"""検証器。確かめてから値を返す。claims の形は知らない。

問い合わせは (repository, mode, 変数名, **args) を受ける。mode は "full"（本番）か "sanity"（試運転）。
値の元になる run は、その mode の成功した最新の run。番号は claims に書かない。
"""
import functools
import hashlib
import io
import json
import re
import subprocess
import zipfile
from fractions import Fraction

BRANCH = "main"
EXPERIMENT_WORKFLOW = "run_experiment.yml"
ARTIFACT = "run-output"
OUTPUT_PATH = "outputs/results/metrics.json"
CLAIMS_PATH = "formal/claims.json"


def _gh(*args: str) -> str:
    return subprocess.run(["gh", *args], check=True, capture_output=True, text=True).stdout


@functools.cache
def _experiment_runs(repository: str, mode: str) -> list[dict]:
    """実験のワークフローの、その mode の run。新しい順。mode は起動時の入力で、run の名前の末尾に入っている。"""
    runs = json.loads(_gh("api", f"repos/{repository}/actions/workflows/{EXPERIMENT_WORKFLOW}/runs?branch={BRANCH}&per_page=100"))
    return [run for run in runs["workflow_runs"] if run["display_title"].split()[-1] == mode]


def _evidence_run(repository: str, mode: str) -> dict:
    succeeded = [run for run in _experiment_runs(repository, mode) if run["conclusion"] == "success"]
    if not succeeded:
        raise ValueError(f"成功した {mode} の run が無い")
    return succeeded[0]


@functools.cache
def _artifact(repository: str, mode: str) -> zipfile.ZipFile:
    """artifact がその run のもので、中身が GitHub の記録した digest と一致することを確かめて開く。"""
    run = _evidence_run(repository, mode)["id"]
    artifacts = json.loads(_gh("api", f"repos/{repository}/actions/runs/{run}/artifacts"))["artifacts"]
    matches = [a for a in artifacts if a["name"] == ARTIFACT and not a["expired"]]
    if len(matches) != 1:
        raise ValueError(f"run {run} に artifact {ARTIFACT!r} が {len(matches)} 個ある")
    archive = subprocess.run(["gh", "api", f"repos/{repository}/actions/artifacts/{matches[0]['id']}/zip"],
                             check=True, capture_output=True).stdout
    if "sha256:" + hashlib.sha256(archive).hexdigest() != matches[0]["digest"]:
        raise ValueError(f"artifact {ARTIFACT!r} の中身が、GitHub の記録した digest と一致しない")
    return zipfile.ZipFile(io.BytesIO(archive))


def _output(repository: str, mode: str) -> dict:
    """実験の出力。小数は書かれた桁のままの有理数で読む。"""
    return json.loads(_artifact(repository, mode).read(OUTPUT_PATH), parse_float=Fraction)


def experiment_output(repository: str, mode: str, variable: str):
    """実験の出力の、変数名と同じキーの値。"""
    return _output(repository, mode)[variable]


def experiment_output_keys(repository: str, mode: str, variable: str) -> list[str]:
    """実験の出力にあるキーの一覧。"""
    return list(_output(repository, mode))


def artifact_file_sha256(repository: str, mode: str, variable: str, path: str) -> str:
    """artifact にあるファイルの SHA-256。"""
    return hashlib.sha256(_artifact(repository, mode).read(path)).hexdigest()


def artifact_json(repository: str, mode: str, variable: str, path: str, key: str):
    """artifact にある JSON の、キーの値。"""
    return json.loads(_artifact(repository, mode).read(path), parse_float=Fraction)[key]


def _file_at(repository: str, commit: str, path: str) -> str | None:
    result = subprocess.run(["gh", "api", f"repos/{repository}/contents/{path}?ref={commit}",
                             "-H", "Accept: application/vnd.github.raw"], capture_output=True, text=True)
    return result.stdout if result.returncode == 0 else None


def _matched(source: str | None, pattern: str) -> str | None:
    matches = re.findall(pattern, source or "")
    return matches[0] if len(matches) == 1 else None


def source_text(repository: str, mode: str, variable: str, path: str, pattern: str) -> str:
    """run が実行した commit のファイルから、正規表現で取り出した文字列。"""
    commit = _evidence_run(repository, mode)["head_sha"]
    value = _matched(_file_at(repository, commit, path), pattern)
    if value is None:
        raise ValueError(f"{path}@{commit}: {pattern!r} がちょうど 1 箇所には一致しない")
    return value


def _commit_position(repository: str, commit: str) -> int:
    """その commit までの履歴にある commit の数。履歴が一本なら、小さいほど前。"""
    headers = _gh("api", "-i", f"repos/{repository}/commits?sha={commit}&per_page=1")
    last_page = re.search(r'[?&]page=(\d+)>; rel="last"', headers)
    return int(last_page.group(1)) if last_page else 1


def _declared_position(repository: str, path: str, read) -> int:
    """ファイルの履歴で、read が値を初めて返した commit の位置。その後に値が変わっていたら、追記のみの違反。"""
    # ponytail: 履歴が 100 commit を超えたら、ページをめくる必要がある
    commits = _gh("api", f"repos/{repository}/commits?path={path}&sha={BRANCH}&per_page=100", "--jq", ".[].sha").split()
    declared = [(commit, value) for commit in reversed(commits)
                if (value := read(_file_at(repository, commit, path))) is not None]
    if not declared:
        raise ValueError(f"{path}: 値が宣言されていない")
    if len({json.dumps(value, sort_keys=True) for _, value in declared}) != 1:
        raise ValueError(f"{path}: 宣言した値が、後の commit で変わっている")
    return _commit_position(repository, declared[0][0])


def declared_value_commit_position(repository: str, mode: str, variable: str, declared_variable: str) -> int:
    """claims.json で、その変数に宣言した値を初めて書いた commit の、履歴の中での位置。"""
    def read(source: str | None):
        return json.loads(source or "{}").get("variables", {}).get(declared_variable, {}).get("declared")
    return _declared_position(repository, CLAIMS_PATH, read)


def source_text_commit_position(repository: str, mode: str, variable: str, path: str, pattern: str) -> int:
    """ソースのファイルで、正規表現に一致する文字列を初めて書いた commit の、履歴の中での位置。"""
    return _declared_position(repository, path, lambda source: _matched(source, pattern))


def first_full_run_commit_position(repository: str, mode: str, variable: str) -> int:
    """本番の最初の run（失敗も含む）が実行した commit の、履歴の中での位置。"""
    runs = _experiment_runs(repository, "full")
    if not runs:
        raise ValueError("本番の run がまだ無い")
    return _commit_position(repository, runs[-1]["head_sha"])


def repository_public(repository: str, mode: str, variable: str) -> bool:
    """リポジトリが公開されているか。"""
    return json.loads(_gh("api", f"repos/{repository}"))["visibility"] == "public"


def repository_files(repository: str, mode: str, variable: str) -> list[str]:
    """リポジトリのファイルの一覧。"""
    tree = json.loads(_gh("api", f"repos/{repository}/git/trees/{BRANCH}?recursive=1"))
    return [entry["path"] for entry in tree["tree"] if entry["type"] == "blob"]


QUERIES = {"GitHub": {f.__name__: f for f in (
    experiment_output, experiment_output_keys, artifact_file_sha256, artifact_json, source_text,
    declared_value_commit_position, source_text_commit_position, first_full_run_commit_position,
    repository_public, repository_files)}}

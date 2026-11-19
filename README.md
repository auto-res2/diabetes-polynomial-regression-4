# diabetes-polynomial-regression-4

糖尿病データセット（Efron et al., 2004）に 2 次の多項式回帰を当てはめ、予測性能を評価する実験。線形回帰の結果は auto-res2/diabetes-linear-regression-6 を引用する。

- レポート: [`report/report.pdf`](report/report.pdf)（論文の「実験設定」と「結果」の節を抜粋した体裁）
- 実験コード: [`src/run_experiment.py`](src/run_experiment.py)
- 出力: [`results/metrics.json`](results/metrics.json)（実験の後に置く。レポートも実験の後に値を入れて作る）
- claims と検証: [`formal/`](formal/)（claims.json に宣言し、GitHub Actions で検証する）

## 再現

```bash
uv sync --frozen
uv run python src/run_experiment.py        # データを取得し、results/metrics.json を書く
uv run python src/make_report_values.py    # report/values.tex を書く
cd report && lualatex report.tex && lualatex report.tex
```

データは `src/download_data.py` が公開ファイルから取得し、SHA-256 が固定値と一致することを確かめる。

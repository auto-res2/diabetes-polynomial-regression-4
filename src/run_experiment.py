"""糖尿病データセットに 2 次の多項式回帰を当てはめ、値を results/metrics.json に書く。

出力のキーは、Lean の変数名と同じにする（formal/claims.json の variables）。
--sanity を付けると、同じ形の合成データで実行する。仕組みの試運転用で、結果は証拠にしない。
"""
import hashlib
import json
import os
import platform
import sys
from pathlib import Path

import numpy as np
import sklearn
from sklearn.linear_model import LinearRegression
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split

from download_data import DATA_PATH, download_data

TEST_SIZE = 0.2
POLY_DEGREE = 2
SEED = 0
RESULTS_PATH = Path("results/metrics.json")
COLUMNS = ["AGE", "SEX", "BMI", "BP", "S1", "S2", "S3", "S4", "S5", "S6", "Y"]


def write_sanity_data() -> Path:
    """本番のデータと同じ形（442 行、11 列）の乱数の表を、本番のデータと同じ場所に書く。"""
    table = np.random.default_rng(0).normal(100.0, 20.0, size=(442, len(COLUMNS))).round(1)
    DATA_PATH.parent.mkdir(parents=True, exist_ok=True)
    np.savetxt(DATA_PATH, table, fmt="%.1f", delimiter="\t", header="\t".join(COLUMNS), comments="")
    return DATA_PATH


def metrics(split: str, y_true: np.ndarray, y_pred: np.ndarray) -> dict[str, float]:
    mse = float(mean_squared_error(y_true, y_pred))
    return {
        f"{split}Mse": mse,
        f"{split}Rmse": mse**0.5,
        f"{split}Mae": float(mean_absolute_error(y_true, y_pred)),
        f"{split}R2": float(r2_score(y_true, y_pred)),
    }


def environment() -> dict[str, object]:
    """実行した計算機とソフトウェアの情報。"""
    cpu_model = next(
        (line.split(":", 1)[1].strip() for line in Path("/proc/cpuinfo").read_text().splitlines()
         if line.startswith("model name")), platform.processor())
    memory_kb = next(
        int(line.split()[1]) for line in Path("/proc/meminfo").read_text().splitlines()
        if line.startswith("MemTotal"))
    return {
        "envCpuModel": cpu_model,
        "envCpuLogicalCores": os.cpu_count(),
        "envMemoryGib": round(memory_kb / 1024**2, 1),
        "envPython": platform.python_version(),
        "envNumpy": np.__version__,
        "envScikitLearn": sklearn.__version__,
    }


def public_name(cls: type) -> str:
    """クラスの、下線で始まる内部のモジュールを除いた名前。"""
    modules = [part for part in cls.__module__.split(".") if not part.startswith("_")]
    return ".".join(modules + [cls.__qualname__])


def sha256(array: np.ndarray) -> str:
    return hashlib.sha256(np.ascontiguousarray(array).tobytes()).hexdigest()


def main() -> None:
    data_path = write_sanity_data() if "--sanity" in sys.argv else download_data()
    columns = data_path.read_text().splitlines()[0].split("\t")
    table = np.loadtxt(data_path, skiprows=1)
    features, target = table[:, :-1], table[:, -1]
    train_index, test_index = train_test_split(np.arange(len(target)), test_size=TEST_SIZE, random_state=SEED)
    x_train, x_test, y_train, y_test = features[train_index], features[test_index], target[train_index], target[test_index]
    model_input = x_train
    fit_input = np.column_stack([model_input, y_train])
    model = make_pipeline(PolynomialFeatures(POLY_DEGREE, include_bias=False), LinearRegression()).fit(fit_input[:, :-1], fit_input[:, -1])
    result = {
        "nSamples": int(len(target)), "nFeatures": int(features.shape[1]),
        "featureColumns": columns[:-1], "targetColumn": columns[-1],
        "splitSeed": SEED, "nTrain": int(len(y_train)), "nTest": int(len(y_test)),
        "trainIndex": [int(i) for i in train_index], "testIndex": [int(i) for i in test_index],
        "loadedXSha256": sha256(features[train_index]), "modelInputXSha256": sha256(model_input),
        # モデルに入れた訓練データとテストデータ（説明変数と目的変数）。文献 [1] と同じデータかを照合するための値
        "trainDataSha256": sha256(np.column_stack([model_input, y_train])), "testDataSha256": sha256(np.column_stack([x_test, y_test])),
        "usedFeatureCount": int(model.n_features_in_), "fitSteps": [public_name(type(step)) for _, step in model.steps],
        "polyDegree": POLY_DEGREE, "nPolyFeatures": int(model[0].n_output_features_),
        # 交互作用項（2 つの変数の積）の数と、当てはめに渡したデータ（説明変数と目的変数）
        "nInteractionFeatures": sum(" " in name for name in model[0].get_feature_names_out()), "fitInputSha256": sha256(fit_input),
        "targetMean": float(target.mean()), "targetStd": float(target.std()),
        **metrics("train", y_train, model.predict(x_train)),
        **metrics("test", y_test, model.predict(x_test)),
        "meanPredictorTestRmse": float(mean_squared_error(y_test, np.full_like(y_test, y_train.mean()))) ** 0.5,
        **environment(),
    }
    RESULTS_PATH.parent.mkdir(parents=True, exist_ok=True)
    RESULTS_PATH.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: value for key, value in result.items() if not key.endswith("Index")}, indent=2))


if __name__ == "__main__":
    main()

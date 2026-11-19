"""results/metrics.json の値を、レポートが読み込む LaTeX のマクロに書き出す。"""
import json
from pathlib import Path

result = json.loads(Path("results/metrics.json").read_text())
lines = [
    f"\\newcommand{{\\NSamples}}{{{result['nSamples']}}}",
    f"\\newcommand{{\\NFeatures}}{{{result['nFeatures']}}}",
    f"\\newcommand{{\\NTrain}}{{{result['nTrain']}}}",
    f"\\newcommand{{\\NTest}}{{{result['nTest']}}}",
    f"\\newcommand{{\\Seed}}{{{result['splitSeed']}}}",
    f"\\newcommand{{\\TargetMean}}{{{result['targetMean']:.1f}}}",
    f"\\newcommand{{\\TargetStd}}{{{result['targetStd']:.1f}}}",
    f"\\newcommand{{\\NPolyFeatures}}{{{result['nPolyFeatures']}}}",
]
for split, name in (("train", "Train"), ("test", "Test")):
    lines += [
        f"\\newcommand{{\\{name}Mse}}{{{result[split + 'Mse']:.1f}}}",
        f"\\newcommand{{\\{name}Rmse}}{{{result[split + 'Rmse']:.1f}}}",
        f"\\newcommand{{\\{name}Mae}}{{{result[split + 'Mae']:.1f}}}",
        f"\\newcommand{{\\{name}Rsq}}{{{result[split + 'R2']:.3f}}}",
    ]
lines += [
    f"\\newcommand{{\\CpuModel}}{{{result['envCpuModel'].replace('(R)', '').replace('(TM)', '').replace('CPU @ ', '')}}}",
    f"\\newcommand{{\\CpuCores}}{{{result['envCpuLogicalCores']}}}",
    f"\\newcommand{{\\MemoryGib}}{{{result['envMemoryGib']}}}",
    f"\\newcommand{{\\PythonVersion}}{{{result['envPython']}}}",
    f"\\newcommand{{\\NumpyVersion}}{{{result['envNumpy']}}}",
    f"\\newcommand{{\\SklearnVersion}}{{{result['envScikitLearn']}}}",
]
Path("report/values.tex").write_text("\n".join(lines) + "\n")

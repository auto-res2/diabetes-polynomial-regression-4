import Mathlib
import References
/-!
レポート 2 の各文の claims を、命題として書いたもの。
値はすべて引数で受ける。値を入れるのは parse_claims.py が生成する Theorems.lean。
仕様は文献 [1]。[1] の claims と検証済みの値は References.lean（parse_claims.py が [1] のスキーマから生成する）に公理として置かれ、
ここでは Ref1.… として使う。
検証器が無い claims は、対象を opaque な定数として置き、公理として宣言する（末尾）。
-/
namespace Claims

/-! ## R01 -/
/-- データセット（観測）。実行が読んだファイルは、コードに固定したファイルである。 -/
abbrev R01_c1 (observedSha256 dataSha256 : String) : Prop := observedSha256 = dataSha256
/-- データセット（[1] との一致）。読んだファイルは [1] が読んだファイルと同じ。 -/
abbrev R01_c2 (observedSha256 : String) : Prop := observedSha256 = Ref1.observedSha256
/-- データセット。コードの指定 = 実際に読んだファイル = [1] が読んだファイル。 -/
abbrev R01_c3 (dataSha256 observedSha256 : String) : Prop := dataSha256 = observedSha256 ∧ observedSha256 = Ref1.observedSha256
/-- 前処理（観測）。説明変数に加工をしていない。 -/
abbrev R01_c4 (modelInputXSha256 loadedXSha256 : String) : Prop := modelInputXSha256 = loadedXSha256
/-- 前処理（[1] との一致）。モデルに入れた説明変数は [1] と同じ。 -/
abbrev R01_c5 (modelInputXSha256 : String) : Prop := modelInputXSha256 = Ref1.modelInputXSha256
/-- 前処理。読み込んだデータ = モデルに入れたデータ = [1] がモデルに入れたデータ。 -/
abbrev R01_c6 (loadedXSha256 modelInputXSha256 : String) : Prop := loadedXSha256 = modelInputXSha256 ∧ modelInputXSha256 = Ref1.modelInputXSha256
/-- 分割（観測）。シード 0、テストの割合 20%。 -/
abbrev R01_c7 (splitSeed nTest nSamples : ℕ) : Prop := splitSeed = 0 ∧ (nTest : ℤ) = ⌈(0.2 : ℚ) * nSamples⌉
/-- 分割（[1] との一致）。訓練とテストの添字は [1] と同じ。 -/
abbrev R01_c8 (trainIndex testIndex : List ℕ) : Prop := trainIndex = Ref1.trainIndex ∧ testIndex = Ref1.testIndex
/-- 分割。シード 0・割合 20% の手順で行い、その結果の添字が [1] と一致する。 -/
abbrev R01_c9 (splitSeed nTest nSamples : ℕ) (trainIndex testIndex : List ℕ) : Prop :=
  (splitSeed = 0 ∧ (nTest : ℤ) = ⌈(0.2 : ℚ) * nSamples⌉) ∧ (trainIndex = Ref1.trainIndex ∧ testIndex = Ref1.testIndex)

/-! ## R02 -/
abbrev R02_c1 (outputKeys : List String) : Prop :=
  ["trainMse", "trainRmse", "trainMae", "trainR2", "testMse", "testRmse", "testMae", "testR2"] ⊆ outputKeys
/-- 検証器なし。出力の各指標は、[1] の定義（Ref1.mse、Ref1.rmse、Ref1.mae、Ref1.r2）どおりに計算した値である。 -/
abbrev R02_c2 (trainMse trainRmse trainMae trainR2 testMse testRmse testMae testR2 : ℝ)
    (yTrain ŷTrain : Fin 353 → ℝ) (yTest ŷTest : Fin 89 → ℝ) : Prop :=
  trainMse = Ref1.mse yTrain ŷTrain ∧ trainRmse = Ref1.rmse yTrain ŷTrain ∧
  trainMae = Ref1.mae yTrain ŷTrain ∧ trainR2 = Ref1.r2 yTrain ŷTrain ∧
  testMse = Ref1.mse yTest ŷTest ∧ testRmse = Ref1.rmse yTest ŷTest ∧
  testMae = Ref1.mae yTest ŷTest ∧ testR2 = Ref1.r2 yTest ŷTest
abbrev R02_c3 (trainRmse trainMse testRmse testMse rmseSquaredTolerance : ℚ) : Prop :=
  |trainRmse ^ 2 - trainMse| ≤ rmseSquaredTolerance ∧ |testRmse ^ 2 - testMse| ≤ rmseSquaredTolerance

/-! ## R03 -/
abbrev R03_c1 (polyDegree nPolyFeatures : ℕ) : Prop := polyDegree = 2 ∧ nPolyFeatures = 65
abbrev R03_c2 (nInteractionFeatures : ℕ) : Prop := nInteractionFeatures = 45
abbrev R03_c3 (fitInputSha256 trainDataSha256 : String) : Prop := fitInputSha256 = trainDataSha256
/-- 検証器なし。展開した変数に対する係数は、訓練データ上の残差の二乗和を最小にする（モデルは [1] の Ref1.linearModel）。 -/
abbrev R03_c4 (X : Fin 353 → Fin 65 → ℝ) (y : Fin 353 → ℝ) (β₀ : ℝ) (β : Fin 65 → ℝ) : Prop :=
  ∀ b₀ b, ∑ i, (y i - Ref1.linearModel β₀ β (X i)) ^ 2 ≤ ∑ i, (y i - Ref1.linearModel b₀ b (X i)) ^ 2

/-! ## R04 -/
/-- 検証器なし。正則化の係数は 0 である。 -/
abbrev R04_c1 (penaltyWeight : ℚ) : Prop := penaltyWeight = 0

/-! ## R06 -/
/-- 同じテストデータ（添字が [1] と一致）で、[1] の線形回帰のテストの MSE（Ref1.testMse）より小さい。 -/
abbrev R06_c1 (testIndex : List ℕ) (testMse : ℚ) : Prop := testIndex = Ref1.testIndex ∧ testMse < Ref1.testMse
/-- c1 ならば、予測精度が高い（予測精度が高い = テストの MSE が小さい）。 -/
abbrev R06_c2 (testIndex : List ℕ) (testMse : ℚ) : Prop :=
  testIndex = Ref1.testIndex ∧ testMse < Ref1.testMse → testMse < Ref1.testMse

/-! ## 検証器が無い claims の公理 -/
namespace Unobserved
noncomputable opaque trainMse : ℝ
noncomputable opaque trainRmse : ℝ
noncomputable opaque trainMae : ℝ
noncomputable opaque trainR2 : ℝ
noncomputable opaque testMse : ℝ
noncomputable opaque testRmse : ℝ
noncomputable opaque testMae : ℝ
noncomputable opaque testR2 : ℝ
noncomputable opaque yTrain : Fin 353 → ℝ
noncomputable opaque ŷTrain : Fin 353 → ℝ
noncomputable opaque yTest : Fin 89 → ℝ
noncomputable opaque ŷTest : Fin 89 → ℝ
noncomputable opaque polyX : Fin 353 → Fin 65 → ℝ
noncomputable opaque β₀ : ℝ
noncomputable opaque β : Fin 65 → ℝ
opaque penaltyWeight : ℚ
end Unobserved

open Unobserved in
axiom R02_c2_axiom : R02_c2 trainMse trainRmse trainMae trainR2 testMse testRmse testMae testR2 yTrain ŷTrain yTest ŷTest
open Unobserved in
axiom R03_c4_axiom : R03_c4 polyX yTrain β₀ β
axiom R04_c1_axiom : R04_c1 Unobserved.penaltyWeight

end Claims

import Mathlib
/-! 引用した claims と値の公理。parse_claims.py が引用先のスキーマから生成する。手で編集しない。 -/
namespace Ref1
-- https://github.com/auto-res2/diabetes-linear-regression-6 の commit bc1e74fa8ca0e776724fff18c471d0e627540c1c
opaque modelInputXSha256 : String
opaque loadedXSha256 : String
noncomputable opaque linearModel {p : ℕ} (β₀ : ℝ) (β : Fin p → ℝ) (x : Fin p → ℝ) : ℝ
opaque outputKeys : List String
noncomputable opaque mean {n : ℕ} (y : Fin n → ℝ) : ℝ
noncomputable opaque mse {n : ℕ} (y ŷ : Fin n → ℝ) : ℝ
noncomputable opaque r2 {n : ℕ} (y ŷ : Fin n → ℝ) : ℝ
noncomputable opaque mae {n : ℕ} (y ŷ : Fin n → ℝ) : ℝ
noncomputable opaque rmse {n : ℕ} (y ŷ : Fin n → ℝ) : ℝ
opaque testMse : ℚ
opaque trainMse : ℚ
opaque trainRmse : ℚ
opaque trainMae : ℚ
opaque trainR2 : ℚ
opaque testRmse : ℚ
opaque testMae : ℚ
opaque testR2 : ℚ
opaque observedSha256 : String
opaque trainIndex : List ℕ
opaque testIndex : List ℕ
abbrev R04_c1 (modelInputXSha256 loadedXSha256 : String) : Prop := modelInputXSha256 = loadedXSha256
abbrev R08_c2 : Prop := ∀ (p : ℕ) (β₀ : ℝ) (β x : Fin p → ℝ), linearModel β₀ β x = β₀ + ∑ j, β j * x j
abbrev R11_c1 (outputKeys : List String) : Prop :=
  ["trainMse", "trainRmse", "trainMae", "trainR2", "testMse", "testRmse", "testMae", "testR2"] ⊆ outputKeys
abbrev R12_c1 : Prop := ∀ (n : ℕ) (y ŷ : Fin n → ℝ),
  mse y ŷ = (1 / (n : ℝ)) * ∑ i, (y i - ŷ i) ^ 2 ∧
  r2 y ŷ = 1 - (∑ i, (y i - ŷ i) ^ 2) / ∑ i, (y i - mean y) ^ 2
abbrev R13_c1 : Prop := ∀ (n : ℕ) (y : Fin n → ℝ), mean y = (1 / (n : ℝ)) * ∑ i, y i
abbrev R14_c3 : Prop := ∀ (n : ℕ) (y ŷ : Fin n → ℝ), mae y ŷ = (1 / (n : ℝ)) * ∑ i, |y i - ŷ i|
abbrev R14_c4 : Prop := ∀ (n : ℕ) (y ŷ : Fin n → ℝ), rmse y ŷ = Real.sqrt (mse y ŷ)
abbrev R15_c1 (outputKeys : List String) : Prop := R11_c1 outputKeys
abbrev R20_c1 (testMse : ℚ) : Prop := (round (testMse / 0.1) : ℚ) * 0.1 = 3424.3
abbrev R26_c1 (trainMse trainRmse trainMae trainR2 testMse testRmse testMae testR2 : ℚ) : Prop :=
  (round (trainMse / 0.1) : ℚ) * 0.1 = 2734.8 ∧ (round (trainRmse / 0.1) : ℚ) * 0.1 = 52.3 ∧
  (round (trainMae / 0.1) : ℚ) * 0.1 = 42.6 ∧ (round (trainR2 / 0.001) : ℚ) * 0.001 = 0.554 ∧
  (round (testMse / 0.1) : ℚ) * 0.1 = 3424.3 ∧ (round (testRmse / 0.1) : ℚ) * 0.1 = 58.5 ∧
  (round (testMae / 0.1) : ℚ) * 0.1 = 46.2 ∧ (round (testR2 / 0.001) : ℚ) * 0.001 = 0.332
axiom R04_c1_cited : R04_c1 modelInputXSha256 loadedXSha256
axiom R08_c2_cited : R08_c2
axiom R11_c1_cited : R11_c1 outputKeys
axiom R12_c1_cited : R12_c1
axiom R13_c1_cited : R13_c1
axiom R14_c3_cited : R14_c3
axiom R14_c4_cited : R14_c4
axiom R15_c1_cited : R15_c1 outputKeys
axiom R20_c1_cited : R20_c1 testMse
axiom R26_c1_cited : R26_c1 trainMse trainRmse trainMae trainR2 testMse testRmse testMae testR2
axiom observedSha256_value : observedSha256 = "4733febee697862c22139cdac87478a300ce0d101593deb07ed6c0f3328a99cd"
axiom modelInputXSha256_value : modelInputXSha256 = "ae560a6efb1b86fbce564225a40502c1f85dcbbc7acb6f5830bac71c5aa7bfec"
axiom trainIndex_value : trainIndex = [74, 26, 45, 389, 154, 4, 386, 225, 327, 264, 8, 190, 5, 371, 200, 313, 7, 325, 366, 22, 68, 437, 20, 353, 281, 14, 300, 240, 175, 405, 153, 75, 64, 55, 135, 329, 81, 316, 369, 328, 414, 421, 361, 415, 232, 224, 252, 254, 418, 106, 278, 63, 336, 378, 387, 430, 89, 93, 245, 272, 241, 92, 18, 145, 150, 322, 393, 297, 231, 66, 380, 412, 140, 101, 345, 247, 363, 17, 146, 315, 220, 30, 114, 235, 103, 219, 274, 176, 191, 116, 168, 367, 120, 218, 112, 303, 136, 308, 221, 126, 196, 332, 424, 133, 33, 419, 162, 34, 44, 97, 85, 61, 167, 199, 173, 229, 236, 433, 376, 250, 108, 407, 46, 357, 372, 263, 73, 137, 422, 246, 253, 29, 181, 374, 301, 51, 365, 391, 217, 432, 27, 2, 259, 156, 255, 417, 346, 138, 212, 104, 310, 306, 311, 215, 348, 189, 214, 35, 230, 204, 234, 293, 239, 210, 67, 24, 295, 216, 223, 129, 111, 166, 349, 40, 317, 79, 431, 350, 13, 364, 436, 228, 161, 83, 439, 416, 110, 149, 152, 16, 299, 109, 312, 139, 237, 260, 318, 355, 248, 342, 19, 269, 226, 340, 3, 309, 125, 280, 286, 77, 184, 354, 420, 275, 294, 384, 182, 395, 80, 307, 258, 11, 331, 86, 266, 36, 423, 58, 41, 270, 50, 209, 352, 351, 368, 123, 222, 62, 379, 130, 187, 23, 43, 0, 201, 377, 98, 304, 429, 178, 256, 94, 409, 95, 390, 169, 69, 305, 48, 341, 207, 279, 227, 148, 143, 334, 180, 356, 131, 425, 440, 262, 324, 203, 84, 121, 383, 406, 91, 82, 267, 119, 358, 291, 57, 321, 257, 394, 42, 105, 408, 273, 392, 38, 53, 385, 128, 290, 28, 183, 370, 163, 151, 244, 202, 31, 32, 127, 185, 413, 288, 398, 402, 147, 285, 410, 177, 99, 338, 335, 197, 243, 115, 404, 265, 72, 333, 25, 165, 337, 426, 174, 428, 39, 193, 314, 396, 88, 70, 87, 292, 242, 277, 211, 9, 359, 195, 251, 323, 192, 117, 47, 172]
axiom testIndex_value : testIndex = [362, 249, 271, 435, 400, 403, 12, 399, 198, 205, 78, 144, 298, 171, 268, 21, 194, 1, 10, 208, 76, 37, 388, 411, 289, 100, 261, 401, 319, 206, 375, 283, 373, 344, 287, 360, 179, 238, 434, 302, 158, 118, 339, 397, 330, 296, 164, 54, 157, 71, 284, 6, 343, 326, 159, 15, 320, 60, 282, 142, 56, 124, 107, 132, 382, 102, 160, 141, 186, 441, 90, 59, 347, 233, 427, 65, 438, 155, 122, 276, 188, 96, 170, 113, 381, 213, 134, 49, 52]
axiom testMse_value : testMse = ((8560648335746739 : ℚ) / 2500000000000)
axiom trainMse_value : trainMse = ((1709219311922339 : ℚ) / 625000000000)
axiom trainRmse_value : trainRmse = ((5229484581749661 : ℚ) / 100000000000000)
axiom trainMae_value : trainMae = ((21296672157121723 : ℚ) / 500000000000000)
axiom trainR2_value : trainR2 = ((346203130086067 : ℚ) / 625000000000000)
axiom testRmse_value : testRmse = ((1170343425546313 : ℚ) / 20000000000000)
axiom testMae_value : testMae = ((1154339625092621 : ℚ) / 25000000000000)
axiom testR2_value : testR2 = ((3244465012799 : ℚ) / 9765625000000)
end Ref1

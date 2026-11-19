import Values
import Claims
open Claims
/-! 各命題の判定。parse_claims.py が生成する。 -/
theorem R01_c1_holds : R01_c1 (observedSha256 := Values.observedSha256) (dataSha256 := Values.dataSha256) := by decide +kernel
theorem R01_c2_holds : R01_c2 (observedSha256 := Values.observedSha256) := by unfold R01_c2; rw [Ref1.observedSha256_value]; decide +kernel
theorem R01_c3_holds : R01_c3 (dataSha256 := Values.dataSha256) (observedSha256 := Values.observedSha256) := by unfold R01_c3; rw [Ref1.observedSha256_value]; decide +kernel
theorem R01_c4_holds : R01_c4 (modelInputXSha256 := Values.modelInputXSha256) (loadedXSha256 := Values.loadedXSha256) := by decide +kernel
theorem R01_c5_holds : R01_c5 (modelInputXSha256 := Values.modelInputXSha256) := by unfold R01_c5; rw [Ref1.modelInputXSha256_value]; decide +kernel
theorem R01_c6_holds : R01_c6 (loadedXSha256 := Values.loadedXSha256) (modelInputXSha256 := Values.modelInputXSha256) := by unfold R01_c6; rw [Ref1.modelInputXSha256_value]; decide +kernel
theorem R01_c7_holds : R01_c7 (splitSeed := Values.splitSeed) (nTest := Values.nTest) (nSamples := Values.nSamples) := by decide +kernel
theorem R01_c8_holds : R01_c8 (trainIndex := Values.trainIndex) (testIndex := Values.testIndex) := by unfold R01_c8; rw [Ref1.trainIndex_value, Ref1.testIndex_value]; decide +kernel
theorem R01_c9_holds : R01_c9 (splitSeed := Values.splitSeed) (nTest := Values.nTest) (nSamples := Values.nSamples) (trainIndex := Values.trainIndex) (testIndex := Values.testIndex) := by unfold R01_c9; rw [Ref1.trainIndex_value, Ref1.testIndex_value]; decide +kernel
theorem R02_c1_holds : R02_c1 (outputKeys := Values.outputKeys) := by decide +kernel
theorem R02_c3_holds : R02_c3 (trainRmse := Values.trainRmse) (trainMse := Values.trainMse) (testRmse := Values.testRmse) (testMse := Values.testMse) (rmseSquaredTolerance := Values.rmseSquaredTolerance) := by decide +kernel
theorem R03_c1_holds : R03_c1 (polyDegree := Values.polyDegree) (nPolyFeatures := Values.nPolyFeatures) := by decide +kernel
theorem R03_c2_holds : R03_c2 (nInteractionFeatures := Values.nInteractionFeatures) := by decide +kernel
theorem R03_c3_holds : R03_c3 (fitInputSha256 := Values.fitInputSha256) (trainDataSha256 := Values.trainDataSha256) := by decide +kernel
theorem R05_c1_holds : R05_c1 (testMse := Values.testMse) := by decide +kernel
theorem R06_c1_fails : ¬ (R06_c1 (testIndex := Values.testIndex) (testMse := Values.testMse)) := by unfold R06_c1; rw [Ref1.testIndex_value, Ref1.testMse_value]; decide +kernel
theorem R06_c2_holds : R06_c2 (testIndex := Values.testIndex) (testMse := Values.testMse) := by unfold R06_c2; rw [Ref1.testIndex_value, Ref1.testMse_value]; decide +kernel
theorem R07_c1_holds : R07_c1 (trainMse := Values.trainMse) (trainRmse := Values.trainRmse) (trainMae := Values.trainMae) (trainR2 := Values.trainR2) (testMse := Values.testMse) (testRmse := Values.testRmse) (testMae := Values.testMae) (testR2 := Values.testR2) := by decide +kernel
theorem R07_c2_holds : R07_c2 := by unfold R07_c2; rw [Ref1.trainMse_value, Ref1.trainRmse_value, Ref1.trainMae_value, Ref1.trainR2_value, Ref1.testMse_value, Ref1.testRmse_value, Ref1.testMae_value, Ref1.testR2_value]; decide +kernel

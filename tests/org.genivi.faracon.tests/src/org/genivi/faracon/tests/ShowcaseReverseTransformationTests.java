package org.genivi.faracon.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.tests.util.ARA2FrancaTestBase;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.junit.Test;
import org.junit.Ignore;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class ShowcaseReverseTransformationTests extends ARA2FrancaTestBase {

	private static final String GENERATED_SHOWCASE_ARA_MODELS = "src-gen/testcases/";

	@Test
	@Ignore("The test should not use input models which are generated by other testcases!")
	public void createDrivingLaneFranca() {
		transform(GENERATED_SHOWCASE_ARA_MODELS, "drivingLane");
	}
	
	@Test
	@Ignore("The test should not use input models which are generated by other testcases!")
	public void createVehiclesFranca() {
		transform(GENERATED_SHOWCASE_ARA_MODELS, "vehicles");
	}
	
}

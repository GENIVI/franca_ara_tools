package org.genivi.faracon.tests.aspects_on_franca_methods.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the conversion of the set of return/output parameters of a Franca method.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1320_Tests extends Franca2ARATestBase {

	static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_on_franca_methods/f2a/"

	@Test
	def void oneMethodReturnValue() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "oneMethodReturnValue")
	}

	@Test
	def void multipleMethodInputArguments() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "multipleMethodReturnValues")
	}

}

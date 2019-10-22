package org.genivi.faracon.tests.aspects_on_franca_methods.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the basic conversion of a Franca method declaration.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1290_Tests extends Franca2ARATestBase {

	static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_on_franca_methods/f2a/"

	@Test
	def void methodWithInAndOutArguments() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "methodWithInAndOutArguments")
	}

}

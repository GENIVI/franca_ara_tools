package org.genivi.faracon.tests.aspects_for_franca_broadcasts.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the conversion of the broadcasts set of an Franca interface definition.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1250_Tests extends Franca2ARATestBase {

	static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_for_franca_broadcasts/f2a/"

	@Test
	def void oneBroadcast() {	
		transformAndCheck(LOCAL_FRANCA_MODELS, "oneBroadcast");
	}

	@Test
	def void multipleMethods() {	
		transformAndCheck(LOCAL_FRANCA_MODELS, "multipleBroadcasts");
	}

}

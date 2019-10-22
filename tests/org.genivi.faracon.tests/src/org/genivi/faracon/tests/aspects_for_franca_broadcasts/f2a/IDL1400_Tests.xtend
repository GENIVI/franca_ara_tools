package org.genivi.faracon.tests.aspects_for_franca_broadcasts.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith
import org.genivi.faracon.logging.AbstractLogger

/**
 * Test cases for testing the conversion of Franca broadcasts with a selector.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1400_Tests extends Franca2ARATestBase {

	static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_for_franca_broadcasts/f2a/"

	@Test(expected = AbstractLogger.StopOnErrorException)
	def void broadcastsWithSelectors() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastsWithSelectors")
	}

}

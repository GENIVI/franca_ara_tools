package org.genivi.faracon.tests.aspects_on_maps.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests autosar maps to franca maps.
 * Also covers IDL 1770 and 1780 for Autosar to Franca.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1760_Tests extends ARA2FrancaTestBase {

	@Test
	def void testMapTypeTransformation() {
		transformAndCheck(testPath + "mapTypeTest.arxml", testPath + "mapTypeTest.fidl")
	}

	@Test
	def void testMapTypeUsageTransformation() {
		transformAndCheck(testPath + "mapTypeUsage.arxml", testPath + "mapTypeUsage.fidl")
	}

}

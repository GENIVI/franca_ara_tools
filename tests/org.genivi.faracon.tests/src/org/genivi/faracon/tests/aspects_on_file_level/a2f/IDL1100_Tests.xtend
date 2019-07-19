package org.genivi.faracon.tests.aspects_on_file_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1100_Tests extends ARA2FrancaTestBase {
	
	@Test
	def void testSingleArPackage() {
		transformAndCheck("src/org/genivi/faracon/tests/aspects_on_file_level/a2f/emptyFile.arxml",
			"src/org/genivi/faracon/tests/aspects_on_file_level/f2a/emptyFile.fidl")
	}
}

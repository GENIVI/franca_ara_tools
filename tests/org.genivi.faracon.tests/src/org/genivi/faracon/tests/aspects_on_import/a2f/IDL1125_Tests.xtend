package org.genivi.faracon.tests.aspects_on_import.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith
import org.genivi.faracon.logging.AbstractLogger

/**
 * Test transformation of imports from autosar to franca
 * Also includes the test for IDL1120
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1125_Tests extends ARA2FrancaTestBase {

	@Test
	def void testMultipleFilesFromAutosarWithImport() {
		transformAndCheckIntegrationTest(#[testPath + "fileWithImport.arxml"],
			#[testPath + "fileWithImport_a1.b2.c3.fidl", testPath + "fileWithImport_a1.b2.c3.d4.fidl"],
			"testMultipleFilesFromAutosarWithImport")
	}

	@Test
	def void testMultipleFilesWithMultipleInterfacesAndTypesWithImport() {
		transformAndCheckIntegrationTest(
			#[testPath + "fileWithMultiImport.arxml"],
			#[testPath + "fileWithMultiImport_a1.b2.c3.fidl", testPath + "fileWithMultiImport_a1.b2.c3.d4.fidl",
				testPath + "fileWithMultiImport_a1.b2.c3.d4.e5.fidl"],
			"testMultipleFilesWithMultipleInterfacesAndTypesWithImport"
		)
	}

	@Test
	def void testMultipleInputToMultipleOutFiles() {
		transformAndCheckIntegrationTest(
			#[testPath + "fileWithMultiImportPart1.arxml", testPath + "fileWithMultiImportPart2.arxml"],
			#[testPath + "fileWithMultiImportPart1_a1.b2.c3.fidl",
				testPath + "fileWithMultiImportPart2_a1.b2.c3.d4.fidl",
				testPath + "fileWithMultiImportPart2_a1.b2.c3.d4.e5.fidl"],
			"IDL1125_testMultipleInputToMultipleOutFiles")
	}

	@Test(expected=AbstractLogger.StopOnErrorException)
	def void testSingleInputFileToMultipleFrancaFiles() {
		transformAndCheckIntegrationTest(#[testPath + "fileWithMultiImportPart1.arxml"],
			#[testPath + "fileWithMultiImport_a1.b2.c3.fidl", testPath + "fileWithMultiImport_a1.b2.c3.d4.fidl",
				testPath + "fileWithMultiImport_a1.b2.c3.d4.e5.fidl"], "testSingleInputFileToMultipleFrancaFiles")
	}
}

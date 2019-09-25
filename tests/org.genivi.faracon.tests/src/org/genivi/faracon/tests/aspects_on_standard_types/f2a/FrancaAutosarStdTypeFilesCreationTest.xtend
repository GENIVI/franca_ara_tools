package org.genivi.faracon.tests.aspects_on_standard_types.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.junit.Assert.assertNotNull

/**
 * Tests whether the autosar std-types are created during test-execution 
 * 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class FrancaAutosarStdTypeFilesCreationTest extends Franca2ARATestBase {
	
	@Test
	def void testAutosarStdFilesCreation(){
		//given
		val inputFolder = "src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/" 
		val inputFile = "oneMethod.fidl"
		val expectedOutputFile = "src/org/genivi/faracon/tests/aspects_on_interface_level/a2f/oneMethod.arxml"
		val outputFolderName = "testAutosarStdFilesCreation"
		
		//when 
		this.transformAndCheckIntegrationTest(inputFolder, #[inputFile], #[expectedOutputFile], outputFolderName)
		
		//then: after a transformation the std type files must be in the output folder
		val outputFolder = Preferences.instance.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, null)
		val arxmlFiles = findArxmlFilesStdFiles(outputFolder, false)
		val stdTypes = arxmlFiles.findFirst[it.endsWith("stdtypes.arxml")]
		stdTypes.assertNotNull()
		val stdVectorTypes = arxmlFiles.findFirst[it.endsWith("stdtypes_vector.arxml")]
		stdVectorTypes.assertNotNull()
	}
	
}
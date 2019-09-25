package org.genivi.faracon.tests.util

import java.util.Collection
import javax.inject.Inject
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.Franca2ARATransformation
import org.genivi.faracon.cli.FilePathsHelper
import org.genivi.faracon.cli.Franca2AraConverter
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants
import org.genivi.faracon.tests.FaraconTestBase

import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertNotNull

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*

abstract class Franca2ARATestBase extends FaraconTestBase {

	@Inject
	var protected extension Franca2ARATransformation franca2AraTransformation
	@Inject
	var protected extension ARATypeCreator araTypeCreator
	@Inject
	var Franca2AraConverter franca2AraConverter

	def void transform(String path, String fileBasename) {
		transformtionTest(path, fileBasename, null, false)
	}

	/**
	 * Do not use this method any longer as it does not perform any check
	 */
	@Deprecated
	def void transformAndCheck(String path, String fileBasename) {
		transformtionTest(path, fileBasename, null, true)
	}

	def void transformAndCheck(String path, String fileBasename, String expectedFilePath) {
		transformtionTest(path, fileBasename, expectedFilePath, true)
	}

	def void transformAndCheckIntegrationTest(String path, Collection<String> files,
		Collection<String> expectedFilePaths, String outputFolderName) {
		// given: non-null strings, which are not empty
		val inputPaths = files.map[path + it].toList
		assertFalse("No source file path given", inputPaths.nullOrEmpty)
		Preferences.instance.setPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH,
			"src-gen/testcases/" + outputFolderName)

		// when
		franca2AraConverter.convertFiles(inputPaths)

		// assert
		val autosarModelPaths = Preferences.instance.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, null)
		assertNotNull("no outputpath found", autosarModelPaths)
		val actualAutosarFiles = findArxmlFilesStdFiles(autosarModelPaths, true)
		actualAutosarFiles.forEach [ autosarFileName |
			// load autosar models and set UUID to 0
			val modelContainer = araConnector.loadModel(autosarFileName) as ARAModelContainer
			modelContainer.model.setUuidsTo0
			araConnector.saveModel(modelContainer, autosarFileName)
		]
		assertAutosarFilesAreEqual(actualAutosarFiles, expectedFilePaths)
	}
	
	protected def Collection<String> findArxmlFilesStdFiles(String autosarModelPaths, boolean ignoreStdFiles) {
		val arxmlFiles = FilePathsHelper.findFiles(#[autosarModelPaths], "arxml")
		if(ignoreStdFiles){
			return arxmlFiles.filter[!it.endsWith("stdtypes.arxml") && !it.endsWith("stdtypes_vector.arxml")].toList	
		}
		return arxmlFiles
	}

	def private void transformtionTest(String path, String fileBasename, String expectedFileName, boolean check) {
		// given
		// load example Franca IDL interface
		val inputfile = path + fileBasename + ".fidl"
		val fmodel = loader.loadModel(inputfile)
		assertNotNull("The franca model " + inputfile + " is null", fmodel)

		// when
		// transform to arxml
		val fromFranca = araConnector.fromFranca(fmodel) as ARAModelContainer
		val araFileName = "src-gen/testcases/" + fileBasename + ".arxml"
		println("Save ara file " + araFileName)
		fromFranca.model.setUuidsTo0
		araConnector.saveModel(fromFranca, araFileName)

		// then
		if (check && expectedFileName !== null) {
			// ensure both use the same resource set
			assertAutosarFilesAreEqual(araFileName, expectedFileName)
		}
	}

	/**
	 * Returns the path to the corresponding autosar to franca test path.
	 * The default implementation assumes that the autosar to franca test path
	 * has the same path, but with "a2f" instead of "f2a" as last segment 
	 */
	def protected String getCorrespondingAutosar2FrancaTestPath() {
		testPath.replaceFirst("f2a", "a2f")
	}

}

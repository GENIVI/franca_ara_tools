package org.genivi.faracon.tests.util

import autosar40.autosartoplevelstructure.AUTOSAR
import com.google.inject.Inject
import java.util.Collection
import java.util.Collections
import java.util.List
import org.franca.core.framework.IModelContainer
import org.franca.core.franca.FModel
import org.genivi.faracon.ARA2FrancaTransformation
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.cli.Ara2FrancaConverter
import org.genivi.faracon.cli.FilePathsHelper
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants
import org.genivi.faracon.tests.FaraconTestBase
import org.junit.After
import org.junit.Before

import static org.genivi.faracon.ARAConnector.*
import static org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertNotNull

abstract class ARA2FrancaTestBase extends FaraconTestBase {

	@Inject
	var protected extension ARA2FrancaTransformation ara2FrancaTransformation

	@Inject
	var Ara2FrancaConverter ara2FrancaConverter

	@Before
	def void beforeTest() {
		Preferences.instance.setPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "src-gen/testcases")
	}

	@After
	def void afterTest() {
		ara2FrancaTransformation.logger.enableContinueOnErrors(false)
	}

	def void transformAndCheck(String sourceFilePath, String expectedFilePath) {
		transformAndCheck(sourceFilePath, Collections.singletonList(expectedFilePath))
	}

	def void transformAndCheck(String sourceFilePath, String fileBasename, FModel expectedModel) {
		transformAndCheck(loadARAModel(sourceFilePath + fileBasename + ".arxml"), expectedModel)
	}

	def void transformAndCheck(AUTOSAR arModel, String expectedFilePath, String expectedFileName) {
		transformAndCheck(arModel, expectedFilePath + expectedFileName + ".arxml")
	}

	def void transformAndCheck(AUTOSAR arModel, String expectedFilePath) {
		transformAndCheck(arModel, loader.loadModel(expectedFilePath))
	}

	def void transformAndCheck(AUTOSAR arModel, FModel expectedFModel) {
		transformAndCheck(arModel, Collections.singletonList(expectedFModel))
	}

	def void transformAndCheck(String sourceFilePath, Collection<String> expectedFilePaths) {
		val expectedFrancaModels = expectedFilePaths.map [
			loader.loadModel(it);
		].toList
		val araModelContainer = araConnector.loadModel(new ARAResourceSet, sourceFilePath) as ARAModelContainer
		val arModel = araModelContainer.model
		transformAndCheck(arModel, expectedFrancaModels)
	}

	def void transformAndCheck(AUTOSAR arModel, Collection<FModel> expectedFModels) {
		val autosarModelContainer = arModel.wrapInModelContainer()
		doTransformTest(autosarModelContainer, expectedFModels)
	}

	protected def List<FModel> transformToFranca(String arFilePath) {
		transformToFranca(loadARAModel(arFilePath))
	}

	protected def List<FModel> transformToFranca(AUTOSAR arModel) {
		transformToFranca(arModel.wrapInModelContainer)
	}

	def private void doTransformTest(IModelContainer arModel, Collection<FModel> expectedModels) {
		// given: non null model and non-null expected models
		assertNotNull("The input ARXML model is null", arModel)
		assertFalse("No expectd franca models provided", expectedModels.isNullOrEmpty)
		expectedModels.forEach[assertNotNull("The expected franca model is null", it)]

		// when: transformed to franca
		val francaModels = transformToFranca(arModel)

		// then: actual model equals expected franca models
		assertFrancaModelsAreEqual(francaModels, expectedModels)
	}

	protected def void transformAndCheckIntegrationTest(Collection<String> sourceFilePaths,
		Collection<String> expectedFilePaths, String outputFolderName) {
		// given: non-null strings, which are not empty
		assertFalse("No source file path given", sourceFilePaths.nullOrEmpty)
		Preferences.instance.setPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH,
			"src-gen/testcases/" + outputFolderName)

		// when
		ara2FrancaConverter.convertFiles(sourceFilePaths)

		// assert
		val expectedFrancaModels = expectedFilePaths.map [
			loader.loadModel(it);
		].toList
		val actualFrancaModelsPath = Preferences.instance.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, null)
		val actualFrancaFilePaths = FilePathsHelper.findFiles(#[actualFrancaModelsPath], "fidl")
		val actualFrancaModels = actualFrancaFilePaths.map[
			loader.loadModel(it)
		].toList
		assertFrancaModelsAreEqual(actualFrancaModels, expectedFrancaModels)
	}

	protected def List<FModel> transformToFranca(IModelContainer arModel) {
		val francaMultiModelContainer = ara2FrancaConverter.convertModelContainersAndSaveResults(Collections.singletonList(arModel as ARAModelContainer))
		val allFrancaModelContainer = francaMultiModelContainer.map[it.francaModelContainers]
		val francaModels = allFrancaModelContainer.flatten.map[it.model].toList
		return francaModels
	}

	protected def ARAModelContainer wrapInModelContainer(AUTOSAR arModel) {
		var ARAResourceSet araResourceSet = arModel?.eResource?.resourceSet as ARAResourceSet
		araResourceSet = if(null === araResourceSet) new ARAResourceSet else araResourceSet
		val autosarModelContainer = new ARAModelContainer(arModel, araResourceSet.standardTypeDefinitionsModel)
		autosarModelContainer
	}

	/**
	 * allows simple saving of an Autosar model element.
	 * 
	 * @param arModel the Autosar Model
	 * @param fileName the file name of the autosar output file
	 */
	def protected saveAraFile(AUTOSAR arModel, String fileName) {
		araConnector.saveARXML(new ARAResourceSet, arModel, this.testPath + fileName)
	}

	/**
	 * Returns the path to the corresponding franca to autosar test path.
	 * The default implementation assumes that the autosar to franca test path
	 * has the same path, but with "f2a" instead of "a2f" as last segment 
	 */
	def protected String getCorrespondingFranca2AutosarTestPath() {
		testPath.replaceFirst("a2f", "f2a")
	}
}

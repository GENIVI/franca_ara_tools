package org.genivi.faracon.tests.util

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.util.Autosar40Factory
import com.google.inject.Inject
import java.util.Collection
import java.util.Collections
import java.util.List
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.IModelContainer
import org.franca.core.franca.FModel
import org.franca.core.franca.FrancaFactory
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.FrancaMultiModelContainer

import static org.genivi.faracon.ARAConnector.*
import static org.genivi.faracon.tests.util.FrancaAraAssertHelper.*
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertNotNull

class ARA2FrancaTestBase {

	@Inject
	protected FrancaPersistenceManager loader

	@Inject
	protected ARAConnector araConnector;

	/**
	 * The Franca Factory as extension, which can be used to create expected tests
	 * models in derived classes.
	 */
	protected extension val FrancaFactory francaFactory = FrancaFactory.eINSTANCE

	/**
	 * The Autosar Factory as extension, which can be used to create expected tests
	 * models in derived classes.
	 */
	protected extension val Autosar40Factory arFactory = Autosar40Factory.eINSTANCE

	def void transformAndCheck(String sourceFilePath, String expectedFilePath) {
		transformAndCheck(sourceFilePath, Collections.singletonList(expectedFilePath))
	}
	
	def void transformAndCheck(String path, String fileBasename, FModel expectedModel) {
		transformAndCheck(loadARAModel(path + fileBasename + ".arxml"), expectedModel)
	}

	def void transformAndCheck(AUTOSAR arModel, String path, String expectedFileName) {
		transformAndCheck(arModel, path + expectedFileName + ".arxml")
	}

	def void transformAndCheck(AUTOSAR arModel, String expectedFilePath) {
		transformAndCheck(arModel, loader.loadModel(expectedFilePath))
	}

	def void transformAndCheck(AUTOSAR arModel, FModel expectedFModel) {
		transformAndCheck(arModel, Collections.singletonList(expectedFModel))
	}
	
	def void transformAndCheck(String sourceFilePath, Collection<String> expectedFilePaths) {
		val expectedFrancaModels = expectedFilePaths.map[loader.loadModel(it);].toList
		val arModel = loadARAModel(sourceFilePath)
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

	/**
	 * Returns the path to the test class, which can be used to load files, which are stored next to the 
	 * class itself. 
	 */
	def protected getTestPath() {
		return "src/" + (this.class.package.name + ".").replace(".", "/") + "/"
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
	
	protected def List<FModel> transformToFranca(IModelContainer arModel) {
		val FrancaMultiModelContainer transformedContainers = araConnector.toFranca(arModel) as FrancaMultiModelContainer
		val francaModels = transformedContainers.francaModelContainers.map[it.model].toList
		francaModels.forEach[loader.saveModel(it, "src-gen/testcases/" + it.name + ".fidl")]
		francaModels
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
}

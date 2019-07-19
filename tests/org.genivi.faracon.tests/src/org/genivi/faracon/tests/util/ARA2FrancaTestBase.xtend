package org.genivi.faracon.tests.util

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.util.Autosar40Factory
import com.google.inject.Inject
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.framework.IModelContainer
import org.franca.core.franca.FModel
import org.franca.core.franca.FrancaFactory
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer

import static org.genivi.faracon.ARAConnector.*
import static org.genivi.faracon.tests.util.FrancaAraAssertHelper.*
import static org.junit.Assert.assertNotNull
import org.genivi.faracon.ARAResourceSet

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


	def void transformAndCheck(String sourceFilePath, String expectedFilePath){
		val FModel expectedFrancaModel = loader.loadModel(expectedFilePath);
		val arModel = loadARAModel(sourceFilePath)
		transformAndCheck(arModel, expectedFrancaModel)
	}
	
	def void transformAndCheck(String path, String fileBasename, FModel expectedModel) {
		transformAndCheck(loadARAModel(path + fileBasename + ".arxml"),expectedModel)
	}

	def void transformAndCheck(AUTOSAR arModel, String path, String expectedFileName){
		transformAndCheck(arModel, path + expectedFileName + ".arxml")
	}
	
	def void transformAndCheck(AUTOSAR arModel, String expectedFilePath){
		transformAndCheck(arModel, loader.loadModel(expectedFilePath))
	}  

	def void transformAndCheck(AUTOSAR arModel, FModel expectedFModel) {
		var ARAResourceSet araResourceSet = arModel?.eResource?.resourceSet as ARAResourceSet
		araResourceSet = if(null == araResourceSet) new ARAResourceSet else araResourceSet
		val autosarModelContainer = new ARAModelContainer(arModel, araResourceSet.standardTypeDefinitionsModel)
		doTransformTest(autosarModelContainer, expectedFModel)
	}

	@SuppressWarnings("restriction")
	def private void doTransformTest(IModelContainer arModel, FModel expectedModel) {
		assertNotNull("The input ARXML model is null", arModel)
		assertNotNull("The expected franca model is null", expectedModel)
		// transform to Franca IDL
		val fmodel = araConnector.toFranca(arModel) as FrancaModelContainer
		loader.saveModel(fmodel.model, "src-gen/testcases/" + expectedModel.name + ".fidl")

		assertModelsAreEqual(fmodel.model, expectedModel)
	}
}

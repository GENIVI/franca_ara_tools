package org.genivi.faracon.tests.aspects_on_file_level.a2f

import java.util.Collections
import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.FrancaMultiModelContainer
import org.genivi.faracon.cli.ConverterCliCommand
import org.genivi.faracon.cli.OutputFileHelper
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull
import static org.junit.Assert.assertNull

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*

/**
 * Tests for the creation of multiple franca output files
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1110_Tests extends ARA2FrancaTestBase {

	@Inject
	var ConverterCliCommand cliCommand

	@Test
	def void testNamespaceHierarchy() {
		//given 
		val autosarInputFileName = this.testPath + "namespacesHierarchy.arxml" 
		
		//when
		val francaModels = transformToFranca(autosarInputFileName)
				
		//then
		val francaModel = francaModels.assertOneElement
		francaModel.assertNamespace("a1.b2.c3")
	}

	@Test
	def void testNamespaceForMultiplePackagesWithElements() {
		//given 
		val autosarInputFileName = testPath + "multiPackagesWithContent.arxml"
		
		//when
		val francaModels = transformToFranca(autosarInputFileName)
				
		//then
		francaModels.assertElements(2).sortBy[name]
		francaModels.get(0).assertNamespace("parentPackage.firstPackageWithContent")
		francaModels.get(1).assertNamespace("parentPackage.secondPackageWithContent")
	}


	@Test
	def void testFrancaFileNameCalculationForSingleInput(){
		// given
		val araModelUri = URI.createFileURI(testPath + "testFileName.arxml")
		val fModel = createFModel =>[name = "testFranca"]
		val fModelContainer = new FrancaMultiModelContainer(Collections.singletonList(fModel))  
		
		// when
		val outputUri = OutputFileHelper.calculateFrancaOutputUri(araModelUri, fModelContainer, fModelContainer.francaModelContainers.get(0))
		
		//then 
		val expectedFrancaUri = URI.createFileURI(testPath + "testFileName.fidl")
		assertEquals("Wrong franca output URI calculated", expectedFrancaUri , outputUri)
	}
	
	@Test
	def void testFrancaFileNameCalculationForMultiInput(){
		// given
		val araModelUri = URI.createFileURI(testPath + "testFileName.arxml")
		val fModel1 = createFModel =>[name = "testFranca1"]
		val fModel2 = createFModel =>[name = "testFranca2"]
		val fModelContainer = new FrancaMultiModelContainer(newArrayList(fModel1, fModel2))  
		
		// when
		val francaUri1 = OutputFileHelper.calculateFrancaOutputUri(araModelUri, fModelContainer, fModelContainer.francaModelContainers.get(0))
		val francaUri2 = OutputFileHelper.calculateFrancaOutputUri(araModelUri, fModelContainer, fModelContainer.francaModelContainers.get(1))
		
		//then
		val expectedFrancaUri1 =  URI.createFileURI(testPath + "testFileName_testFranca1.fidl")
		val expectedFrancaUri2 =  URI.createFileURI(testPath + "testFileName_testFranca2.fidl")
		assertEquals("Wrong franca output URI for first file calculated", expectedFrancaUri1 , francaUri1)
		assertEquals("Wrong franca output URI for second calculated", expectedFrancaUri2 , francaUri2)
	}
	
	@Test
	def void testFrancaFileNameForSingleFileInput(){
		// given
		val araFilePath = newArrayList(testPath + "namespacesHierarchy.arxml")
		
		//when
		cliCommand.convertARAFiles(araFilePath)

		//then
		val fModel = loader.loadModel("namespacesHierarchy")
		assertNotNull("No franca model created", fModel)
	}

	@Test
	def void testFrancaFileNameForMultiFileOutput(){
				// given
		val araFilePath = newArrayList(testPath + "multiPackagesWithContent.arxml")
		
		//when
		cliCommand.convertARAFiles(araFilePath)

		//then
		val nullFModel = loader.loadModel("multiPackagesWithContent")
		assertNull("The franca file with the name multiPackagesWithContent should not have been created", nullFModel)
		val expectedFirstFrancaModel = loader.loadModel( "multiPackagesWithContent_parentPackage.firstPackageWithContent")
		assertNotNull("No franca file with name multiPackagesWithContent_parentPackage.firstPackageWithContent created", expectedFirstFrancaModel)
		val expectedSecondFrancaModel = loader.loadModel("multiPackagesWithContent_parentPackage.secondPackageWithContent")
		assertNotNull("No franca file with name multiPackagesWithContent_parentPackage.secondPackageWithContent created", expectedSecondFrancaModel)
	}

}

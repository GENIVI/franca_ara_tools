package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FModelElement
import org.genivi.faracon.ara2franca.FrancaImportCreator
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertNull

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.junit.Assert.assertNotNull

/**
 * Test mapping of Autosar-Elements to Franca-Elements
 * As the Autosar-metamodel contains lots of Referrable elements, 
 * we only instanciate the ones that are transformed to Franca FModelElements
 * 
 * TODO: Since the ARA to franca transformation is not yet complete, we currently miss creating 
 * the following FModelElements :
 * FMapType, FEnumerationType, FAttribute, FField, FArrayType, FStructType, FUnionType, FTypeDef, FTypeCollection
 *             
 */
@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1460_Tests extends ARA2FrancaTestBase {
	
	@Inject
	var extension FrancaTypeCreator araTypeCreator
	
	@Test
	def void eventConversion() {
		// given
		val event = createVariableDataPrototype
		ara2FrancaTransformation.logger.enableContinueOnErrors(true)
		
		//when
		val result = ara2FrancaTransformation.transform(event)
		
		//then
		assertNotNullAndInstanceOfFModelElement(result)
	}
	
	/**
	 * Test transformation to predefined type, which is not an FModelElement, but needs 
	 * to be tested as well here.
	 */
	@Test
	def void dataTypeConversionToPredefinedType() {
		//given
		val implementationDataType = createImplementationDataType =>[
			category = "VALUE"
			shortName = "UInt32"
		]
		
		//when
		val result = araTypeCreator.createFTypeRefAndImport(implementationDataType, null)
		
		//then
		result.assertNotNull
		assertNull("The derived element is not null, but " + result.derived, result.derived)
		result.predefined.assertIsInstanceOf(FBasicTypeId)
	}

	@Test
	def void methodConversion() {
		//given
		val clientServerOperation = createClientServerOperation
		
		//when
		val result = ara2FrancaTransformation.transform(clientServerOperation)
		
		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void interfaceConversion() {
		//given
		val serviceInterface = createServiceInterface
		
		//when
		val result = ara2FrancaTransformation.transform(serviceInterface)
		
		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	private def assertNotNullAndInstanceOfFModelElement(Object o){
		o.assertNotNull()
		o.assertIsInstanceOf(FModelElement)
	}

}

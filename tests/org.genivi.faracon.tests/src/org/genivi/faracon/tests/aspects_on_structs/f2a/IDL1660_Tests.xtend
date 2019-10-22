package org.genivi.faracon.tests.aspects_on_structs.f2a

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.commonstructure.implementationdatatypes.ImplementationDataTypeElement
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

/**
 * Test cases for flatten Franca Structs
 * «»
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1660_Tests extends AbstractFranca2AraStructTest{
	
	@Test
	def void testUnitFrancaStructToAutosarStruct(){
		//given
		val structName = "TestFStruct"
		val subElementName = "MyUInt32"
		val baseFieldName = "BaseFieldTest"
		val baseStruct = createFStructType =>[
			it.name = "TestBaseStruct"
			it.elements += createFField =>[
				it.name = baseFieldName
				it.type = createFTypeRef =>[
					it.predefined = FBasicTypeId.UINT8
				]
			]
		]
		val fStruct = this.createFStruct(structName, subElementName, baseStruct)
		
		//when
		val type = araTypeCreator.getDataTypeForReference(fStruct)

		//then
		val implementationDatatype = type.assertIsInstanceOf(ImplementationDataType).assertName(structName).assertCategory("STRUCTURE")
		val subElements = implementationDatatype.subElements.assertElements(2).sortBy[shortName]
		subElements.get(0).assertIsInstanceOf(ImplementationDataTypeElement).assertName(baseFieldName).assertCategory("TYPE_REFERENCE")
		subElements.get(1).assertIsInstanceOf(ImplementationDataTypeElement).assertName(subElementName).assertCategory("TYPE_REFERENCE")
	}
	
	@Test
	def void testStructWithBaseStructToAutosarStruct(){
		transformAndCheck(testPath, "structWithBaseStruct", testPath + "structWithBaseStruct.arxml")
	}
	
	@Test
	def void testStructWithBaseStructInNamedTypeCollectionToAutosarStruct(){
		transformAndCheck(testPath, "structWithBaseStructInNamedTypeCollection", testPath + "structWithBaseStructInNamedTypeCollection.arxml")
	}
	
}
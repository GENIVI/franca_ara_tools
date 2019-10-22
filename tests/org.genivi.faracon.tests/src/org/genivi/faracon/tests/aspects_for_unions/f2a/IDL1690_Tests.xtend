package org.genivi.faracon.tests.aspects_for_unions.f2a

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
 * Test cases for flattening Franca unions with inherited base unions.
 * «»
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1690_Tests extends AbstractFranca2AraUnionTest{
	
	@Test
	def void testUnitFrancaUnionWithBaseUnionToAutosarUnion(){
		//given
		val unionName = "TestFUnion"
		val subElementName = "MyUInt32"
		val baseFieldName = "BaseFieldTest"
		val baseUnion = createFUnionType =>[
			it.name = "TestBaseUnion"
			it.elements += createFField =>[
				it.name = baseFieldName
				it.type = createFTypeRef =>[
					it.predefined = FBasicTypeId.UINT8
				]
			]
		]
		val fUnion = this.createFUnion(unionName, subElementName, baseUnion)
		
		//when
		val type = araTypeCreator.getDataTypeForReference(fUnion)

		//then
		val implementationDatatype = type.assertIsInstanceOf(ImplementationDataType).assertName(unionName).assertCategory("UNION")
		val subElements = implementationDatatype.subElements.assertElements(2).sortBy[shortName]
		subElements.get(0).assertIsInstanceOf(ImplementationDataTypeElement).assertName(baseFieldName).assertCategory("TYPE_REFERENCE")
		subElements.get(1).assertIsInstanceOf(ImplementationDataTypeElement).assertName(subElementName).assertCategory("TYPE_REFERENCE")
	}
	
	@Test
	def void testUnionWithBaseUnionToAutosarUnion(){
		transformAndCheck(testPath, "unionWithBaseUnion", testPath + "unionWithBaseUnion.arxml")
	}
	
	@Test
	def void testUnionWithBaseUnionInNamedTypeCollectionToAutosarUnion(){
		transformAndCheck(testPath, "unionWithBaseUnionInNamedTypeCollection", testPath + "unionWithBaseUnionInNamedTypeCollection.arxml")
	}
	
}
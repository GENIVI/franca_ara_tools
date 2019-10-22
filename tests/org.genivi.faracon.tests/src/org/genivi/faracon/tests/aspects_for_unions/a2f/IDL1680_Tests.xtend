package org.genivi.faracon.tests.aspects_for_unions.a2f

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FField
import org.franca.core.franca.FUnionType
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*

/**
 * Test transformation of Autosar implementation data type with category 
 * UNION to Franca union type. «» 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1680_Tests extends ARA2FrancaTestBase {

	@Inject
	var FrancaTypeCreator francaTypeCreator

	@Test
	def void testSimpleUnion() {
		// given
		val testUnionName = "TestArUnion"
		val autosarUnion = createImplementationDataType => [
			shortName = testUnionName
			category = "UNION"
		]

		// when
		val result = francaTypeCreator.transform(autosarUnion)

		// then
		result.assertIsInstanceOf(FUnionType)
		result.assertName(testUnionName)
	}

	@Test
	def void testUnionWithContent() {
		// given
		val testUnionName = "TestArUnion"
		val subElement1 = createImplementationDataTypeElement => [
			shortName = "MyUInt8"
			category = "TYPE_REFERENCE"
			swDataDefProps = createSwDataDefProps => [
				swDataDefPropsVariants += createSwDataDefPropsConditional => [
					it.implementationDataType = createImplementationDataType => [
						it.category = "VALUE"
						it.shortName = "UInt8"
					]
				]
			]
		]
		val subElement2 = createImplementationDataTypeElement => [
			shortName = "MyUInt16"
			category = "TYPE_REFERENCE"
			swDataDefProps = createSwDataDefProps => [
				swDataDefPropsVariants += createSwDataDefPropsConditional => [
					it.implementationDataType = createImplementationDataType => [
						it.category = "VALUE"
						it.shortName = "UInt16"
					]
				]
			]
		]
		val autosarUnion = createImplementationDataType => [
			shortName = testUnionName
			category = "UNION"
			subElements += subElement1
			subElements += subElement2
		]

		// when
		val result = francaTypeCreator.transform(autosarUnion)

		// then
		val unionType = result.assertType(FUnionType, "TestArUnion")
		val elements = unionType.elements.assertElements(2).sortBy[name]
		elements.get(0).assertFTypedElement(FField, "MyUInt16", false, false, FBasicTypeId.UINT16)
		elements.get(1).assertFTypedElement(FField, "MyUInt8", false, false, FBasicTypeId.UINT8)
	}
	
	@Test
	def void testSingleUnionInArxmlFile(){
		transformAndCheck(testPath + "singleUnionTest.arxml", testPath + "singleUnionTest.fidl")
	}
	
	@Test
	def void testMultipleUnionsInArxmlFile(){
		transformAndCheck(testPath + "multipleUnionsTest.arxml", testPath + "multipleUnionsTest.fidl")
	}
	
	@Test
	def void testUnionAndInterfaceInArxmlFile(){
		transformAndCheck(testPath + "unionAndInterfaceInPackageTest.arxml", testPath + "unionAndInterfaceInPackage.fidl")
	}
	
}

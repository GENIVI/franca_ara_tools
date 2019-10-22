package org.genivi.faracon.tests.aspects_on_structs.a2f

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FStructType
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*
import org.franca.core.franca.FField
import org.franca.core.franca.FBasicTypeId
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum

/**
 * Test transformation of Autosar implementation data type with category 
 * STRUCTURE to franca struct type. «»
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1650_Tests extends ARA2FrancaTestBase {

	@Inject
	var FrancaTypeCreator francaTypeCreator

	@Test
	def void testSimpleStruct() {
		// given
		val testStructName = "TestArStruct"
		val autosarStruct = createImplementationDataType => [
			shortName = testStructName
			category = "STRUCTURE"
		]

		// when
		val result = francaTypeCreator.transform(autosarStruct)

		// then
		result.assertIsInstanceOf(FStructType)
		result.assertName(testStructName)
	}

	@Test
	def void testStructWithContent() {
		// given
		val testStructName = "TestArStruct"
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
		val autosarStruct = createImplementationDataType => [
			shortName = testStructName
			category = "STRUCTURE"
			subElements += subElement1
			subElements += subElement2
		]

		// when
		val result = francaTypeCreator.transform(autosarStruct)

		// then
		val structType = result.assertType(FStructType, "TestArStruct")
		val elements = structType.elements.assertElements(2).sortBy[name]
		elements.get(0).assertFTypedElement(FField, "MyUInt16", false, false, FBasicTypeId.UINT16)
		elements.get(1).assertFTypedElement(FField, "MyUInt8", false, false, FBasicTypeId.UINT8)
	}
	
	@Test
	def void testSingleStructInArxmlFile(){
		transformAndCheck(testPath + "singleStructTest.arxml", testPath + "singleStructTest.fidl")
	}
	
	@Test
	def void testMultipleStructsInArxmlFile(){
		transformAndCheck(testPath + "multipleStructTest.arxml", testPath + "multipleStructTest.fidl")
	}
	
	@Test
	def void testStructAndInterfaceInArxmlFile(){
		transformAndCheck(testPath + "structAndInterfaceInPackageTest.arxml", testPath + "structAndInterfaceInPackage.fidl")
	}
	
}

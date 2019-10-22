package org.genivi.faracon.tests.aspects_for_unions.f2a

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.commonstructure.implementationdatatypes.ImplementationDataTypeElement
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

/**
 * Test cases for testing the conversion of Franca unions to AUTOSAR unions.
 * «»
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1680_Tests extends AbstractFranca2AraUnionTest {
	
	@Test
	def void testUnitFrancaUnionToAutosarUnion() {
		//given
		val unionName = "TestFUnion"
		val subElementName = "MyUInt32"
		val fUnion = createFUnion(unionName, subElementName, null)
		
		//when
		val type = araTypeCreator.getDataTypeForReference(fUnion)

		//then
		val implementationDatatype = type.assertIsInstanceOf(ImplementationDataType).assertName(unionName).assertCategory("UNION")
		val subElement = implementationDatatype.subElements.assertOneElement.assertIsInstanceOf(ImplementationDataTypeElement).assertName(subElementName)
		subElement.assertCategory("TYPE_REFERENCE")
	}
	
	@Test
	def void testSingleFrancaUnionToAutosarUnion() {
		val path = "src/org/genivi/faracon/tests/aspects_for_unions/a2f/"
		transformAndCheck(path, "singleUnionTest", path + "singleUnionTest.arxml")
	}
	
	@Test
	def void testMultipleFrancaUnionsToAutosarUnions() {
		val path = "src/org/genivi/faracon/tests/aspects_for_unions/a2f/"
		transformAndCheck(path, "multipleUnionsTest", path + "multipleUnionsTest.arxml")
	}
	
	@Test
	def void testUnionAndInterfaceInPackage() {
		val path = "src/org/genivi/faracon/tests/aspects_for_unions/a2f/"
		transformAndCheck(path, "unionAndInterfaceInPackage", path + "unionAndInterfaceInPackageTest.arxml")
	}
}

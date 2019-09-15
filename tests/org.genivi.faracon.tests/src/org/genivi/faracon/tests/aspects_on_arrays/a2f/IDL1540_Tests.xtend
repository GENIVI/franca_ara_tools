package org.genivi.faracon.tests.aspects_on_arrays.a2f

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertTrue

/**
 * Tests Events to Broadcasts
 * Also covers IDL 1370 and IDL1380 for Autosar to Franca.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1540_Tests extends ARA2FrancaTestBase {

	@Test
	def void testArrayTransformation() {
		transformAndCheck(testPath + "arrayTest.arxml", testPath + "arrayTest.fidl")
	}

	@Test
	def void testArrayUsageTransformation() {
		transformAndCheck(testPath + "arrayUsage.arxml", testPath + "arrayUsage.fidl")
	}

	@Test
	def void testStdTypesVector() {
		// given
		val vectors = new ARAResourceSet().araStandardTypeDefinitionsModel.standardVectorTypeDefinitionsModel
		val uint32Vector = vectors.eAllContents.filter(ImplementationDataType).findFirst[shortName == "UInt32Vector"]
		val argument = createArgumentDataPrototype => [
			it.shortName = "TestArgument"
			it.type = uint32Vector
			it.direction = ArgumentDirectionEnum.IN
		]

		// when
		val resultingArgument= argument.transform

		// then
		assertTrue("Input argument was expected to be an array", resultingArgument.array)
		assertEquals("Argument was expected to be UInt32", FBasicTypeId.UINT32, resultingArgument.type.predefined)
	}
	
	@Test
	def void testStdTypesVecotrUsage(){
		transformAndCheck(testPath + "stdVectorTypeUsage.arxml", testPath + "stdVectorTypeUsage.fidl")
	}

}

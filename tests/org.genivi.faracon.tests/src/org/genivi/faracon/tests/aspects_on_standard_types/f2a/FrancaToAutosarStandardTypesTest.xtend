package org.genivi.faracon.tests.aspects_on_standard_types.f2a

import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertTrue
import org.junit.After

/**
 * Covers tests for standard types.
 * It covers the following IDLs:
 * 2620,2630,2640,2650,2660,2670,2680,2690,2700,2710,2720,2730,2740,2750,2760 
 * 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class FrancaToAutosarStandardTypesTest extends Franca2ARATestBase {

	@Inject
	var extension ARATypeCreator

	@After
	def void afterTest(){
		logger.enableContinueOnErrors(false)
	}

	@Test
	def void testFrancaBaseTypes() {
		// given: all primitve types except byte buffer
		val francaBasicTypeUsages = FBasicTypeId.VALUES.filter [
			it !== FBasicTypeId.UNDEFINED && it != FBasicTypeId.BYTE_BUFFER
		].map [ basicType |
			createFAttribute => [
				it.type = createFTypeRef => [
					it.predefined = basicType
				]
			]
		]

		// when
		val araTypes = francaBasicTypeUsages.map [
			it.type.createDataTypeReference(it)
		].toList

		// then
		val francaTypesMap = francaBasicTypeUsages.map[it.type].toMap[it.predefined.getName]
		assertEquals("Differnt number for franca and ara types found", francaTypesMap.size, araTypes.size)
		araTypes.forEach [
			assertTrue("No franca type found for Autosar type " + shortName, francaTypesMap.containsKey(shortName))
			val francaType = francaTypesMap.get(shortName)
			assertEquals("Franca type and Autosar type need to have equal name", francaType.predefined.getName,
				shortName)

		]
	}

	@Test(expected=AbstractLogger.StopOnErrorException)
	def void testFrancaByteBuffer() {
		testFrancaByteBufferTransformation()
	// then: expect the error
	}

	@Test
	def void testFrancaByteBufferContinueOnError() {
		logger.enableContinueOnErrors(true)

		val araType = testFrancaByteBufferTransformation

		// then: expect vector type usage
		assertEquals("ByteVectorType was expected for the Franca Type ByteBuffer", "ByteVectorType", araType.shortName)

	}

	private def AutosarDataType testFrancaByteBufferTransformation() {
		val francaByteBufferUsage = createFAttribute => [
			it.type = createFTypeRef => [
				it.predefined = FBasicTypeId.BYTE_BUFFER
			]
		]

		// when 
		return francaByteBufferUsage.type.createDataTypeReference(francaByteBufferUsage)
	}

}

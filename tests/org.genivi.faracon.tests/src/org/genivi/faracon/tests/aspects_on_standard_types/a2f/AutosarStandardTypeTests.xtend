package org.genivi.faracon.tests.aspects_on_standard_types.a2f

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FArgument
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertTrue

/**
 * Covers tests for standard types.
 * It covers the following IDLs:
 * 2620,2630,2640,2650,2660,2670,2680,2690,2700,2710,2720,2730,2740,2750,2760 
 * 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class AutosarStandardTypeTests extends ARA2FrancaTestBase {

	/**Transforms all types in the stdtypes.arxml to franca and ensures that no error occurs */
	@Test
	def void testUnitAutosarStdTypesMethodApErrors() {
		// given 
		val autosarStdTypes = stdImplementationTypes
		val autosarStdTypesContaiment = autosarStdTypes.map [ stdType |
			createArgumentDataPrototype => [
				it.shortName = "TestArgument"
				it.type = stdType
			]
		]

		// when 
		val francaPrimitivesUsages = autosarStdTypesContaiment.map [
			it.transform
		].toList

		// then 
		assertEquals("Not all primitive types have been transformed correctly", francaPrimitivesUsages.size,
			autosarStdTypes.size)
		val francaPrimitivesMap = francaPrimitivesUsages.toMap [
			val typeName = getTypeName(it)
			it.isArray + typeName
		]
		autosarStdTypes.forEach [
			val autosarName = it.shortName
			if (autosarName == "ByteVectorType" || autosarName == "ByteArray") {
				assertTrue("No franca type created for autosar type with name " + autosarName,
					francaPrimitivesMap.containsKey(true + FBasicTypeId.UINT8.getName))
			} else {
				assertTrue("No franca type created for autosar type with name " + autosarName + " created types are " +
					francaPrimitivesMap.values, francaPrimitivesMap.containsKey(false + autosarName))
				val francaPrimitive = francaPrimitivesMap.get(false + autosarName)
				val francaName = francaPrimitive.typeName
				assertEquals("The Franca primitive type name does not equal the Autosar primitive type name",
					francaName, autosarName)
			}
		]
	}

	private def String getTypeName(FArgument it) {
		if (it.type.derived === null) {
			return it.type.predefined.getName
		} else {
			return it.type.derived.name
		}
	}

	def private getStdImplementationTypes() {
		val araResourceSet = new ARAResourceSet
		val stdTypesResource = araResourceSet.resources.get(0)
		assertTrue("Assertion error: expected to find std-Types resource, but found resource: " + stdTypesResource.URI,
			stdTypesResource.URI.toString.contains("stdtypes.arxml"))
		val stdImplementationDataTypes = stdTypesResource.contents.get(0).eAllContents.filter(ImplementationDataType)
		assertFalse("Assertion error: No stdTypes found ", stdImplementationDataTypes.empty)
		return stdImplementationDataTypes.toList
	}

}

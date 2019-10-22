package org.genivi.faracon.tests.aspects_on_arrays.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests the transformation of anonymous array types from Franca to AUTOSAR.
 * «»
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1620_Tests extends Franca2ARATestBase {

	@Test
	def void simpleAnonymousArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["simpleAnonymousArrayType"],
			#[testPath + "simpleAnonymousArrayType.arxml"],
			"simpleAnonymousArrayType")
	}

	@Test
	def void complexAnonymousArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["complexAnonymousArrayType"],
			#[testPath + "complexAnonymousArrayType.arxml"],
			"complexAnonymousArrayType")
	}

	@Test
	def void anonymousArrayTypesWithImport() {
		transformAndCheckIntegrationTest(testPath,
			#["anonymousArrayTypesWithImport",
			  "commonTypesForAnonymousArrayTypes"],
			#[testPath + "anonymousArrayTypesWithImport.arxml",
			  testPath + "commonTypesForAnonymousArrayTypes.arxml"],
			"anonymousArrayTypesWithImport")
	}

	@Test
	def void multipleAnonymousArrayTypesUsingTheSameElementType() {
		transformAndCheckIntegrationTest(testPath,
			#["anonymousArrayTypesWithImport",
			  "furtherAnonymousArrayTypeWithImport",
			  "commonTypesForAnonymousArrayTypes"],
			#[testPath + "anonymousArrayTypesWithImport.arxml",
			  testPath + "furtherAnonymousArrayTypeWithImport.arxml",
			  testPath + "commonTypesForAnonymousArrayTypes.arxml"],
			"multipleAnonymousArrayTypesUsingTheSameElementType")
	}

	@Test
	def void anonymousArrayTypesWithElementsTypesFromDifferentNamespaces() {
		transformAndCheckIntegrationTest(testPath,
			#["anonymousArrayTypesWithElementsTypesFromDifferentNamespaces",
			  "commonTypesForNamedArrayTypes",
			  "commonTypes2ForNamedArrayTypes"],
			#[testPath + "anonymousArrayTypesWithElementsTypesFromDifferentNamespaces.arxml",
			  testPath + "commonTypesForNamedArrayTypes.arxml",
			  testPath + "commonTypes2ForNamedArrayTypes.arxml"],
			"anonymousArrayTypesWithElementsTypesFromDifferentNamespaces")
	}

}

package org.genivi.faracon.tests.util

import java.util.Collection
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.franca.FModel

import static org.junit.Assert.assertEquals
import static org.junit.Assert.fail

/**
 * Assertion helper for the faracon test, which contains all general 
 * assertions that can be used for both directions: ara 2 franca and franca to ara.
 */
class FaraconAssertHelper {

	private new() {
	}

	def static void assertFrancaModelsAreEqual(Collection<FModel> francaModels,
		Collection<FModel> expectedFrancaModel) {
		assertEquals("Expected collection and actual collection of franca models need to have the same size.",
			expectedFrancaModel.size, francaModels.size)
		val sortedActual = francaModels.sortBy[it.name]
		val sortedExpected = expectedFrancaModel.sortBy[it.name]
		for (var i = 0; i < sortedExpected.size; i++) {
			assertModelsAreEqual(sortedActual.get(i), sortedExpected.get(i))
		}
	}

	def static void assertModelsAreEqual(EObject actualModel, EObject expectedModel) {
		if (!EcoreUtil.equals(actualModel, expectedModel)) {
			// for now, we just fail without giving a hint why --> todo: improve that
			fail("The expected model does not equal the actual model")
		}
	}
	
	def static <T> T assertOneElement(Collection<T> elements){
		return elements.assertElements(1).get(0)
	}
	
	def static <T> Collection<T> assertElements(Collection<T> elements, int expectedElements){
		assertEquals("Wrong number of expected elements in collection " + elements, expectedElements, elements.size)
		return elements
	} 
}

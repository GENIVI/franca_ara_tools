package org.genivi.faracon.tests.util

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil

import static org.junit.Assert.fail

class FrancaAraAssertHelper {
	
	private new(){}
	
	def static void assertModelsAreEqual(EObject actualModel, EObject expectedModel) {
		if (!EcoreUtil.equals(actualModel, expectedModel)) {
			// for now, we just fail without giving a hint why --> todo: improve that
			fail("The expected model does not equal the actual model")
		}
	}
}
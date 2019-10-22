package org.genivi.faracon.tests.aspects_for_franca_ftyperef.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the translation of instances of the Franca metaclass 'FTypeRef'
 * that point to user-defined complex types.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1810_Tests extends Franca2ARATestBase {

	@Test
	def void userDefinedTypeMethodArguments() {	
		transformAndCheck(testPath, "userDefinedTypeMethodArguments", correspondingAutosar2FrancaTestPath + "userDefinedTypeMethodArguments.arxml");
	}

	@Test
	def void userDefinedTypeStructFields() {	
		transformAndCheck(testPath, "userDefinedTypeStructFields", testPath + "userDefinedTypeStructFields.arxml");
	}

}

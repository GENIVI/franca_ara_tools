package org.genivi.faracon.tests.aspects_on_file_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith
import static org.junit.Assert.fail
import static extension org.genivi.faracon.tests.util.AssertHelper.*
import static org.junit.Assert.assertEquals

@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1100_Tests extends ARA2FrancaTestBase {
	
	@Test
	def void testSingleArPackage() {
		// given
		val inputFilePath = testPath + "singlePackage.arxml"
		
		// when
		val francaModels = inputFilePath.transformToFranca()
		
		//then
		val francaModel = francaModels.assertOneElement
		assertEquals("Wrong franca namespace created", "empty_namespace", francaModel.name)
		
	}
}

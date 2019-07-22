package org.genivi.faracon.tests.aspects_on_file_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.AssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*

@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1110_Tests extends ARA2FrancaTestBase {

	@Test
	def void testNamespaceHierarchy() {
		//given 
		val autosarInputFileName = this.testPath + "namespacesHierarchy.arxml" 
		
		//when
		val francaModels = transformToFranca(autosarInputFileName)
				
		//then
		val francaModel = francaModels.assertOneElement
		francaModel.assertNamespace("a1.b2.c3")
	}

	@Test
	def void testNamespaceForMultiplePackagesWithElements() {
		//given 
		val autosarInputFileName = testPath + "multiPackagesWithContent.arxml"
		
		//when
		val francaModels = transformToFranca(autosarInputFileName)
				
		//then
		francaModels.assertElements(2).sortBy[name]
		francaModels.get(0).assertNamespace("parentPackage.firstPackageWithContent")
		francaModels.get(1).assertNamespace("parentPackage.secondPackageWithContent")
	}

}

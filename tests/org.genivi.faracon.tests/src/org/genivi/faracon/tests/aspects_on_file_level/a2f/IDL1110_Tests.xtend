package org.genivi.faracon.tests.aspects_on_file_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAResourceSet

@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1110_Tests extends ARA2FrancaTestBase {

	@Test 
	def void testNamespaceHierarchy() {
		val autosar = createAUTOSAR => [
			arPackages += createARPackage =>[
				shortName = "a"
				arPackages += createARPackage => [
					shortName = "b"
					arPackages += createARPackage => [shortName = "c"]
				]
			]
		]
		saveAraFile(autosar, testPath+ "namespaceHierarchy.arxml" )
		
	}
}

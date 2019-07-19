package org.genivi.faracon.tests.aspects_on_file_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.framework.FrancaModelContainer
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1120_Tests extends ARA2FrancaTestBase {

	@Test(expected=AbstractLogger.StopOnErrorException)
	def void testNamespaceLeadsToWarning() {
		// given
		val araContainer = createAutosarModelWithNamespace()

		// when
		araConnector.toFranca(araContainer) as FrancaModelContainer

		// then expect the exception through the expect parameter in the annotation
	}

	private def createAutosarModelWithNamespace() {
		val autosarFileWithNamespace = createAUTOSAR => [
			arPackages += createARPackage => [
				it.shortName = "arPackage"
				elements += createServiceInterface => [
					it.shortName = "InterfaceWithNamespace"
					it.namespaces += createSymbolProps => [
						it.shortName = "my.name.space"
					]
				]
			]
		]
		val araContainer = new ARAModelContainer(autosarFileWithNamespace,
			new ARAResourceSet().standardTypeDefinitionsModel)
		return araContainer
	}
}

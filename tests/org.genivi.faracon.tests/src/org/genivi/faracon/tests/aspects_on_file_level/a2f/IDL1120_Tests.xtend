package org.genivi.faracon.tests.aspects_on_file_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.framework.FrancaModelContainer
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.FrancaMultiModelContainer
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

/**
 * Tests that a Namespace from Autosar is either correct transformed to franca
 * or throws an error if it is wrong
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1120_Tests extends ARA2FrancaTestBase {

	@Test(expected=AbstractLogger.StopOnErrorException)
	def void testNamespaceLeadsToWarning() {
		// given
		val araContainer = createAutosarModelWithNamespace("my.wrong.namespace")

		// when
		araConnector.toFranca(araContainer) as FrancaModelContainer

		// then expect the exception through the expect parameter in the annotation
	}

	@Test
	def void testNamespaceMatching() {
		// given
		val elementNamespace = "arPackage.serviceInterfacePackage"
		val araContainer = createAutosarModelWithNamespace(elementNamespace)

		// when
		val francaModelContainer = araConnector.toFranca(araContainer) as FrancaMultiModelContainer

		// then
		val francaModel = francaModelContainer.francaModelContainers.assertOneElement.model
		assertEquals("Wrong franca namespace created", elementNamespace, francaModel.name)
	}

	private def createAutosarModelWithNamespace(String namespace) {
		val symbolProps = namespace.split("\\.").map [ name |
			createSymbolProps => [
				it.shortName = name
				it.symbol = name
			]
		]
		val autosarFileWithNamespace = createAUTOSAR => [
			arPackages += createARPackage => [
				it.shortName = "arPackage"
				arPackages += createARPackage => [
					it.shortName = "serviceInterfacePackage"
					elements += createServiceInterface => [
						it.shortName = "InterfaceWithNamespace"
						it.namespaces += symbolProps
					]
				]
			]
		]
		val araContainer = new ARAModelContainer(autosarFileWithNamespace,
			new ARAResourceSet().araStandardTypeDefinitionsModel)
		return araContainer
	}
}

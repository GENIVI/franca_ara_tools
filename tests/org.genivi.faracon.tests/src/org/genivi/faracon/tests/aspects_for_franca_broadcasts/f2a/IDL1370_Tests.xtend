package org.genivi.faracon.tests.aspects_for_franca_broadcasts.f2a

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.genivi.faracon.Franca2ARATransformation
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertNotNull

/**
 * Test cases for testing that a Franca broadcast 'FBroadcast' is converted into an AUTOSAR object of the metatype 'VariableDataPrototype'.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1370_Tests extends Franca2ARATestBase {

	@Inject
	var Franca2ARATransformation franca2ARATransformation

	@Test
	def void broadcastConversion() {
		val FBroadcast fBroadcast = francaFac.createFBroadcast
		val FInterface fParentInterface = francaFac.createFInterface => [
			broadcasts += fBroadcast
		]
		val ARPackage arInterfacePackage = araFac.createARPackage
		val VariableDataPrototype variableDataPrototype = franca2ARATransformation.transform(fBroadcast, fParentInterface, arInterfacePackage)
		assertNotNull(variableDataPrototype)
	}

}

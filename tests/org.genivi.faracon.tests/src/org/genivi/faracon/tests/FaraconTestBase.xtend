package org.genivi.faracon.tests

import autosar40.util.Autosar40Factory
import javax.inject.Inject
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.franca.FrancaFactory
import org.genivi.faracon.ARAConnector

/**
 * This is the abstract base class for all tests in the Faracon tool.
 * It contains common members and methods, which are needed for the tests. 
 */
abstract class FaraconTestBase {
	
	@Inject
	protected FrancaPersistenceManager loader

	@Inject
	protected ARAConnector araConnector;

	/**
	 * The Franca Factory as extension, which can be used to create expected tests
	 * models in derived classes.
	 */
	protected extension val FrancaFactory francaFactory = FrancaFactory.eINSTANCE

	/**
	 * The Autosar Factory as extension, which can be used to create expected tests
	 * models in derived classes.
	 */
	protected extension val Autosar40Factory arFactory = Autosar40Factory.eINSTANCE
	
	def protected francaFac() {
		return francaFactory
	}

	def protected araFac() {
		return arFactory
	}
	
	/**
	 * Returns the path to the test class, which can be used to load files, which are stored next to the 
	 * class itself. 
	 */
	def protected getTestPath() {
		return "src/" + (this.class.package.name + ".").replace(".", "/")
	}
}
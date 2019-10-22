package org.genivi.faracon.tests.aspects_for_franca_broadcasts.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the conversion of the set of arguments of a Franca broadcast.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1380_Tests extends Franca2ARATestBase {

	static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_for_franca_broadcasts/f2a/"

	@Test
	def void broadcastWithoutArguments() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastWithoutArguments")
	}

	@Test
	def void broadcastWithOneArgument() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastWithOneArgument")
	}

	@Test
	def void broadcastWithMultipleArguments() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastWithMultipleArguments")
	}

	@Test
	def void broadcastConflictWithUserStruct() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastConflictWithUserStruct")
	}

	@Test
	def void broadcastDoubleConflictWithUserStructs() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastDoubleConflictWithUserStructs")
	}

	@Test
	def void broadcastConflictWithUserEnum() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastConflictWithUserEnum")
	}

	@Test
	def void broadcastNonConflictWithIdenticallyNamedMethod() {
		transformAndCheck(LOCAL_FRANCA_MODELS, "broadcastNonConflictWithIdenticallyNamedMethod")
	}

}

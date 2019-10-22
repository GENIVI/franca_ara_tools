package org.genivi.faracon.tests.aspects_on_structs.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.logging.AbstractLogger.StopOnErrorException
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for polymorphic struct hierarchies
 * «»
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1670_Tests extends AbstractFranca2AraStructTest{
	
	@Test(expected = StopOnErrorException)
	def void testPolymorphicStructHierarchy(){
		//given
		val structName = "TestFStruct"
		val subElementName = "MyUInt32"
		val fStruct = this.createFStruct(structName, subElementName, null)
		fStruct.polymorphic = true
		
		//when
		araTypeCreator.getDataTypeForReference(fStruct)

		//then expect the error
	}
	
}
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
class IDL1140_Tests extends ARA2FrancaTestBase {
	
	@Test 
	def void testSingleDataType() {
		// given
		val arModel = createAUTOSAR => [
			arPackages += createARPackage =>[
				shortName = "firstPackage"
				arPackages += createARPackage =>[
					shortName = "secondPackage"
					elements += createImplementationDataType =>[
						shortName = "DataType1"
					]
				]
			]
		]	
		
		// when
		val francaModels = transformToFranca(arModel)

		//then
		val francaModel = francaModels.assertOneElement
	    francaModel.assertNamespace("firstPackage.secondPackage")
	}

	@Test 
	def void testMultiDataTypesInSamePackage() {
		// given
		val arModel = createAUTOSAR => [
			arPackages += createARPackage =>[
				shortName = "firstPackage"
				arPackages += createARPackage =>[
					shortName = "secondPackage"
					elements += createImplementationDataType =>[
						shortName = "DataType1"
					]
					elements += createImplementationDataType =>[
						shortName = "DataType2"
					]
				]
			]
		]	
		
		// when
		val francaModels = transformToFranca(arModel)

		//then
		val francaModel = francaModels.assertOneElement
	    francaModel.assertNamespace("firstPackage.secondPackage")
	}

	@Test 
	def void testMutliDataTypesInDifferentPackages() {
		//given
		val arModel = createAUTOSAR => [
			arPackages += createARPackage =>[
				shortName = "firstPackage"
				arPackages += createARPackage =>[
					shortName = "secondPackage"
					elements += createImplementationDataType =>[
						shortName = "DataType1"
					]
					elements += createImplementationDataType =>[
						shortName = "DataType2"
					]
				]
				arPackages += createARPackage =>[
					shortName = "thirdPackage"
					elements += createImplementationDataType =>[
						shortName = "DataType3"
					]
					elements += createImplementationDataType =>[
						shortName = "DataType4"
					]
				]
			]
		]

		// when
		val francaModels = transformToFranca(arModel)

		//then
		francaModels.assertElements(2).sortBy[name]
	    francaModels.get(0).assertNamespace("firstPackage.secondPackage")
	    francaModels.get(1).assertNamespace("firstPackage.thirdPackage")
	}
}

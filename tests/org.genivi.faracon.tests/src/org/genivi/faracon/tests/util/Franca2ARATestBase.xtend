package org.genivi.faracon.tests.util

import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.tests.FaraconTestBase

import static org.junit.Assert.assertNotNull

abstract class Franca2ARATestBase extends FaraconTestBase {

	def void transform(String path, String fileBasename) {
		doTransformTest(path, fileBasename, false)
	}

	def void transformAndCheck(String path, String fileBasename) {
		doTransformTest(path, fileBasename, true)
	}

	@SuppressWarnings("restriction")
	def private void doTransformTest(String path, String fileBasename, boolean check) {
		// load example Franca IDL interface
		val inputfile = path + fileBasename + ".fidl"
		println("Loading Franca file " + inputfile + " ...")
		val fmodel = loader.loadModel(inputfile)
		assertNotNull(fmodel)
		
		// transform to arxml
		val fromFranca = araConnector.fromFranca(fmodel) as ARAModelContainer
		araConnector.saveModel(fromFranca, "src-gen/testcases/" + fileBasename + ".arxml")
		
		// transform to Franca IDL
//		val fmodel2 = araConnector.toFranca(fromFranca) as FrancaModelContainer
//		loader.saveModel(fmodel2.model, "src-gen/testcases/" + fileBasename + ".fidl")

		if (check) {
			// load reference arxml file
			val referenceFile = "model/reference/" + fileBasename + ".arxml"
	// TODO: implement comparison against ref model
//			val ref = conn.loadModel(referenceFile) as ARAModelContainer
			
			// compare with reference file
//			val rset1 = fromFranca.model.eResource.resourceSet
//			val rset2 = ref.model.eResource.resourceSet
//	
//			val IComparisonScope scope = EMFCompare.createDefaultScope(rset1, rset2)
//			val Comparison comparison = EMFCompare.builder.build.compare(scope)
//			 
//			val List<Diff> differences = comparison.getDifferences
//			val nDiffs = 0
//			for(Diff diff : differences) {
//				if (! (diff instanceof ResourceAttachmentChangeSpec)) {
//					println(diff.toString);
//					nDiffs++
//				}
//			}
//			assertEquals(0, nDiffs)
		}
	}

}

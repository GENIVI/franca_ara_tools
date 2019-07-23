package org.genivi.faracon.cli

import org.genivi.faracon.FrancaMultiModelContainer
import org.eclipse.emf.common.util.URI
import org.franca.core.framework.FrancaModelContainer

class OutputFileHelper {
	private new(){}
	 
	def static calculateFrancaOutputUri(URI araModelUri, FrancaMultiModelContainer fmodel,
			FrancaModelContainer francaModelContainer){
		var transformedModelUri = araModelUri.trimFileExtension();
		if (fmodel.getFrancaModelContainers().size() > 1) {
			// if we created more than one Franca file, we use the origin file name and the
			// franca model name as file name as we need to create multiple files and cannot
			// use the input file with ".fidl" as extension
			val modelName = francaModelContainer.model().getName();
			val araFileName = transformedModelUri.lastSegment();
			val francaFileName = araFileName + "_" + modelName;
			transformedModelUri = transformedModelUri.trimSegments(1)
					.appendSegment(francaFileName);
		}
		transformedModelUri = transformedModelUri.appendFileExtension("fidl");
		return transformedModelUri;
	}
}
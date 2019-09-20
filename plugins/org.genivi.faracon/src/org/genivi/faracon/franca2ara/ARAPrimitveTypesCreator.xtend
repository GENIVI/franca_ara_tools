package org.genivi.faracon.franca2ara

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.HashMap
import javax.inject.Singleton
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.Franca2ARABase

@Singleton
class ARAPrimitveTypesCreator extends Franca2ARABase {

	val nameToType = new HashMap<String, ImplementationDataType>()
	
	def ARPackage createPrimitiveTypesPackage(ARAResourceSet araResourceSet) {
		val ARAResourceSet araResourceSetLocal = 
			if (araResourceSet === null) new ARAResourceSet() else araResourceSet
		val AUTOSAR primitiveTypesModel = araResourceSetLocal.araStandardTypeDefinitionsModel.standardTypeDefinitionsModel
		val topLevelPackage = primitiveTypesModel.arPackages.get(0)
		primitiveTypesModel.eAllContents.filter(ImplementationDataType).forEach[
			nameToType.put(it.shortName,it)
		]
		return topLevelPackage
	}

	def getBaseTypeForReference(FBasicTypeId fBasicTypeId) {
		createPrimitiveTypesPackage(null)
		if(!this.nameToType.containsKey(fBasicTypeId.getName)){
			getLogger.logError("Can not find an AUTOSAR simple type for the FBasicTypeId: " + fBasicTypeId?.getName + "! (IDL2620)")
		}
		if(fBasicTypeId == FBasicTypeId.BYTE_BUFFER){
			logger.logError('''Cannot convert Franca ByteBuffer to an Autosar simple type.''')
			return this.nameToType.get("ByteVectorType")
		}
		this.nameToType.get(fBasicTypeId.getName)
	}

	// TODO: This predicate function does not work properly with the current implementation
	//       because the primitive types library is loaded twice.
	def isPrimitiveType(ImplementationDataType implementationDataType) {
		val lookupImplementationDataType = nameToType.get(implementationDataType.shortName)
		return lookupImplementationDataType !== null && lookupImplementationDataType === implementationDataType
	}

}

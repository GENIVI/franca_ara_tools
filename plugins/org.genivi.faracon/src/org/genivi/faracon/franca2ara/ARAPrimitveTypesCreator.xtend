package org.genivi.faracon.franca2ara

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import com.google.inject.Inject
import java.util.Map
import javax.inject.Singleton
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.util.AutosarUtil

@Singleton
class ARAPrimitveTypesCreator extends Franca2ARABase {

	@Inject
	var extension AutosarUtil

	var Map<String, ImplementationDataType> nameToType = null
	var Map<String, ImplementationDataType> nameToVectorType = null

	new() {
		Preferences.instance.registerARAPrimitveTypesCreator(this)
	}

	def loadPrimitiveTypes() {
		if (nameToType === null) {
			explicitlyLoadPrimitiveTypes
		}
	}

	def explicitlyLoadPrimitiveTypes() {
		nameToType = newHashMap
		nameToVectorType = newHashMap

		val ARAResourceSet araResourceSet = new ARAResourceSet()
		val AUTOSAR primitiveTypesModel = araResourceSet.araStandardTypeDefinitionsModel.standardTypeDefinitionsModel
		primitiveTypesModel.eAllContents.filter(ImplementationDataType).forEach[
			nameToType.put(it.shortName,it)
		]

		val AUTOSAR primitiveTypesVectorsModel = araResourceSet.araStandardTypeDefinitionsModel.standardVectorTypeDefinitionsModel
		primitiveTypesVectorsModel.eAllContents.filter(ImplementationDataType).forEach[
			nameToVectorType.put(it.shortName,it)
		]
	}

	def getBaseTypeForReference(FBasicTypeId fBasicTypeId, String typedElementName, String namespaceName) {
		loadPrimitiveTypes
		if(!this.nameToType.containsKey(fBasicTypeId.getName)){
			getLogger.logError("Can not find an AUTOSAR simple type for the FBasicTypeId: " + fBasicTypeId?.getName + "! (IDL2620)")
		}
		if(fBasicTypeId == FBasicTypeId.BYTE_BUFFER){
			logger.logWarning('''The CommonAPI and AUTOSAR serialization formats of the Franca ByteBuffer '«typedElementName»' in '«namespaceName»' are equivalent only if the ARA::COM system configuration defines array sizes to be encoded with 4 Bytes.''')
		}
		this.nameToType.get(fBasicTypeId.getName)
	}

	def getBaseTypeVectorForReference(FBasicTypeId fBasicTypeId, String typedElementName, String namespaceName) {
		loadPrimitiveTypes
		val basicTypeVectorName = fBasicTypeId.getName + "Vector"
		if(!this.nameToVectorType.containsKey(basicTypeVectorName)){
			getLogger.logError("Can not find an AUTOSAR vector type for the FBasicTypeId: " + fBasicTypeId?.getName + "! (IDL2620)")
		}
		if(fBasicTypeId == FBasicTypeId.BYTE_BUFFER){
			logger.logWarning('''The CommonAPI and AUTOSAR serialization formats of the Franca ByteBuffers in the array '«typedElementName»' in '«namespaceName»' are equivalent only if the ARA::COM system configuration defines array sizes to be encoded with 4 Bytes.''')
		}
		this.nameToVectorType.get(basicTypeVectorName)
	}

	def isPrimitiveType(ImplementationDataType implementationDataType) {
		val lookupImplementationDataType = nameToType.get(implementationDataType.shortName)
		return lookupImplementationDataType !== null && lookupImplementationDataType === implementationDataType
	}


	var AUTOSAR primitiveTypesAnonymousArraysModel
	var ARPackage primitiveTypesAnonymousArraysMainPackage

	def clearPrimitiveTypesAnonymousArrays() {
		primitiveTypesAnonymousArraysModel = null
		primitiveTypesAnonymousArraysMainPackage = null
	}

	def createPrimitiveTypesAnonymousArraysModel() {
		primitiveTypesAnonymousArraysModel = fac.createAUTOSAR
		if (nameToType !== null) {
			val packagePath = AutosarUtil.collectPackagePath(nameToType.values.head.ARPackage)
			primitiveTypesAnonymousArraysMainPackage =
				primitiveTypesAnonymousArraysModel.ensurePackagesExistence(packagePath)
		}
	}

	def getPrimitiveTypesAnonymousArraysModel() {
		primitiveTypesAnonymousArraysModel
	}
	
	def getOrCreatePrimitiveTypesAnonymousArraysMainPackage() {
		if (primitiveTypesAnonymousArraysMainPackage === null) {
			createPrimitiveTypesAnonymousArraysModel
		}
		primitiveTypesAnonymousArraysMainPackage
	}

}

package org.genivi.faracon.ara2franca

import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.commonstructure.implementationdatatypes.ImplementationDataTypeElement
import java.util.Collection
import java.util.Optional
import javax.inject.Inject
import javax.inject.Singleton
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypedElement
import org.genivi.faracon.ARA2FrancaBase
import org.genivi.faracon.ARAResourceSet
import org.franca.core.franca.FTypeRef

@Singleton
class FrancaTypeCreator extends ARA2FrancaBase {

	val static ORIGINAL_SUB_ELEMENT_NAME_ANNOTATION = "OriginalSubElementName"

	@Inject
	var extension FrancaEnumCreator
	@Inject
	var extension FrancaImportCreator francaImportCreator
	@Inject
	var extension FrancaAnnotationCreator

	def transform(ImplementationDataType src) {
		if (src === null) {
			getLogger.logWarning('''Cannot create Franca type for not set implementation type.''')
			return null
		}
		if (src.category == "STRUCTURE") {
			return transformStructure(src)
		} else if (src.category == "UNION") {
			return transformUnion(src)
		} else if (src.category == "ASSOCIATIVE_MAP") {
			return transformMap(src)
		} else if (src.category == "TYPE_REFERENCE") {
			return transformEnumeration(src)
		} else if (src.category == "VECTOR") {
			return transformArray(src)
		} else if (src.category == "ARRAY") {
			logger.
				logWarning('''Category ARRAY used in «ImplementationDataType» «src.shortName» is not fully supported yet. Using the same logic as for category "VECTOR"''')
			return transformArray(src)
		} else {
			getLogger.
				logWarning('''Cannot create Franca type for "«src.shortName»" because AutosarDatatypes of category "«src.category»" are not yet supported''')
			return null
		}
	}

	def create createFTypeCollection createAnonymousTypeCollectionForModel(FModel model) {
		// no implementation - the create method ensures that we only create one anonymous type collection per FModel
		model.typeCollections.add(it)
	}

	/**
	 * Creates a default type, which can be used for the transformation if no source type is provided.
	 * Before calling this method an error should be logged.
	 */
	def createDefaultTypeRef() {
		val typeRef = fac.createFTypeRef
		typeRef.predefined = FBasicTypeId.get(FBasicTypeId.UINT32_VALUE)
		return typeRef
	}

	def private create fac.createFStructType transformStructure(ImplementationDataType src) {
		fillFrancaCompoundType(src, it)
	}

	def private create fac.createFUnionType transformUnion(ImplementationDataType src) {
		fillFrancaCompoundType(src, it)
	}

	def private fillFrancaCompoundType(
		ImplementationDataType aCompoundType,
		FCompoundType fCompoundType
	) {
		fCompoundType.name = aCompoundType.shortName
		if (aCompoundType.subElements !== null) {
			for (subElement : aCompoundType.subElements) {
				val araStructElementType = getTypeRefTargetType(subElement)
				if (araStructElementType !== null) {
					val field = fac.createFField => [
						name = subElement.shortName
						type = createFTypeRefAndImport(araStructElementType, it)
					]
					fCompoundType.elements.add(field)
				} else {
					getLogger.
						logError('''No type for the AUTOSAR sub-element "«subElement?.shortName»" in implementation data type "«aCompoundType?.shortName»" found. Cannot create a matching franca element.''')
				}
			}
		}
	}

	def private create fac.createFMapType transformMap(ImplementationDataType src) {
		name = src.shortName
		if (!src.checkSubElements(2, "No complete Franca map can be created from the mentioned Autosar type.")) {
			return
		}
		val keySubElement = src.subElements.get(0)
		if (!keySubElement.shortName.nullOrEmpty) {
			it.addFrancaAnnotation("Key " + ORIGINAL_SUB_ELEMENT_NAME_ANNOTATION, keySubElement.shortName)
		}
		val araKeyType = keySubElement.getTypeRefTargetType
		if (araKeyType !== null) {
			keyType = createFTypeRefAndImport(araKeyType, null)
		} else {
			logger.logError(
				"Cannot create mapping key type for " + ImplementationDataType.simpleName + " " + src.shortName)
		}
		val valueSubElement = src.subElements.get(1)
		if (!valueSubElement.shortName.nullOrEmpty) {
			it.addFrancaAnnotation("Value " + ORIGINAL_SUB_ELEMENT_NAME_ANNOTATION, valueSubElement.shortName)
		}
		val araValueType = valueSubElement.getTypeRefTargetType
		if (araValueType !== null) {
			valueType = createFTypeRefAndImport(araValueType, null)
		} else {
			logger.logError(
				"Cannot create mapping value type for " + ImplementationDataType.simpleName + " " + src.shortName)
		}
	}

	def private create fac.createFArrayType transformArray(ImplementationDataType src) {
		name = src.shortName
		if (!src.checkSubElements(1, "No inner type for the Franca array can be created.")) {
			return
		}
		val firstSubElement = src.subElements.get(0)
		if (!firstSubElement.shortName.nullOrEmpty) {
			it.addFrancaAnnotation(ORIGINAL_SUB_ELEMENT_NAME_ANNOTATION, firstSubElement.shortName)
		}

		if (firstSubElement.arraySizeSemantics == ArraySizeSemanticsEnum.FIXED_SIZE) {
			logger.
				logWarning('''The type "«src.shortName»" has array semantic «firstSubElement.arraySizeSemantics». Only experimental support for fixed size arrays is supported.''')
			val fixedArraySize = firstSubElement.arraySize?.mixedText
			it.addExperimentalArraySizeAnnotation(fixedArraySize)
		}
		val araElementType = firstSubElement.typeRefTargetType

		if (araElementType !== null) {
			elementType = createFTypeRefAndImport(araElementType, null)
		} else {
			getLogger.
				logError('''No Franca array created for Autosar type "«src.shortName», because no property with value type has been defined."''')
		}
	}

	def private boolean checkSubElements(ImplementationDataType src, int count, String consequence) {
		val dataTypeSubElements = src.subElements
		if (dataTypeSubElements.size !== count) {
			// we expect exactly one sub element, otherwise, we consider that as an error
			logger.
				logError('''Found «dataTypeSubElements.size» sub elements for «ImplementationDataType» «src.shortName». Only «count» sub elements are allowed for «src.category».«consequence» ''')
			return false
		}
		return true
	}

	def private getTypeRefTargetType(ImplementationDataTypeElement typeRef) {
		if (typeRef.category != "TYPE_REFERENCE") {
			getLogger.
				logError('''The category of the type reference in the sub element "«typeRef.shortName»" needs to be "TYPE_REFERENCE", but was «typeRef.category»''')
			return null
		}
		val firstProperty = getFirstProperty(typeRef.swDataDefProps)
		if (firstProperty === null) {
			getLogger.
				logError('''No property found for the type reference "«typeRef»". Cannot transform the type reference to Franca.''')
			return null
		}
		val typeRefTargetType = firstProperty.implementationDataType as ImplementationDataType
		typeRefTargetType
	}

	// Important: This cannot be realized as a Xtend create function because we need
	// to create multiple type ref objects that point to the same type object!
	def createFTypeRefAndImport(ImplementationDataType src, FTypedElement parentTypedElement) {
		val typeRef = fac.createFTypeRef
		if (isPrimitiveType(src)) {
			if (src.isStdType) {
				typeRef.setPrimitveTypeBasedOnName(src, parentTypedElement)
			} else {
				val nonVectorName = src.shortName.replace("Vector", "")
				typeRef.predefined = FBasicTypeId.getByName(nonVectorName)
				if (parentTypedElement !== null) {
					parentTypedElement.array = true
				}
			}
		} else {
			src.createImportIfNecessary()
			typeRef.derived = transform(src)
		}
		typeRef
	}

	def void setPrimitveTypeBasedOnName(FTypeRef fTypeRef, ImplementationDataType src, FTypedElement parentTypedElement) {
		val autosarShortName = src.shortName
		if (autosarShortName == "ByteArray" || autosarShortName == "ByteVectorType") {
			fTypeRef.predefined = FBasicTypeId.UINT8
			if(parentTypedElement === null){
				logger.logError('''The simple type «autosarShortName» cannot be used within because no Franca Typed parent has been created for the element «src»''')
			}else{
				parentTypedElement.array = true	
			}
		} else {
			fTypeRef.predefined = FBasicTypeId.getByName(src.shortName)
		}
	}

	/**
	 * A type is a primitive type if it is contained in the standard type definitions model.
	 */
	def isPrimitiveType(ImplementationDataType src) {
		if (src.araResourceSet.present) {
			return src.isStdTypeOrStdVector
		}
		// This is a fall back way to identify prmitive types if the implementation type has no resource 
		val isByteArray = src?.shortName == "ByteArray" && src?.category == "VECTOR"
		val isByteVectorType = src?.shortName == "ByteVectorType" && src?.category == "VECTOR"
		return isByteVectorType || isByteArray || src?.category == "VALUE" || src?.category == "STRING"
	}

	def private isStdTypeOrStdVector(ImplementationDataType src) {
		return src.isStdType || src.isStdVectorType

	}

	def private isStdType(ImplementationDataType src) {
		val araResourceSet = src.araResourceSet
		if (!araResourceSet.present) {
			return false
		}
		val araStdTypeModel = araResourceSet.get.araStandardTypeDefinitionsModel
		val stdResource = araStdTypeModel?.standardTypeDefinitionsModel?.eResource
		val srcResource = src.eResource
		return srcResource !== null && srcResource == stdResource
	}

	def private isStdVectorType(ImplementationDataType src) {
		val araResourceSet = src.araResourceSet
		if (!araResourceSet.present) {
			return false
		}
		val araStdTypeModel = araResourceSet.get.araStandardTypeDefinitionsModel
		val stdVectorResource = araStdTypeModel?.standardVectorTypeDefinitionsModel?.eResource
		val srcResource = src.eResource
		return srcResource !== null && srcResource == stdVectorResource
	}

	def private Optional<ARAResourceSet> getAraResourceSet(ImplementationDataType src) {
		val resource = src?.eResource
		val resourceSet = resource?.resourceSet
		if (resourceSet instanceof ARAResourceSet) {
			return Optional.of(resourceSet)
		}
		return Optional.empty
	}

}

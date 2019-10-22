package org.genivi.faracon.names

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypedElement

class FrancaNamesCollector {

	def fillNamesHierarchy(FModel fModel, NamesHierarchy namesHierarchy) {
		fModel.processElement("", namesHierarchy)
	}

	protected def void processElement(EObject arbitraryElement, String namespace, NamesHierarchy namesHierarchy) {
		val String localName = arbitraryElement.localName
		var innerNamespace = namespace
		if (!localName.nullOrEmpty) {
			if (!innerNamespace.empty) {
				innerNamespace += "."
			}
			innerNamespace += localName
			namesHierarchy.insertFullyQualifiedName(innerNamespace, arbitraryElement.metaclassGroup, false)
		}
		val finalInnerNamespace = innerNamespace
		arbitraryElement.eContents.forEach[processElement(finalInnerNamespace, namesHierarchy)]
	}

	protected dispatch def Class<?> getMetaclassGroup(EObject arbitraryElement) {
		null
	}
	protected dispatch def Class<?> getMetaclassGroup(FModel fModel) {
		FModel
	}
	protected dispatch def Class<?> getMetaclassGroup(FModelElement fModelElement) {
		FModelElement
	}
	protected dispatch def Class<?> getMetaclassGroup(FBroadcast fBroadcast) {
		FBroadcast
	}
	protected dispatch def Class<?> getMetaclassGroup(FEnumerator fEnumerator) {
		FEnumerator
	}
	protected dispatch def Class<?> getMetaclassGroup(FTypedElement fTypedElement) {
		FTypedElement
	}
	protected dispatch def Class<?> getMetaclassGroup(FArgument fArgument) {
		FArgument
	}
	protected dispatch def Class<?> getMetaclassGroup(FAttribute fAttribute) {
		FAttribute
	}
	protected dispatch def Class<?> getMetaclassGroup(FField fField) {
		FField
	}
	protected dispatch def Class<?> getMetaclassGroup(FMethod fMethod) {
		FMethod
	}
	protected dispatch def Class<?> getMetaclassGroup(FType fType) {
		FType
	}
	protected dispatch def Class<?> getMetaclassGroup(FTypeCollection fTypeCollection) {
		FTypeCollection
	}
	protected dispatch def Class<?> getMetaclassGroup(FInterface fInterface) {
		FInterface
	}

	protected dispatch def getLocalName(EObject arbitraryElement) {
		null
	}
	protected dispatch def getLocalName(FModel fModel) {
		fModel.name
	}
	protected dispatch def getLocalName(FModelElement fModelElement) {
		fModelElement.name
	}


/*
	protected dispatch def void processElement(EObject arbitraryElement, String namespace, NamesHierarchy namesHierarchy) {
		arbitraryElement.eContents.forEach[processElement(namespace, namesHierarchy)]
	}

	protected dispatch def void processElement(FModel fModel, String namespace, NamesHierarchy namesHierarchy) {
		val innerNamespace = fModel.name
		namesHierarchy.insertFullyQualifiedName(innerNamespace, FModel, false)
		fModel.eContents.forEach[processElement(innerNamespace, namesHierarchy)]
	}

	protected dispatch def void processElement(FModelElement fModelElement, String namespace, NamesHierarchy namesHierarchy) {
		val innerNamespace = namespace + "." + fModelElement.name
		namesHierarchy.insertFullyQualifiedName(innerNamespace, fModelElement.class, false)
		fModelElement.eContents.forEach[processElement(innerNamespace, namesHierarchy)]
	}

	protected dispatch def void processElement(FBroadcast fBroadcast, String namespace, NamesHierarchy namesHierarchy) {
		val innerNamespace = namespace + "." + fBroadcast.name
		namesHierarchy.insertFullyQualifiedName(innerNamespace, FBroadcast, false)
		fBroadcast.eContents.forEach[processElement(innerNamespace, namesHierarchy)]
	}
*/

}

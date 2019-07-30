package org.genivi.faracon.util

import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.Collection
import autosar40.genericstructure.generaltemplateclasses.arpackage.PackageableElement
import java.util.concurrent.AbstractExecutorService
import java.util.Objects

class AutosarUtil {
	private new() {
	}

	def static String getPackageNamespace(ARPackage arPackage) {
		val namespace = arPackage.shortName
		if (arPackage.eContainer instanceof ARPackage) {
			return getPackageNamespace(arPackage.eContainer as ARPackage) + "." + namespace
		}
		return namespace
	}

	/**
	 * Collects packages need to be transformed from Autosar to franca.
	 * Collects the packages that contain elements from type relevantElementsInstances or which are leaf packages.
	 * 
	 */
	static def void collectPackagesWithElementsOrLeafPackages(Collection<ARPackage> packages,
		Collection<ARPackage> packagesWithElements, Collection<Class<?>> relevantElementsInstances) {
		packages.forEach [ currentPackage |
			val hasRelevantElement = currentPackage.elements.findFirst [ packageElement |
				!relevantElementsInstances.filter[it.isInstance(packageElement)].isNullOrEmpty
			]
			val isLeafPackage = currentPackage.arPackages.isNullOrEmpty
			if (hasRelevantElement !== null || isLeafPackage) {
				// the current package has at least one interface or one ImplementationDataType --> needs to be transformed 
				packagesWithElements.add(currentPackage)
			}
			collectPackagesWithElementsOrLeafPackages(currentPackage.arPackages, packagesWithElements,
				relevantElementsInstances)
		]
	}
	
	/**
	 * Checks whether the namespace of the provided service interface matches 
	 * the namespace according to the package hierarchy.
	 */
	def static namespaceMathchesHierarchy(ServiceInterface serviceInterface) {
		val containingPackage = serviceInterface.ARPackage
		val hierarchyNamespace = containingPackage.packageNamespace
		return Objects.equals(hierarchyNamespace, serviceInterface.namespaceHierarchy)
	}
	
	
	def private static getNamespaceHierarchy(ServiceInterface serviceInterface){
		val hierarchy = serviceInterface.namespaces.map[it.shortName]
		return hierarchy.join(".")	
	} 
}

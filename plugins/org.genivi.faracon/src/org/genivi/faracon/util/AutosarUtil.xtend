package org.genivi.faracon.util

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.Collection

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
}

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

	static def void collectPackagesWithElements(Collection<ARPackage> packages,
		Collection<ARPackage> packagesWithElements, Collection<Class<?>> relevantElementsInstances) {
		packages.forEach [ currentPackage |
			val hasRelevantElement = currentPackage.elements.findFirst [ packageElement |
				!relevantElementsInstances.filter[it.isInstance(packageElement)].isNullOrEmpty
			]
			if (hasRelevantElement !== null) {
				// the current package has at least one interface or one ImplementationDataType --> needs to be transformed 
				packagesWithElements.add(currentPackage)
			}
			collectPackagesWithElements(currentPackage.arPackages, packagesWithElements, relevantElementsInstances)
		]
	}
}

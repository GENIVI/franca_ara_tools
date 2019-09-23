package org.genivi.faracon.franca2ara

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.Map
import java.util.regex.Pattern
import javax.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypeCollection
import org.genivi.faracon.Franca2ARABase

import static extension org.franca.core.FrancaModelExtensions.*

@Singleton
class ARAModelSkeletonCreator extends Franca2ARABase {

	val Map<FModel, ARPackage> fModel2arPackage = newHashMap()
	val Map<FTypeCollection, ARPackage> fTypeCollection2arPackage = newHashMap()

	def create fac.createAUTOSAR createAutosarModelSkeleton(FModel fModel) {
		arPackages.add(fModel.createPackageHierarchy)
	}

	def protected create fac.createARPackage createPackageHierarchy(FModel fModel) {
		val segments = fModel.name.split(Pattern.quote("."))
		var ARPackage currentPackage = it
		if (!segments.nullOrEmpty) {
			currentPackage.shortName = segments.get(0)
			var ARPackage currentParentPackage = currentPackage
			for (segment : segments.drop(1)) {
				currentPackage = createPackageWithName(segment, currentParentPackage)
				currentParentPackage = currentPackage
			}
		} else {
			currentPackage.shortName = fModel.name
		}
		
		// Create AUTOSAR subpackages for all Franca interface definitions with content that has to be transformed into package content.
		for (interface : fModel.interfaces) {
			if (!interface.types.nullOrEmpty || !interface.constants.nullOrEmpty) {
				fTypeCollection2arPackage.put(interface, createPackageWithName(interface.name, currentPackage))
			}
		}
		// Create AUTOSAR subpackages for all named Franca type collections.
		for (typeCollection : fModel.typeCollections) {
			if (typeCollection.name.nullOrEmpty) {
				fTypeCollection2arPackage.put(typeCollection, currentPackage)
			} else {
				fTypeCollection2arPackage.put(typeCollection, createPackageWithName(typeCollection.name, currentPackage))
			}
		}
		
		fModel2arPackage.put(fModel, currentPackage)
	}

	def getAccordingArPackage(FModel fModel) {
		fModel2arPackage.get(fModel)
	}

	def createAccordingArPackage(FModel fModel) {
		val accordingArPackage = fModel2arPackage.get(fModel)
		if (accordingArPackage === null) {
			createAutosarModelSkeleton(fModel)
			fModel2arPackage.get(fModel)
		} else {
			accordingArPackage
		}
	}

	def getAccordingArPackage(FTypeCollection fTypeCollection) {
		fTypeCollection2arPackage.get(fTypeCollection)
	}

	def createAccordingArPackage(FTypeCollection fTypeCollection) {
		// This check is only needed when an incomplete Franca model is converted to AUTOSAR.
		// We do this in some unit tests.
		if (fTypeCollection === null) return null

		val accordingArPackage = fTypeCollection2arPackage.get(fTypeCollection)
		if (accordingArPackage === null) {
			createAutosarModelSkeleton(fTypeCollection.model)
			fTypeCollection2arPackage.get(fTypeCollection)
		} else {
			accordingArPackage
		}
	}

	def createAccordingArPackage(EObject obj) {
		createAccordingArPackage(obj.typeCollection)
	}

	def private createPackageWithName(String name, ARPackage parent) {
		val ARPackage newPackage = fac.createARPackage
		newPackage.shortName = name
		parent?.arPackages?.add(newPackage)
		newPackage
	}

}
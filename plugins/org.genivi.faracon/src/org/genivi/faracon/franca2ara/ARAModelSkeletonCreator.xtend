package org.genivi.faracon.franca2ara

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.Map
import java.util.regex.Pattern
import javax.inject.Inject
import javax.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypeCollection
import org.genivi.faracon.Franca2ARABase

import static extension org.franca.core.FrancaModelExtensions.*

@Singleton
class ARAModelSkeletonCreator extends Franca2ARABase {

	@Inject
	var extension AutosarAnnotator

	val Map<FModel, ARPackage> fModel2arPackage = newHashMap()
	val Map<FTypeCollection, ARPackage> fTypeCollection2arPackage = newHashMap()

	def create fac.createAUTOSAR createAutosarModelSkeleton(FModel fModel) {
		arPackages.add(fModel.createPackageHierarchy)
	}

	def private create fac.createARPackage createPackageHierarchy(FModel fModel) {
		var ARPackage currentPackage = it
		if(fModel.name.nullOrEmpty){
			logger.logError("The name of the FIdl model is not set. The transformation to ARXML cannot be executed.")
			return
		}
		val segments = fModel.name.split(Pattern.quote("."))
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
				val interfacePackage = createPackageWithName(interface.name, currentPackage)
				val packageWithVersion = interface.createPackageForVersion(interfacePackage)
				fTypeCollection2arPackage.put(interface, packageWithVersion)
			}
		}
		// Create AUTOSAR subpackages for all named Franca type collections.
		for (typeCollection : fModel.typeCollections) {
			if (typeCollection.name.nullOrEmpty) {
				fTypeCollection2arPackage.put(typeCollection, typeCollection.createPackageForVersion(currentPackage))
			} else {
				val typeCollectionPackage = createPackageWithName(typeCollection.name, currentPackage)
				val packageWithVersion = interface.createPackageForVersion(typeCollectionPackage)
				fTypeCollection2arPackage.put(typeCollection, packageWithVersion)
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

	def getAccordingInterfacePackage(FInterface fInterface) {
		val rootContainer = EcoreUtil.getRootContainer(fInterface)
		if (!(rootContainer instanceof FModel)) {
			logger.logError("Interface " + fInterface.name + " needs to be contained in an FModel")
		}
		val fModel = rootContainer as FModel
		//ensure that the hierarchy for the interface has been created  
		fModel.createAutosarModelSkeleton
		val fModelPackage = fModel.accordingArPackage
		return fInterface.createPackageForVersion(fModelPackage)
	}

	def createAccordingArPackage(FTypeCollection fTypeCollection) {
		// This check is only needed when an incomplete Franca model is converted to AUTOSAR.
		// We do this in some unit tests.
		if(fTypeCollection === null) return null

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

	/**
	 * Creates a package for an FTypeCollection or an FInterface if the FTypeCollection or FInterface
	 * has a version attached.
	 * If no version is attached the provided parent package is returend.
	 */
	def ARPackage createPackageForVersion(FTypeCollection fTypeCollection, ARPackage parentPackage) {
		val fVersion = fTypeCollection?.version
		if (fVersion !== null && (fVersion.major !== null || fVersion.minor !== null )) {
			if (fVersion.major === null || fVersion.minor === null) {
				logger.logError(
					"The version of " + fTypeCollection.class.simpleName +
						" is wrong. Major and minor version need to be set, but found: " + fVersion)
			}
			val majorPart = if(fVersion.major === null) "_1" else String.valueOf(fVersion.major)
			val minorPart = if(fVersion.minor === null) "_1" else String.valueOf(fVersion.minor)
			val packageName = "v_" + majorPart + "_" + minorPart
			val versionPackage = createPackageForVersion(packageName, parentPackage, fTypeCollection)
			return versionPackage
		}
		return parentPackage
	}

	def private create fac.createARPackage createPackageForVersion(String name, ARPackage parentPackage,
		FTypeCollection fTypeCollection) {
		it.shortName = name
		parentPackage.arPackages += it
		val typeCollectionNameString = if(fTypeCollection.name.isNullOrEmpty) "" else fTypeCollection.name + " "
		val classNameString = if( fTypeCollection instanceof FInterface) FInterface.simpleName else FTypeCollection.simpleName 
		it.addAnnotation("FrancaVersion", classNameString+ ": " + typeCollectionNameString + name)
	}

}

package org.genivi.faracon

import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import autosar40.swcomponent.portinterface.ArgumentDataPrototype
import autosar40.swcomponent.portinterface.ClientServerOperation
import com.google.inject.Inject
import org.apache.log4j.Logger
import org.genivi.faracon.ara2franca.FrancaTypeCreator

class ARA2FrancaTransformation extends ARA2FrancaBase {
	
	@Inject 
	var extension FrancaTypeCreator araTypeCreator

	def create fac.createFModel transform(AUTOSAR src) {		
		// TODO: this just takes the first package in the arxml
		if (!src.arPackages.empty) {
			var pkg = src.arPackages.get(0)
			var namespace = pkg.shortName
			while (!pkg.arPackages.empty) {
				pkg = pkg.arPackages.get(0)
				namespace += '.' + pkg.shortName		
			}
			name = namespace
			
			for (element : pkg.elements) {
				if (element instanceof ServiceInterface) {
					interfaces.add(transform(element))
				}
			}
			
			if (!interfaces.empty) {
				// TODO: eliminate simplification for the prototype (just puts all type definitions into the first interface definition).
				val typeCollection = interfaces.get(0)
				pkg = src.arPackages.get(0)
				while (pkg !== null) {
					for (element : pkg.elements) {
						if (element instanceof ImplementationDataType) {
							typeCollection.types.add(transform(element))
						}
					}

					if (!pkg.arPackages.empty) {
						pkg = pkg.arPackages.get(0)
					} else {
						pkg = null
					}
				}
				
			}
		} else {
			name = "NOT_AVAILABLE"
		}
	}

	def create fac.createFInterface transform(ServiceInterface src) {
		if(!src.namespaces.isNullOrEmpty){
			logger.logError('''Namespaces are not supported by Franca. Franca only uses the package hierarchy to identify namespaces. «
			»The following Autosar namespaces defined for the interface "«src.shortName»" can not be transformed: "«src.namespaces.map[shortName].join(", ")»"''')
		}
		name = src.shortName
		broadcasts.addAll(src.events.map[transform])
		attributes.addAll(src.fields.map[transform])
		methods.addAll(src.methods.map[transform])
	}
	
	def create fac.createFBroadcast transform(VariableDataPrototype src) {
		name = src.shortName
		val outArg = fac.createFArgument => [
			// TODO: This is not a proper name. The real parameter name is lost during the Franca to AUTOSAR transformation!
			name = src.type.shortName.toFirstLower
			type = createFTypeRef(src.type as ImplementationDataType)
		]
		outArgs.add(outArg)
	}
	
	def create fac.createFAttribute transform(Field src) {
		name = src.shortName
		type = createFTypeRef(src.type as ImplementationDataType)
		noRead = !src.hasGetter
		noSubscriptions = !src.hasNotifier
		readonly = !src.hasSetter
	}
	
	def create fac.createFMethod transform(ClientServerOperation src) {
		name = src.shortName
		inArgs.addAll(src.arguments.filter[direction == ArgumentDirectionEnum.IN].map[transform])
		outArgs.addAll(src.arguments.filter[direction == ArgumentDirectionEnum.OUT].map[transform])
	}
	
	def create fac.createFArgument transform(ArgumentDataPrototype src) {
		name = src.shortName
		type = createFTypeRef(src.type as ImplementationDataType)
	}
	
}

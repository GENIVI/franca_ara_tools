package org.genivi.faracon;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.sphinx.emf.ecore.proxymanagement.IProxyResolverService;
import org.eclipse.sphinx.emf.metamodel.IMetaModelDescriptor;
import org.eclipse.sphinx.emf.metamodel.MetaModelDescriptorRegistry;
import org.eclipse.sphinx.emf.resource.ExtendedResourceSetImpl;

import autosar40.util.Autosar40Package;
import autosar40.util.Autosar40ReleaseDescriptor;
import autosar40.util.Autosar40ResourceFactoryImpl;

public class ARAResourceSet extends ExtendedResourceSetImpl {

	protected AraStandardTypeDefinitionsModel araStandardTypeDefinitionsModel;

	public ARAResourceSet() {
		configure();
		initAndloadStandardTypeDefinitions();
	}

	public ARAResourceSet(AraStandardTypeDefinitionsModel araStandardTypeDefinitionsModel) {
		configure();
		this.araStandardTypeDefinitionsModel = araStandardTypeDefinitionsModel;
	}

	protected void configure() {
		// next line needs to stay because side effects.
		Autosar40Package autosar40Package = Autosar40Package.eINSTANCE;
		//EPackage.Registry.INSTANCE.put(autosar40Package.eNS_URI, autosar40Package);

		// register the appropriate resource factory to handle all file extensions for Dbus
//		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xml", new DbusxmlResourceFactoryImpl());
//		resourceSet.getPackageRegistry().put(DbusxmlPackage.eNS_URI, DbusxmlPackage.eINSTANCE);

		if (MetaModelDescriptorRegistry.INSTANCE.getDescriptors(Autosar40ReleaseDescriptor.INSTANCE.getIdentifier()).isEmpty())
			MetaModelDescriptorRegistry.INSTANCE.addDescriptor(Autosar40ReleaseDescriptor.INSTANCE);

		if (!Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().containsKey(
						Autosar40ReleaseDescriptor.ARXML_DEFAULT_FILE_EXTENSION)) {
			Resource.Factory arFactory = new Autosar40ResourceFactoryImpl();
			Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put(
				Autosar40ReleaseDescriptor.ARXML_DEFAULT_FILE_EXTENSION,
				arFactory
			);

			getResourceFactoryRegistry().getExtensionToFactoryMap().put(
				Autosar40ReleaseDescriptor.ARXML_DEFAULT_FILE_EXTENSION,
				arFactory);
		}
	}
	
	public AraStandardTypeDefinitionsModel getAraStandardTypeDefinitionsModel() {
		return araStandardTypeDefinitionsModel;
	}

	private void initAndloadStandardTypeDefinitions() {
		araStandardTypeDefinitionsModel = new AraStandardTypeDefinitionsModel();
		this.araStandardTypeDefinitionsModel.loadStandardTypeDefinitions(this); 
	}

	@Override
	protected IProxyResolverService getProxyResolverService(IMetaModelDescriptor descriptor) {
		return null;
	}

}

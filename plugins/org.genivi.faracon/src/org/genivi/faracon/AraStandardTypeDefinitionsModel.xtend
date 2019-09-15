package org.genivi.faracon

import autosar40.autosartoplevelstructure.AUTOSAR
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.emf.ecore.resource.Resource
import java.io.IOException
import org.eclipse.emf.common.util.URI
import java.net.URL
import java.util.Collections
import org.eclipse.emf.ecore.resource.ResourceSet

class AraStandardTypeDefinitionsModel {
	@Accessors(PUBLIC_GETTER)
	var AUTOSAR standardTypeDefinitionsModel
	@Accessors(PUBLIC_GETTER)
	var AUTOSAR standardVectorTypeDefinitionsModel
	
	val static String PATH_TO_STD_ARXML_FILE = "stdtypes.arxml";
	val static String PATH_TO_STD_VECTOR_ARXML_FILE = "stdtypes_vectors.arxml";
	
	def protected loadStandardTypeDefinitions(ResourceSet resourceSet){
		standardTypeDefinitionsModel = loadARAModelFromPluginResource(PATH_TO_STD_ARXML_FILE, resourceSet);
		standardVectorTypeDefinitionsModel = loadARAModelFromPluginResource(PATH_TO_STD_VECTOR_ARXML_FILE, resourceSet);
	} 
	
	def private AUTOSAR loadARAModelFromPluginResource(String fileName, ResourceSet resourceSet) {
		val  url = getClass().getResource("/" + fileName);
		val logicalURI = URI.createFileURI(fileName);
		try {
			val resource = loadResource(url, logicalURI, resourceSet);
			return resource.getContents().get(0) as AUTOSAR
		} catch (IOException e) {
			//TODO: error handling
			return null;
		}
	}
	
	def private Resource loadResource(URL url, URI uri, ResourceSet resourceSet) throws IOException {
		val resource = resourceSet.createResource(uri);
		resource.load(url.openStream(), Collections.EMPTY_MAP);
		return resource;
	}
}

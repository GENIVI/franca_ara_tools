/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.genivi.faracon;

import java.io.IOException;
import java.io.PrintStream;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.IntegerTypeConverter;
import org.genivi.faracon.logging.BaseWithLogger;

import com.google.inject.Inject;

import autosar40.autosartoplevelstructure.AUTOSAR;
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage;
import autosar40.util.Autosar40ReleaseDescriptor;

public class ARAConnector extends BaseWithLogger implements IFrancaConnector {

	@Inject
	ARA2FrancaTransformation ara2FrancaTransformation;

	@Inject
	Franca2ARATransformation franca2ARATransformation;

	private String fileExtension = "arxml";

	private Set<TransformationIssue> lastTransformationIssues = null;

	@Override
	public IModelContainer loadModel(String filename) {
		return loadModel(new ARAResourceSet(), filename);
	}

	public IModelContainer loadModel(ARAResourceSet araResourceSet, String filename) {
		AUTOSAR model = loadARAModel(araResourceSet, filename);
		if (model==null) {
			getLogger().logError("Could not load arxml model from file " + filename);
		} else {
			List<ARPackage> packages = model.getArPackages();
//			if (packages.isEmpty())
//				getLogger().logInfo("Loaded arxml model (no packages)");
//			else
//				getLogger().logInfo("Loaded arxml model (first package " + packages.get(0).getShortName() + ")");
		}
		return new ARAModelContainer(model, araResourceSet.getAraStandardTypeDefinitionsModel());
	}

	@Override
	public boolean saveModel(IModelContainer model, String filename) {
		if (! (model instanceof ARAModelContainer)) {
			return false;
		}

		ARAModelContainer mc = (ARAModelContainer) model;
		return saveARXML(new ARAResourceSet(mc.araStandardTypeDefinitionsModel()), mc.model()/*, mc.getComments()*/, filename);
	}

	@Override
	public FrancaModelContainer toFranca(IModelContainer model) {
		if (! (model instanceof ARAModelContainer)) {
			return null;
		}

		ARAModelContainer amodel = (ARAModelContainer)model;
		Collection<FModel> francaModels = ara2FrancaTransformation.transform(amodel.model());

//		lastTransformationIssues = ara2FrancaTransformation.getTransformationIssues();
//		out.println(IssueReporter.getReportString(lastTransformationIssues));

		return new FrancaMultiModelContainer(francaModels);
	}

	@Override
	public IModelContainer fromFranca(FModel fmodel) {
		// do ranged integer conversion as a preprocessing step
		IntegerTypeConverter.removeRangedIntegers(fmodel, true);

		// do the actual transformation
		AUTOSAR amodel = franca2ARATransformation.transform(fmodel);

		// report issues
//		lastTransformationIssues = franca2ARATransformation.getTransformationIssues();
//		out.println(IssueReporter.getReportString(lastTransformationIssues));

		// create the model container and add some comments to the model
		ARAModelContainer mc = new ARAModelContainer(amodel, null);
		return mc;
	}

	public Set<TransformationIssue> getLastTransformationIssues() {
		return lastTransformationIssues;
	}


	/**
	 * We need to provide a different behavior for URI resolving during load
	 * of arxml XML files. This is because the noNamespaceSchemaLocation
	 * attribute "introspect.xsd" will be used as a key to find the corresponding
	 * EMF package name. If we load an Introspection file with an absolute path, the 
	 * resolving would destroy this key and the EMF package is no more found.  
	 */
//	private static class DBusURIHandler extends URIHandlerImpl {
//		@Override
//		public URI resolve(URI uri) {
//			// don't resolve
//			return uri;
//		}
//	}
	
	public static AUTOSAR loadARAModel(ResourceSet resourceSet, String fileName) {
		URI uri = URI.createFileURI(fileName);
		
		//ConnectorStandaloneSetup.doSetup();

		if (Platform.isRunning()) {
			// TODO
//			ModelLoadManager.INSTANCE.loadFile(getIFileFromURI(uri),
//					Autosar40ReleaseDescriptor.INSTANCE, false,
//					new NullProgressMonitor());
		}

		Resource resource = resourceSet.getResource(uri, true);
		return (AUTOSAR)resource.getContents().get(0);
	}

	public static AUTOSAR loadARAModel(String fileName) {
		
		ARAResourceSet araResourceSet = new ARAResourceSet();
		return loadARAModel(araResourceSet, fileName);
	}

	private boolean saveARXML(
		ResourceSet resourceSet,
		AUTOSAR autosar,
		URI uri
	) throws IOException {

		Resource resource = resourceSet.createResource(uri, Autosar40ReleaseDescriptor.ARXML_CONTENT_TYPE_ID);
		if (Platform.isRunning()) {
			Resource originalResource = autosar.eResource();
			AUTOSAR copy = EcoreUtil.copy(autosar);
//			if (originalResource == null)
//				throw new IllegalStateException("Autosar resource is null");
			// if we don't unload the original model the additions will be seen in that one as well
			if (originalResource != null)
				originalResource.unload();			

			resource.getContents().add(copy);
			resource.save(Collections.EMPTY_MAP);
		} else {
			resource.getContents().add(autosar);
			resource.save(Collections.emptyMap());
		}
 
		getLogger().logInfo("Saved generated arxml-file as '" + uri + "'");

		return true;
	}

	public boolean saveARXML(ResourceSet resourceSet, AUTOSAR autosar, String name) {
		URI uri = URI.createFileURI(name);
		try {
			saveARXML(resourceSet, autosar, uri);
		} catch (IOException e) {
			getLogger().logError("Couldn't save the ARXML file \"" + name + "\"!");
			return false;
		}
		return true;
	}
	
	@Override
	public void setOutputStreams(PrintStream out, PrintStream err) {
		// TODO Auto-generated method stub
	}

	@Override
	public void setLogger(Logger logger) {
		// TODO Auto-generated method stub
	}
	
//	/**
//	 * Add some lines to a given XML file. 
//	 * 
//	 * The lines will be inserted directly below the first line in the XML.
//	 * The first line has to be a "xml version" tag.
//	 *  
//	 * @param inFile the XML file which should be changed
//	 * @param lines the set of lines which should be inserted into the file
//	 * @throws IOException
//	 */
//	private static void addLinesToXML(File inFile, Iterable<String> lines) throws IOException {
//		// compile string which is to be inserted
//		StringBuilder sb = new StringBuilder();
//		sb.append("$1");
//		for(String l : lines) {
//			sb.append("\n" + l);
//		}
//		
//		// read the file and insert the string which we have built before
//		String content = contents(inFile);
//		content = content.replaceAll("(<\\?xml version.*\\?>)", sb.toString());
//
//		// write the file again
//		FileOutputStream fos = new FileOutputStream(inFile);
//		PrintWriter out = new PrintWriter(fos);
//		out.print(content);
//		out.flush();
//		out.close();
//	}
//
//	private static String contents (File file) throws IOException {
//		InputStream in = new FileInputStream(file);
//		byte[] b  = new byte[(int) file.length()];
//		int len = b.length;
//		int total = 0;
//
//		while (total < len) {
//		  int result = in.read(b, total, len - total);
//		  if (result == -1) {
//		    break;
//		  }
//		  total += result;
//		}
//		in.close();
//		return new String(b);
//	}
}

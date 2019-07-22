package org.genivi.faracon.cli;

import java.io.File;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.validation.AbstractValidationMessageAcceptor;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.franca.FModel;
import org.genivi.faracon.ARAConnector;
import org.genivi.faracon.ARAModelContainer;
import org.genivi.faracon.FrancaMultiModelContainer;
import org.genivi.faracon.console.CommandlineTool;
//import org.genivi.faracon.generator.GeneratorFileSystemAccess;
//import org.genivi.faracon.verification.CommandlineValidator;
//import org.genivi.faracon.verification.ValidatorCore;
//import org.genivi.faracon.generator.FrancaDBusGenerator;
import org.genivi.faracon.preferences.Preferences;
import org.genivi.faracon.preferences.PreferencesConstants;

import com.google.inject.Inject;

public class ConverterCliCommand extends CommandlineTool {

	@Inject
	protected ARAConnector araConnector;

	@Inject
	protected FrancaPersistenceManager francaLoader;

//	@Inject
//	protected GeneratorFileSystemAccess fsa;

	protected Preferences preferences;

//	@Inject
//	protected IGenerator francaGenerator;
//	protected FrancaDBusGenerator francaGenerator;

	protected String SCOPE = "DBus validation: ";

	private ValidationMessageAcceptor cliMessageAcceptor = new AbstractValidationMessageAcceptor() {

		@Override
		public void acceptInfo(String message, EObject object, EStructuralFeature feature, int index, String code,
				String... issueData) {
			getLogger().logInfo(SCOPE + message);
		}

		@Override
		public void acceptWarning(String message, EObject object, EStructuralFeature feature, int index, String code,
				String... issueData) {
			getLogger().logWarning(SCOPE + message);
		}

		@Override
		public void acceptError(String message, EObject object, EStructuralFeature feature, int index, String code,
				String... issueData) {
			hasValidationError = true;
			getLogger().logError(SCOPE + message);
		}
	};

	/**
	 * The constructor registers the needed bindings to use the generator
	 */
	public ConverterCliCommand() {
		preferences = Preferences.getInstance();
	}

	/**
	 * Receive command line arguments and set them as preference values for the code
	 * generation.
	 */
	public int execute(CommandLine parsedArguments) {
		// Handle command line options.

//		@SuppressWarnings("unchecked")

		// -l --log-level quiet or verbose
		if (parsedArguments.hasOption("l")) {
			setLogLevel(parsedArguments.getOptionValue("l"));
		}

		getLogger().logInfo("Command: Franca ARA Converter");
		getLogger().increaseIndentationLevel();

		// -e --warnings-as-errors Treat warnings as errors.
		if (parsedArguments.hasOption("e")) {
			setWarningsAsErrors(true);
		}

		// -c --continue-on-errorsDo not stop the tool execution when an error occurs.
		if (parsedArguments.hasOption("c")) {
			setContinueOnErrors(true);
		}

		List<String> commandLineArguments = parsedArguments.getArgList();
		for (String commandLineArgument : commandLineArguments) {
			getLogger().logWarning("Unexpected command line argument \"" + commandLineArgument + "\"");
		}

		String[] francaFilePaths = parsedArguments.getOptionValues('f');
		String[] araFilePaths = parsedArguments.getOptionValues('a');
//		// We expect at least one fidl/fdepl file as command line argument
//		if (files.size() > 0 && files.get(0) != null) {
		boolean haveFrancaInput = francaFilePaths != null && francaFilePaths.length > 0;
		boolean haveARAInput = araFilePaths != null && araFilePaths.length > 0;
		if (!haveFrancaInput && !haveARAInput) {
			getLogger().logError("At least one input model file has to be given!");
		}
		if (haveFrancaInput && haveARAInput) {
			getLogger().logWarning("A mix of FrancaIDL and Adaptive AUTOSAR input model files is given.");
		}
//		// a search path may be specified, collect all fidl/fdepl files
//		if (parsedArguments.hasOption("sp")) {
//			files.addAll(cliTool.searchFidlandFdeplFiles(parsedArguments
//					.getOptionValue("sp")));
//		}

		// destination: -d --dest overwrite default output directory path
		if (parsedArguments.hasOption("d")) {
			setOutputDirectoryPath(parsedArguments.getOptionValue("d"));
		}

		// A file path, that points to a file, that contains the license text.
		// -L --license license text in generated files
		if (parsedArguments.hasOption("L")) {
			setLicenseText(parsedArguments.getOptionValue("L"));
		}

//			// Switch off validation
//			if (parsedArguments.hasOption("nv")) {
//				cliTool.disableValidation();
//			}

		getLogger().decreaseIndentationLevel();

		// Invoke the converters.
		convertFrancaFiles(francaFilePaths);
		convertARAFiles(araFilePaths);

		return 0;
	}

	public void convertFrancaFiles(String[] francaFilePaths) {
		if (francaFilePaths == null || francaFilePaths.length == 0) {
			return;
		}

		getLogger().logInfo("Converting Franca IDL models to Adaptive AUTOSAR IDL models...");
		getLogger().increaseIndentationLevel();

		for (String francaFilePath : francaFilePaths) {
			// Load an input FrancaIDL model.
			String normalizedFrancaFilePath = normalize(francaFilePath);
			getLogger().logInfo("Loading FrancaIDL file " + normalizedFrancaFilePath);
			getLogger().increaseIndentationLevel();
			FModel francaModel;
			try {
				francaModel = francaLoader.loadModel(normalizedFrancaFilePath);
			} catch (Exception e) {
				getLogger().logError("File " + normalizedFrancaFilePath + " could not be loaded!");
				getLogger().decreaseIndentationLevel();
				continue;
			}
			if (francaModel == null) {
				getLogger().logError("File " + normalizedFrancaFilePath + " could not be loaded!");
				getLogger().decreaseIndentationLevel();
				continue;
			}
			URI francaModelUri = francaModel.eResource().getURI();
			if (!francaModelUri.fileExtension().toLowerCase().equals("fidl")) {
				getLogger().logWarning("The FrancaIDL file " + normalizedFrancaFilePath
						+ " does not have the file extension \"fidl\".");
			}
			getLogger().decreaseIndentationLevel();

			// Transform the FrancaIDL model to an arxml model.
			getLogger().logInfo("Converting FrancaIDL file " + normalizedFrancaFilePath);
			ARAModelContainer araModelContainer = (ARAModelContainer) araConnector.fromFranca(francaModel);

			// Store the output arxml model.
			URI transformedModelUri = francaModelUri.trimFileExtension().appendFileExtension("arxml");
			String outputDirectoryPath = null;
			try {
				outputDirectoryPath = preferences.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "");
			} catch (Preferences.UnknownPreferenceException e) {
				getLogger().logError(e.getMessage());
			}
			if (!outputDirectoryPath.isEmpty()) {
				outputDirectoryPath += "/";
			}
			String araFilePath = normalize(outputDirectoryPath + transformedModelUri.lastSegment());
			getLogger().logInfo("Storing arxml file " + araFilePath);
			araConnector.saveModel(araModelContainer, araFilePath);
		}

		getLogger().decreaseIndentationLevel();
	}

	public void convertARAFiles(String[] araFilePaths) {
		if (araFilePaths == null || araFilePaths.length == 0) {
			return;
		}

		getLogger().logInfo("Converting Adaptive AUTOSAR IDL models to Franca IDL models...");
		getLogger().increaseIndentationLevel();

		for (String araFilePath : araFilePaths) {
			// Load an input arxml model.
			String normalizedARAFilePath = normalize(araFilePath);
			getLogger().logInfo("Loading arxml file " + normalizedARAFilePath);
			getLogger().increaseIndentationLevel();
			ARAModelContainer araModelContainer;
			try {
				araModelContainer = (ARAModelContainer) araConnector.loadModel(normalizedARAFilePath);
			} catch (Exception e) {
				getLogger().logError("File " + normalizedARAFilePath + " could not be loaded!");
				getLogger().decreaseIndentationLevel();
				continue;
			}
			URI araModelUri = araModelContainer.model().eResource().getURI();
			if (!araModelUri.fileExtension().toLowerCase().equals("arxml")) {
				getLogger().logWarning("The Adaptive AUTOSAR file " + normalizedARAFilePath
						+ " does not have the file extension \"arxml\".");
			}
			getLogger().decreaseIndentationLevel();

			// Transform the arxml model to a FrancaIDL model.
			getLogger().logInfo("Converting arxml file " + normalizedARAFilePath);
			FrancaMultiModelContainer fmodel = (FrancaMultiModelContainer) araConnector.toFranca(araModelContainer);

			for (FrancaModelContainer francaModelContainer : fmodel.getFrancaModelContainers()) {
				// Store the output FrancaIDL model.
				URI transformedModelUri = araModelUri.trimFileExtension();
				if (fmodel.getFrancaModelContainers().size() > 1) {
					// if we created more than one Franca file, we use the Franca model name as file
					// name as we need to create multiple files and cannot use the input file with
					// ".fidl" as extension
					String modelName = francaModelContainer.model().getName();
					transformedModelUri = araModelUri.trimFileExtension().trimSegments(1).appendFragment(modelName);
				}
				transformedModelUri.appendFileExtension("fidl");

				String outputDirectoryPath = null;
				try {
					outputDirectoryPath = preferences.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "");
				} catch (Preferences.UnknownPreferenceException e) {
					getLogger().logError(e.getMessage());
				}
				if (!outputDirectoryPath.isEmpty()) {
					outputDirectoryPath += "/";
				}
				String francaFilePath = normalize(outputDirectoryPath + transformedModelUri.lastSegment());
				getLogger().logInfo("Storing FrancaIDL file " + francaFilePath);
				francaLoader.saveModel(fmodel.model(), francaFilePath);
			}
		}

		getLogger().decreaseIndentationLevel();
	}

	protected String normalize(String _path) {
		File itsFile = new File(_path);
		return itsFile.getAbsolutePath();
	}

//	/**
//	 * Call the franca generator for the specified list of files.
//	 *
//	 * @param fileList
//	 *            the list of files to generate code from
//	 */
//	protected int doGenerate(List<String> _fileList) {
//		fsa.setOutputConfigurations(Preferences.getInstance()
//				.getOutputpathConfiguration());
//
//		XtextResourceSet rsset = injector.getProvider(XtextResourceSet.class)
//				.get();
//
//		int error_state = NO_ERROR_STATE;
//		getLogger().logInfo("Using Franca Version " + getFrancaVersion());
//
//		// Create absolute paths
//		List<String> fileList = new ArrayList<String>();
//		for (String path : _fileList) {
//			String absolutePath = normalize(path);
//			fileList.add(absolutePath);
//		}
//
//		for (String file : fileList) {
//			URI uri = URI.createFileURI(file);
//			Resource resource = null;
//			try {
//				resource = rsset.createResource(uri);
//			} catch (IllegalStateException ise) {
//				getLogger().logError("Failed to create a resource from "
//						+ file + "\n" + ise.getMessage());
//				error_state = ERROR_STATE;
//				continue;
//			}
//			hasValidationError = false;
//			if (isValidation) {
//				validateDBus(resource);
//			}
//			if (!hasValidationError) {
//				getLogger().logInfo("Generating code for " + file);
//				try {
//					if (Preferences.getInstance().getPreference(
//							PreferencesConstants.P_OUTPUT_SUBDIRS_DBUS, "false").equals("true")) {
//						String subdir = (new File(file)).getName();
//						subdir = subdir.replace(".fidl", "");
//						subdir = subdir.replace(".fdepl", "");
//						fsa.setOutputConfigurations(Preferences.getInstance()
//							.getOutputpathConfiguration(subdir));
//					}
////					francaGenerator.doGenerate(resource, fsa);
//				} catch (Exception e) {
//					getLogger()
//							.logError("Failed to generate dbus code: "
//									+ e.getMessage());
//					error_state = ERROR_STATE;
//				}
//			} else {
//				error_state = ERROR_STATE;
//			}
//			if (resource != null) {
//				// Clear each resource from the resource set in order to let
//				// other fidl files import it.
//				// Otherwise an IllegalStateException will be thrown for a
//				// resource that was already created.
//				resource.unload();
//				rsset.getResources().clear();
//			}
//		}
//		if (dumpGeneratedFiles) {
//			fsa.dumpGeneratedFiles();
//		}
//		fsa.clearFileList();
//		dumpGeneratedFiles = false;
//		return error_state;
//	}

//	/**
//	 * Validate the fidl/fdepl file resource
//	 *
//	 * @param resource
//	 */
//	public void validateDBus(Resource resource) {
//		EObject model = null;
//		CommandlineValidator cliValidator = new CommandlineValidator(
//				cliMessageAcceptor);
//
//		//getLogger().logInfo("validating " + resource.getURI().lastSegment());
//
//		model = cliValidator.loadResource(resource);
//
//		if (model != null) {
//			if (model instanceof FDModel) {
//				// Many error logs would be displayed if a SomeIP deployment file had DBus
//				// deployment information (or vice versa).
//				// Therefore don't validate fdepl files for DBus at the moment
//				return;
//				// cliValidator.validateImports((FDModel) model, resource.getURI());
//			}
//			// check existence of imported fidl/fdepl files
//			if (model instanceof FModel) {
//				cliValidator.validateImports((FModel) model, resource.getURI());
//
//				// validate against GENIVI rules
//				ValidatorCore validator = new ValidatorCore();
//				try {
//					validator.validateModel((FModel) model, cliMessageAcceptor);
//				} catch (Exception e) {
//					getLogger().logError(e.getMessage());
//					hasValidationError = true;
//					return;
//				}
//			}
//			// XText validation
//			cliValidator.validateResourceWithImports(resource);
//		} else {
//			// model is null, no resource factory was registered !
//			hasValidationError = true;
//		}
//	}

	public void setOutputDirectoryPath(String outputDirectoryPath) {
		String normalizedOutputDirectoryPath = normalize(outputDirectoryPath);
		getLogger().logInfo("Output directory path: " + normalizedOutputDirectoryPath);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, normalizedOutputDirectoryPath);
	}

	public void setLogLevel(String optionValue) {
		if (PreferencesConstants.LOGLEVEL_QUIET.equals(optionValue)) {
			preferences.setPreference(PreferencesConstants.P_LOGOUTPUT, "false");
			getLogger().enableInfosLogging(false);
			getLogger().enableWarningsLogging(false);
			getLogger().enableErrorsLogging(false);
		}
		if (PreferencesConstants.LOGLEVEL_VERBOSE.equals(optionValue)) {
			preferences.setPreference(PreferencesConstants.P_LOGOUTPUT, "true");
			getLogger().enableInfosLogging(true);
			getLogger().enableWarningsLogging(true);
			getLogger().enableErrorsLogging(true);
		}
	}

	public void setWarningsAsErrors(boolean enabled) {
		preferences.setPreference(PreferencesConstants.P_WARNINGS_AS_ERRORS, enabled ? "true" : "false");
		getLogger().enableWarningsAsErrors(enabled);
	}

	public void setContinueOnErrors(boolean enabled) {
		preferences.setPreference(PreferencesConstants.P_CONTINUE_ON_ERRORS, enabled ? "true" : "false");
		getLogger().enableContinueOnErrors(enabled);
	}

//	public void disableValidation() {
//		getLogger().logInfo("Validation is off");
//		isValidation = false;
//	}

	/**
	 * Set the text from a file which will be inserted as a comment in each
	 * generated file (for example your license)
	 *
	 * @param fileWithText
	 * @return
	 */
	public void setLicenseText(String fileWithText) {

		String licenseText = getLicenseText(fileWithText);

		if (licenseText != null && !licenseText.isEmpty()) {
			preferences.setPreference(PreferencesConstants.P_LICENSE, licenseText);
		}
	}

	@Override
	public String getFrancaVersion() {
		return Platform.getBundle("org.franca.core").getVersion().toString();
	}

	public void listGeneratedFiles() {
		dumpGeneratedFiles = true;
	}

}

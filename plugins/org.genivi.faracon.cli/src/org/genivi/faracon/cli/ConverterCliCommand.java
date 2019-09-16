package org.genivi.faracon.cli;

import java.util.Collection;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.eclipse.core.runtime.Platform;
import org.genivi.faracon.console.CommandlineTool;
import org.genivi.faracon.preferences.Preferences;
import org.genivi.faracon.preferences.PreferencesConstants;

import com.google.inject.Inject;

public class ConverterCliCommand extends CommandlineTool {

	@Inject
	private Franca2AraConverter franca2AraConverter;
	@Inject
	private Ara2FrancaConverter ara2FrancaConverter;

	private Preferences preferences;

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
		
		// -ca --check ARXML files
		boolean checkArXmlFilesOnly = false;
		if(parsedArguments.hasOption("ca")) {
			getLogger().logInfo("Option \"ca\" set. Only the ARXML files will be checked. No tranformation will be executed.");
			checkArXmlFilesOnly = true;
		}

		List<String> commandLineArguments = parsedArguments.getArgList();
		for (String commandLineArgument : commandLineArguments) {
			getLogger().logWarning("Unexpected command line argument \"" + commandLineArgument + "\"");
		}

		String[] francaFilePaths = parsedArguments.getOptionValues('f');
		String[] araFilePaths = parsedArguments.getOptionValues('a');

		boolean haveFrancaInput = francaFilePaths != null && francaFilePaths.length > 0;
		boolean haveARAInput = araFilePaths != null && araFilePaths.length > 0;
		if (!haveFrancaInput && !haveARAInput) {
			getLogger().logError("At least one input model file has to be given!");
		}
		if (haveFrancaInput && haveARAInput) {
			getLogger().logWarning("A mix of FrancaIDL and Adaptive AUTOSAR input model files is given.");
		}

		// destination: -d --dest overwrite default output directory path
		if (parsedArguments.hasOption("d")) {
			setOutputDirectoryPath(parsedArguments.getOptionValue("d"));
		}

		// A file path, that points to a file, that contains the license text.
		// -L --license license text in generated files
		if (parsedArguments.hasOption("L")) {
			setLicenseText(parsedArguments.getOptionValue("L"));
		}

		getLogger().decreaseIndentationLevel();

		Collection<String> fidlFiles = FilePathsHelper.findFiles(francaFilePaths, "fidl");
		Collection<String> araFiles = FilePathsHelper.findFiles(araFilePaths, "arxml");

		if(checkArXmlFilesOnly) {
			setContinueOnErrors(true);
			int foundRemainingProxies = ara2FrancaConverter.loadFilesAndCheckProxies(araFiles);
			getLogger().logInfo("Found " + foundRemainingProxies + " unresolved objects in input files.");
			return foundRemainingProxies;
		}
		
		// Invoke the converters.
		this.convertARAFiles(araFiles);
		this.convertFrancaFiles(fidlFiles);

		return 0;
	}

	public void convertARAFiles(Collection<String> araFiles) {
		ara2FrancaConverter.convertFiles(araFiles);;
	}
	
	public void convertFrancaFiles(Collection<String> fidlFiles) {
		franca2AraConverter.convertFiles(fidlFiles);
	}

	public void setOutputDirectoryPath(String outputDirectoryPath) {
		String normalizedOutputDirectoryPath = ConverterHelper.normalize(outputDirectoryPath);
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

}

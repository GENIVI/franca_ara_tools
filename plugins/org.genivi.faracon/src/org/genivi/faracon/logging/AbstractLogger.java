package org.genivi.faracon.logging;

import java.util.Collections;

/**
 * This abstract class implements several basic logging features that are useful for most concrete loggers.
 */
public abstract class AbstractLogger implements ILogger {

	private boolean isLoggingInfos = true;
	private boolean isLoggingWarnings = true;
	private boolean isLoggingErrors = true;

	private boolean isWarningsAsErrors = false;

	private boolean isContinueOnErrors = false;
	public class StopOnErrorException extends RuntimeException {}

	private int indentationLevel = 0;
	private String indentationStepSpace = "   ";

	/**
	 * Enable or disable the logging of infos.
	 * @param enabled - true or false
	 */
	public void enableInfosLogging(boolean enabled) {
		isLoggingInfos = enabled;
	}

	/**
	 * Enable or disable the logging of warnings.
	 * @param enabled - true or false
	 */
	public void enableWarningsLogging(boolean enabled) {
		isLoggingWarnings = enabled;
	}

	/**
	 * Enable or disable the logging of errors
	 * @param enabled - true or false
	 */
	public void enableErrorsLogging(boolean enabled) {
		isLoggingErrors = enabled;
	}

	/**
	 * Enable or disable that the processing continues after an error has been reported.
	 * @param enabled - true or false
	 */
	public void enableContinueOnErrors(boolean enabled) {
		isContinueOnErrors = enabled;
	}

	/**
	 * Enable or disable that reported warnings are handled as errors.
	 * @param enabled - true or false
	 */
	public void enableWarningsAsErrors(boolean enabled) {
		isWarningsAsErrors = enabled;
	}

	/**
	 * Logs an information message.
	 * @param infoMessage - The message text.
	 */
	public void logInfo(String infoMessage) {
		if(isLoggingInfos) {
			logInfoImpl(infoMessage);
		}
	}

	/**
	 * A concrete logger class has to implement this method to log an information message in a specific way.
	 * @param infoMessage - The message text.
	 */
	abstract protected void logInfoImpl(String infoMessage);

	/**
	 * Logs a warning message.
	 * @param warningMessage - The message text.
	 */
	public void logWarning(String warningMessage) {
		if (isWarningsAsErrors) {
			logError(warningMessage);
		} else {
			if(isLoggingWarnings) {
				logWarningImpl(warningMessage);
			}
		}
	}

	/**
	 * A concrete logger class has to implement this method to log a warning message in a specific way.
	 * @param warningMessage - The message text.
	 */
	abstract protected void logWarningImpl(String warningMessage);

	/**
	 * Logs an error message.
	 * If 'continue on errors' is not enabled calling this method will also stop the program execution.
	 * @param errorMessage - The message text.
	 */
	public void logError(String errorMessage) {
		if(isLoggingErrors) {
			logErrorImpl(errorMessage);
		}
		if (!isContinueOnErrors) {
			throw new StopOnErrorException();
		}
	}

	/**
	 * A concrete logger class has to implement this method to log an error message in a specific way.
	 * @param errorMessage - The message text.
	 */
	abstract protected void logErrorImpl(String errorMessage);

	/**
	 * Sets the step space string for the indentation mechanism.
	 * Each message is prepended with indentation level repetitions of the indentation step space string.
	 * @param indentationStepSpace - The new step space string for the indentation mechanism.
	 */
	public void setIndentationStepSpace(String indentationStepSpace) {
		this.indentationStepSpace = indentationStepSpace;
	}
	
	/**
	 * Increases the current indentation level by one.
	 * The initial indentation level is 0.
	 * Each message is prepended with indentation level repetitions of the indentation step space string.
	 */
	public void increaseIndentationLevel() {
		indentationLevel++;
	}

	/**
	 * Increases the current indentation level by one.
	 * The initial indentation level is 0.
	 * The indentation level cannot be decreased to lower than 0.
	 * Each message is prepended with indentation level repetitions of the indentation step space string.
	 */
	public void decreaseIndentationLevel() {
		if (indentationLevel > 0) {
			indentationLevel--;
		}
	}

	/**
	 * Returns a string that consists of indentation level repetitions of the indentation step space string.
	 * The purpose of this indentation space string is to be prepended to each message.
	 */
	protected String indentationSpace() {
		return String.join("", Collections.nCopies(indentationLevel, indentationStepSpace));
	}

}

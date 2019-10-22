package org.genivi.faracon.logging;

/**
 * This interface provides a set of method signatures for logging specifically for the FARACON converter tool.
 */
public interface ILogger {

	/**
	 * Enable or disable the logging of infos.
	 * @param enabled - true or false
	 */
	public void enableInfosLogging(boolean enabled);

	/**
	 * Enable or disable the logging of warnings.
	 * @param enabled - true or false
	 */
	public void enableWarningsLogging(boolean enabled);

	/**
	 * Enable or disable the logging of errors
	 * @param enabled - true or false
	 */
	public void enableErrorsLogging(boolean enabled);

	/**
	 * Enable or disable that the processing continues after an error has been reported.
	 * @param enabled - true or false
	 */
	public void enableContinueOnErrors(boolean enabled);

	/**
	 * Enable or disable that reported warnings are handled as errors.
	 * @param enabled - true or false
	 */
	public void enableWarningsAsErrors(boolean enabled);

	/**
	 * Logs an information message.
	 * @param infoMessage - The message text.
	 */
	public void logInfo(String infoMessage);

	/**
	 * Logs a warning message.
	 * @param warningMessage - The message text.
	 */
	public void logWarning(String warningMessage);

	/**
	 * Logs an error message.
	 * If 'continue on errors' is not enabled calling this method will also stop the program execution.
	 * @param errorMessage - The message text.
	 */
	public void logError(String errorMessage);

	/**
	 * Sets the step space string for the indentation mechanism.
	 * Each message is prepended with indentation level repetitions of the indentation step space string.
	 * @param indentationStepSpace - The new step space string for the indentation mechanism.
	 */
	public void setIndentationStepSpace(String indentationStepSpace);
	
	/**
	 * Increases the current indentation level by one.
	 * The initial indentation level is 0.
	 * Each message is prepended with indentation level repetitions of the indentation step space string.
	 */
	public void increaseIndentationLevel();

	/**
	 * Increases the current indentation level by one.
	 * The initial indentation level is 0.
	 * The indentation level cannot be decreased to lower than 0.
	 * Each message is prepended with indentation level repetitions of the indentation step space string.
	 */
	public void decreaseIndentationLevel();

}

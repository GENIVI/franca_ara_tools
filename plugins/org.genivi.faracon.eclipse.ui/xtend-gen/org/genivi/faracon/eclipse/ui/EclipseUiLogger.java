package org.genivi.faracon.eclipse.ui;

import com.google.common.base.Objects;
import org.eclipse.core.runtime.Platform;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.MessageConsole;
import org.eclipse.ui.console.MessageConsoleStream;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.genivi.faracon.logging.AbstractLogger;

@SuppressWarnings("all")
public class EclipseUiLogger extends AbstractLogger {
  private static String FARACON_CONSOLE = "Faracon console";
  
  private final MessageConsoleStream infoStream;
  
  private final MessageConsoleStream errorStream;
  
  public EclipseUiLogger() {
    boolean _isRunning = Platform.isRunning();
    if (_isRunning) {
      this.infoStream = this.getConsole().newMessageStream();
      this.errorStream = this.getConsole().newMessageStream();
      this.errorStream.setActivateOnWrite(true);
    } else {
      this.infoStream = null;
      this.errorStream = null;
    }
  }
  
  private MessageConsole getConsole() {
    final IConsoleManager consoleManager = ConsolePlugin.getDefault().getConsoleManager();
    final Function1<IConsole, Boolean> _function = (IConsole it) -> {
      String _name = it.getName();
      return Boolean.valueOf(Objects.equal(_name, EclipseUiLogger.FARACON_CONSOLE));
    };
    IConsole faraconConsole = IterableExtensions.<IConsole>findFirst(((Iterable<IConsole>)Conversions.doWrapArray(consoleManager.getConsoles())), _function);
    if ((null == faraconConsole)) {
      MessageConsole _messageConsole = new MessageConsole(EclipseUiLogger.FARACON_CONSOLE, null);
      faraconConsole = _messageConsole;
      consoleManager.addConsoles(new IConsole[] { faraconConsole });
    }
    return ((MessageConsole) faraconConsole);
  }
  
  @Override
  protected void logErrorImpl(final String errorMessage) {
    boolean _canLog = this.canLog();
    if (_canLog) {
      this.errorStream.println(errorMessage);
    }
  }
  
  @Override
  protected void logInfoImpl(final String infoMessage) {
    boolean _canLog = this.canLog();
    if (_canLog) {
      this.infoStream.println(infoMessage);
    }
  }
  
  @Override
  protected void logWarningImpl(final String warningMessage) {
    this.logInfo(warningMessage);
  }
  
  private boolean canLog() {
    return (((((this.infoStream != null) && (this.errorStream != null)) && (!this.infoStream.isClosed())) && (!this.errorStream.isClosed())) && 
      PlatformUI.isWorkbenchRunning());
  }
}

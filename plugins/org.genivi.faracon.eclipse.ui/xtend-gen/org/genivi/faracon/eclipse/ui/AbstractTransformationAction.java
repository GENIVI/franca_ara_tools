package org.genivi.faracon.eclipse.ui;

import com.google.common.base.Objects;
import com.google.inject.Guice;
import com.google.inject.Injector;
import java.io.File;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.function.Consumer;
import org.eclipse.core.filesystem.EFS;
import org.eclipse.core.filesystem.IFileStore;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.IObjectActionDelegate;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.genivi.faracon.cli.ConverterCliCommand;
import org.genivi.faracon.cli.ConverterCliModule;
import org.genivi.faracon.eclipse.ui.EclipseUiLogger;
import org.genivi.faracon.eclipse.ui.FaraconPreferencesPage;
import org.genivi.faracon.logging.ILogger;
import org.genivi.faracon.preferences.PreferencesConstants;

@SuppressWarnings("all")
public abstract class AbstractTransformationAction implements IObjectActionDelegate {
  private ISelection selection;
  
  private ILogger logger;
  
  private final String fileExtension;
  
  protected ConverterCliCommand converter;
  
  public AbstractTransformationAction(final String fileExtension) {
    this.fileExtension = fileExtension;
  }
  
  protected Set<String> initConverterAndFindFile() {
    this.converter = this.initConverter();
    this.logger = this.converter.getLogger();
    final Collection<IFile> relevantIFiles = this.findRelevantFilesInSelection();
    final Function1<IFile, String> _function = (IFile it) -> {
      try {
        IFileStore _store = EFS.getStore(it.getLocationURI());
        NullProgressMonitor _nullProgressMonitor = new NullProgressMonitor();
        final File file = _store.toLocalFile(0, _nullProgressMonitor);
        return file.getAbsolutePath();
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    };
    final Iterable<String> filePaths = IterableExtensions.<IFile, String>map(relevantIFiles, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(filePaths);
    if (_isEmpty) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("No files with extension ");
      _builder.append(this.fileExtension);
      _builder.append(" selected. No transformation will be executed!");
      this.logger.logError(_builder.toString());
    }
    return IterableExtensions.<String>toSet(filePaths);
  }
  
  private Collection<IFile> findRelevantFilesInSelection() {
    if ((this.selection.isEmpty() || (!(this.selection instanceof StructuredSelection)))) {
      this.logger.logError("No elements selected. Transformation cannot be performed");
      return Collections.<IFile>emptyList();
    }
    final StructuredSelection structuredSelection = ((StructuredSelection) this.selection);
    final List selectedElements = structuredSelection.toList();
    final HashSet<IFile> relevantFiles = CollectionLiterals.<IFile>newHashSet();
    final Consumer<Object> _function = (Object it) -> {
      this.findRelevantFiles(it, relevantFiles);
    };
    selectedElements.forEach(_function);
    return relevantFiles;
  }
  
  protected void _findRelevantFiles(final Object object, final Set<IFile> relevantIFiles) {
    this.logger.logError(
      (((("Selection of element " + object) + " is not supported. Files contained in ") + object) + 
        " are not used for the transformation"));
  }
  
  protected void _findRelevantFiles(final IFile iFile, final Set<IFile> relevantIFiles) {
    String _fileExtension = null;
    if (iFile!=null) {
      _fileExtension=iFile.getFileExtension();
    }
    boolean _equals = Objects.equal(_fileExtension, this.fileExtension);
    if (_equals) {
      relevantIFiles.add(iFile);
    }
  }
  
  protected void _findRelevantFiles(final IContainer iFolder, final Set<IFile> relevantFiles) {
    try {
      final Consumer<IResource> _function = (IResource it) -> {
        this.findRelevantFiles(it, relevantFiles);
      };
      ((List<IResource>)Conversions.doWrapArray(iFolder.members())).forEach(_function);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  protected ConverterCliCommand initConverter() {
    ConverterCliModule _converterCliModule = new ConverterCliModule(EclipseUiLogger.class);
    final Injector injector = Guice.createInjector(_converterCliModule);
    final ConverterCliCommand converter = injector.<ConverterCliCommand>getInstance(ConverterCliCommand.class);
    this.setPreferences(converter);
    return converter;
  }
  
  private void setPreferences(final ConverterCliCommand converter) {
    final IEclipsePreferences preferences = FaraconPreferencesPage.getInstancePreferences();
    converter.setContinueOnErrors(Boolean.parseBoolean(preferences.get(PreferencesConstants.P_CONTINUE_ON_ERRORS, "false")));
    converter.setLogLevel(preferences.get(PreferencesConstants.P_LOGOUTPUT, PreferencesConstants.LOGLEVEL_VERBOSE));
    converter.setOutputDirectoryPath(preferences.get(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "./output"));
    converter.setWarningsAsErrors(Boolean.parseBoolean(preferences.get(PreferencesConstants.P_WARNINGS_AS_ERRORS, "false")));
  }
  
  @Override
  public void selectionChanged(final IAction action, final ISelection selection) {
    this.selection = selection;
  }
  
  @Override
  public void setActivePart(final IAction action, final IWorkbenchPart targetPart) {
  }
  
  public void findRelevantFiles(final Object iFile, final Set<IFile> relevantIFiles) {
    if (iFile instanceof IFile) {
      _findRelevantFiles((IFile)iFile, relevantIFiles);
      return;
    } else if (iFile instanceof IContainer) {
      _findRelevantFiles((IContainer)iFile, relevantIFiles);
      return;
    } else if (iFile != null) {
      _findRelevantFiles(iFile, relevantIFiles);
      return;
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(iFile, relevantIFiles).toString());
    }
  }
}

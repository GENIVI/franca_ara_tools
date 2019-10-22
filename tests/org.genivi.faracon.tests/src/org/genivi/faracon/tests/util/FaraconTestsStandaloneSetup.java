package org.genivi.faracon.tests.util;

import org.eclipse.xtext.ui.editor.DirtyStateManager;
import org.eclipse.xtext.ui.editor.IDirtyStateManager;
import org.eclipse.xtext.util.Modules2;
import org.franca.core.dsl.FrancaIDLTestsModule;
import org.franca.core.dsl.FrancaIDLTestsStandaloneSetup;
import org.genivi.faracon.cli.ConverterCliModule;
import org.genivi.faracon.console.ConsoleLogger;

import com.google.inject.Binder;
import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;

public class FaraconTestsStandaloneSetup extends FrancaIDLTestsStandaloneSetup {
	@Override
    public Injector createInjector() {
        return Guice.createInjector(Modules2.mixin(new ConverterCliModule(ConsoleLogger.class), new FrancaIDLTestsModule()));
    }

}

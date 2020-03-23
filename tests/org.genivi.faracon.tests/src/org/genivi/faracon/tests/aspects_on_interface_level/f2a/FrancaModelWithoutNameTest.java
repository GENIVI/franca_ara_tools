package org.genivi.faracon.tests.aspects_on_interface_level.f2a;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.logging.AbstractLogger.StopOnErrorException;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.genivi.faracon.tests.util.Franca2ARATestBase;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Tests the issue reported here:
 * https://github.com/GENIVI/franca_ara_tools/issues/148 The transformation did
 * not work if the FrancaModel does not have a name.
 *
 */
@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class FrancaModelWithoutNameTest extends Franca2ARATestBase {
	
	@Test(expected = StopOnErrorException.class)
	public void testFrancaModelWithoutName() {
		transformAndCheck("src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/", "simpleFrancaModelWithoutName",
				"src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/simpleFrancaModelWithoutName.arxml");
	}

}

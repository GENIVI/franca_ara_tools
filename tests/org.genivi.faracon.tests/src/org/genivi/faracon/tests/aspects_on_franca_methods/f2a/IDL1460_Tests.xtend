package org.genivi.faracon.tests.aspects_on_franca_methods.f2a

import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import autosar40.swcomponent.portinterface.ArgumentDataPrototype
import autosar40.swcomponent.portinterface.ClientServerOperation
import com.google.inject.Inject
import java.math.BigInteger
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FIntegerInterval
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.genivi.faracon.Franca2ARATransformation
import org.genivi.faracon.franca2ara.ARAModelSkeletonCreator
import org.genivi.faracon.franca2ara.ARAPrimitveTypesCreator
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertTrue

/**
 * The mapping of this feature is tested by instantiating concrete subclasses of 'FModelElement', 
 * converting these instances, and checking if the conversion results are of the AUTOSAR metatype 'Referrable'.
 *
 * Hierarchy of Franca metaclasses below 'FModelElement':
 *    FModelElement            {abstract}
 *       FBroadcast
 *       FEvaluableElement     {abstract}
 *          FEnumerator
 *          FTypedElement      {abstract}
 *             FArgument
 *             FAttribute
 *             FConstantDef    {IGNORE (A18)}
 *             FDeclaration    {IGNORE (A20)}
 *             FField
 *             FVariable       {IGNORE}
 *       FMethod
 *       FState                {IGNORE (A20)}
 *       FType                 {abstract}
 *          FArrayType
 *          FCompoundType      {abstract}
 *             FStructType
 *             FUnionType
 *          FEnumerationType
 *          FIntegerInterval   {ERROR}
 *          FMapType
 *          FTypeDef
 *       FTypeCollection
 *          FInterface
 *
 * But not all subclasses of 'FModelElement' are appropriate for such tests:
 *  - Abstract subclasses cannot be instantiated.
 *  - Metaclasses which are specified to be ignored will never have an according conversion implementation.
 *  - Metaclasses which are specified to cause an error can be tested with tests that expect an exception to be thrown.
 *
 */
@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FaraconTestsInjectorProvider))
class IDL1460_Tests extends Franca2ARATestBase {

	@Inject
	var Franca2ARATransformation franca2ARATransformation

	@Inject
	var ARATypeCreator araTypeCreator

	@Inject
	var ARAPrimitveTypesCreator araPrimitveTypesCreator

	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	
	@Before
	def void beforeTest(){
		araPrimitveTypesCreator.createPrimitiveTypesPackage(null)
		logger.enableContinueOnErrors(false)
	}
	

	@Test
	def void broadcastConversion() {
		val FBroadcast fBroadcast = francaFac.createFBroadcast
		val FInterface fParentInterface = francaFac.createFInterface => [
			broadcasts += fBroadcast
		]
		val ARPackage arInterfacePackage = araFac.createARPackage
		val VariableDataPrototype variableDataPrototype = franca2ARATransformation.transform(fBroadcast, fParentInterface, arInterfacePackage)
		checkAbstractBaseClasses(fBroadcast, variableDataPrototype)
	}

	@Test
	def void enumeratorConversion() {
		val FEnumerator fEnumerator = francaFac.createFEnumerator
		//TODO: Transform enumerator (transformation not implemented yet) and check abstract base classes.
		//checkAbstractBaseClasses(fEnumerator, )
	}

	@Test
	def void argumentConversion() {
		val FArgument fArgument = francaFac.createFArgument => [
			type = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FInterface fParentInterface = francaFac.createFInterface
		val ArgumentDataPrototype argumentDataPrototype = franca2ARATransformation.transform(fArgument, true, fParentInterface)
		checkAbstractBaseClasses(fArgument, argumentDataPrototype)
	}

	@Test
	def void attributeConversion() {
		val FAttribute fAttribute = francaFac.createFAttribute => [
			type = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FInterface fParentInterface = francaFac.createFInterface => [
			attributes += fAttribute
		]
		val Field field = franca2ARATransformation.transform(fAttribute, fParentInterface)
		checkAbstractBaseClasses(fAttribute, field)
	}

	@Test
	def void fieldConversion() {
		val FField fField = francaFac.createFField => [
			type = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			] 				
		]
		val FStructType fStructType = francaFac.createFStructType => [
			elements += fField
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fStructType
			]
		]
		createAutosarModelSkeleton(fModel)
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fStructType)
		for(subElement : (autosarDataType as ImplementationDataType).subElements) {
			checkAbstractBaseClasses(fField, subElement)
		}
	}

	@Test
	def void methodConversion() {
		val FMethod fMethod = francaFac.createFMethod
		val FInterface fParentInterface = francaFac.createFInterface => [
			methods += fMethod
		]
		val ClientServerOperation clientServerOperation = franca2ARATransformation.transform(fMethod, fParentInterface)
		checkAbstractBaseClasses(fMethod, clientServerOperation)
	}

	@Test
	def void arrayConversion() {
		val FArrayType fArrayType = francaFac.createFArrayType => [
			elementType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
				interval = francaFac.createFIntegerInterval => [
					lowerBound = new BigInteger("1")
					upperBound = new BigInteger("10")
				]
			]
		]
		//TODO: Transform array type (transformation of named array types is not implemented yet) and check abstract base classes.
		//checkAbstractBaseClasses(fArrayType, )
	}

	@Test
	def void structConversion() {
		val FStructType fStructType = francaFac.createFStructType
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fStructType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fStructType)
		checkAbstractBaseClasses(fStructType, autosarDataType)
	}

	@Test
	def void unionConversion() {
		val FUnionType fUnionType = francaFac.createFUnionType
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fUnionType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fUnionType)
		checkAbstractBaseClasses(fUnionType, autosarDataType)
	}

	@Test
	def void enumerationConversion() {
		val FEnumerationType fEnumerationType = francaFac.createFEnumerationType
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fEnumerationType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fEnumerationType)
		checkAbstractBaseClasses(fEnumerationType, autosarDataType)
	}

	@Test(expected = AbstractLogger.StopOnErrorException)
	def void integerIntervalConversion() {
		val FIntegerInterval fIntegerInterval = francaFac.createFIntegerInterval => [
			lowerBound = new BigInteger("-19")
			upperBound = new BigInteger("972")
		]
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fIntegerInterval)
		checkAbstractBaseClasses(fIntegerInterval, autosarDataType)
	}

	@Test
	def void mapConversion() {
		val FMapType fMapType = francaFac.createFMapType => [
			keyType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
			valueType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fMapType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fMapType)
		checkAbstractBaseClasses(fMapType, autosarDataType)
	}

	@Test
	def void typeDefConversion() {
		val FTypeDef fTypeDef = francaFac.createFTypeDef => [
			actualType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fTypeDef
			]
		]
		fModel.createAutosarModelSkeleton
		//TODO: Transform typedef type (transformation is not implemented yet) and check abstract base classes.
		//val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fTypeDef)
		//checkAbstractBaseClasses(fTypeDef, autosarDataType)
	}

	@Test
	def void typeCollectionConversion() {
		val FTypeCollection fTypeCollection = francaFac.createFTypeCollection
		val ARPackage arPackage = araFac.createARPackage
		//TODO: Transform type vollection (transformation is not implemented yet) and check abstract base classes.
		//checkAbstractBaseClasses(fTypeCollection, )
	}

	@Test
	def void interfaceConversion() {
		val FInterface fInterface = francaFac.createFInterface
		createFModel => [
			//create fModel and add the interface to it as interfaces need to be contained in an FModel
			it.interfaces += fInterface
			it.name = "Test"
		]
		val ServiceInterface serviceInterface = franca2ARATransformation.transform(fInterface)
		checkAbstractBaseClasses(fInterface, serviceInterface)
	}

	def void checkAbstractBaseClasses(FModelElement fModelElement, Referrable referrable) {
		assertTrue((fModelElement === null && referrable === null) || (fModelElement !== null && referrable !== null))
	}

}

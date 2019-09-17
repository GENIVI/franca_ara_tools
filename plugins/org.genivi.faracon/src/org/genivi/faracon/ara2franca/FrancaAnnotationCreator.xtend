package org.genivi.faracon.ara2franca

import com.google.inject.Singleton
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FModelElement
import org.genivi.faracon.ARA2FrancaBase

@Singleton
class FrancaAnnotationCreator extends ARA2FrancaBase {

	def void addFrancaAnnotation(FModelElement fModelElement, String annotationLabel, String annotationText) {
		val francaAnnotation = createFAnnotation => [
			type = FAnnotationType.SOURCE_ALIAS
			comment = "Faracon: " + annotationLabel + ": " + annotationText
		]
		fModelElement.ensureFAnnotationBlock.elements.add(francaAnnotation)
	}

	def void addExperimentalArraySizeAnnotation(FArrayType fArrayType, String arraySize) {
		val francaAnnotation = createFAnnotation => [
			type = FAnnotationType.EXPERIMENTAL
			comment = "Faracon: " + "fixed array size = " + arraySize
		]
		fArrayType.ensureFAnnotationBlock.elements.add(francaAnnotation)

	}

	private def ensureFAnnotationBlock(FModelElement fModelElement) {
		if (fModelElement.comment === null) {
			fModelElement.comment = createFAnnotationBlock
		}
		return fModelElement.comment
	}

}

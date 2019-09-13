package org.genivi.faracon.ara2franca

import com.google.inject.Singleton
import org.franca.core.franca.FModelElement
import org.genivi.faracon.ARA2FrancaBase
import org.franca.core.franca.FAnnotationType

@Singleton
class FrancaAnnotationCreator extends ARA2FrancaBase {

	def void addFrancaAnnotation(FModelElement fModelElement, String annotationLabel, String annotationText) {
		val francaAnnotation = createFAnnotation =>[
			type = FAnnotationType.SOURCE_ALIAS
			comment = "Faracon: " + annotationLabel + ": " + annotationText
		]
		if(fModelElement.comment === null){
			fModelElement.comment = createFAnnotationBlock
		}
		fModelElement.comment.elements.add(francaAnnotation)
	}

}

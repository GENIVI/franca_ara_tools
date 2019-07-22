package org.genivi.faracon

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Accessors
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.franca.FModel

/**
 * Franca container, that can hold mutiple franca model container itself
 * Extends FrancaModelContainer in order to allow use of the 
 * Franca model container interfaces. 
 */
class FrancaMultiModelContainer extends FrancaModelContainer {

	@Accessors
	val Collection<FrancaModelContainer> francaModelContainers
	
	new(Collection<FModel> francaModels) {
		super(francaModels.isNullOrEmpty ? null : francaModels.get(0))
		francaModelContainers = francaModels.map[new FrancaModelContainer(it)].toList
	}

}

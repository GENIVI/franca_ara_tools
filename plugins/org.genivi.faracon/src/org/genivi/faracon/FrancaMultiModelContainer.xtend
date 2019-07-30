package org.genivi.faracon

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Accessors
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.franca.FModel

/**
 * Franca container, that can hold mutiple franca model container itself
 * Extends FrancaModelContainer in order to allow use of the 
 * Franca model container interfaces. 
 * 
 * Note: originally the FrancaModelContainer is not made to hold multiple franca files.
 * However, in oder to deal with multiple franca models easily this class allows dealing with multiple models.
 * This might be confusing a bit, but in order to implement dealing with multiple models correctly, 
 * we would need to change the Franca API.
 */
class FrancaMultiModelContainer extends FrancaModelContainer {

	@Accessors
	val Collection<FrancaModelContainer> francaModelContainers

	new(Collection<FModel> francaModels) {
		super(if(francaModels.isNullOrEmpty) null else francaModels.get(0))
		francaModelContainers = francaModels.map[new FrancaModelContainer(it)].toList
	}

}

package org.genivi.faracon.logging;

import com.google.inject.Inject;

public abstract class BaseWithLogger {

	@Inject
	private ILogger logger;
	
	public ILogger getLogger() {
		return logger;
	}

}

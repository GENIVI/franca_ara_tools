package org.genivi.faracon.tests.util

import java.util.Collection
import static org.junit.Assert.assertEquals

class AssertHelper {
	private new(){}
	
	def static <T> T assertOneElement(Collection<T> elements){
		return elements.assertElements(1).get(0)
	}
	
	def static <T> Collection<T> assertElements(Collection<T> elements, int expectedElements){
		assertEquals("Wrong number of expected elements in collection " + elements, expectedElements, elements.size)
		return elements
	} 
}
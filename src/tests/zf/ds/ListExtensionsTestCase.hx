package tests.zf.ds;

import zf.tests.TestCase;
import zf.ds.ListExtensions;

class ListExtensionsTestCase extends TestCase {
	function test_listextensions_slice() {
		var list = new List<Int>();
		for (i in 0...100) {
			list.add(i);
		}
		var arr = ListExtensions.toArray(list);
		for (i in 0...100) {
			assertEqual(i, arr[i]);
		}
		assertEqual(arr.length, 100);

		var sliced = ListExtensions.slice(list, 0, 40);
		for (i in 0...40) {
			assertEqual(i, sliced[i]);
		}
		assertEqual(sliced.length, 40);

		var sliced = ListExtensions.slice(list, 10, 40);
		for (i in 0...30) {
			assertEqual(i + 10, sliced[i]);
		}
		assertEqual(sliced.length, 30);
	}
}

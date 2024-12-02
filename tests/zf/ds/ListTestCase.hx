package tests.zf.ds;

import zf.ds.List;

import zf.Assert;

class ListTestCase extends TestCase {
	public static final Name = "ListTestCase";

	override public function get_name(): String {
		return Name;
	}

	override public function run() {
		testBasic();
	}

	public function testBasic() {
		final list = new List<Int>();
		list.add(3);
		list.add(5);
		list.push(1);

		final arr = list.toArray();
		Assert.assert(arr[0] == 1);
		Assert.assert(arr[1] == 3);
		Assert.assert(arr[2] == 5);
		Assert.assert(list.length == 3);

		list.add(3);

		final arr = list.toArray();
		Assert.assert(arr[0] == 1);
		Assert.assert(arr[1] == 3);
		Assert.assert(arr[2] == 5);
		Assert.assert(arr[3] == 3);
		Assert.assert(list.length == 4);

		final l = list.map((x) -> { return x + 1; });
		final arr = l.toArray();
		Assert.assert(arr[0] == 2);
		Assert.assert(arr[1] == 4);
		Assert.assert(arr[2] == 6);
		Assert.assert(arr[3] == 4);
		Assert.assert(l.length == 4);

		trace(l.join("."));
		trace(l.toString());

		list.remove(3);

		final arr = list.toArray();
		Assert.assert(arr[0] == 1);
		Assert.assert(arr[1] == 5);
		Assert.assert(arr[2] == 3);
		Assert.assert(list.length == 3);

		list.push(3);
		list.removeLast(3);

		final arr = list.toArray();
		Assert.assert(arr[0] == 3);
		Assert.assert(arr[1] == 1);
		Assert.assert(arr[2] == 5);
		Assert.assert(list.length == 3);

		list.pop();

		final arr = list.toArray();
		Assert.assert(arr[0] == 1);
		Assert.assert(arr[1] == 5);
		Assert.assert(list.length == 2);

	}
}


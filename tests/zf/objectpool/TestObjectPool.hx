package tests.zf.objectpool;

import zf.Assert;

using zf.ds.ArrayExtensions;

class TestObjectPool extends TestCase {
	public static final Name = "TestObjectPool";

	override public function get_name(): String {
		return Name;
	}

	override public function run() {
		testPool1();
		testPool2();
		testPool3();
		testPool4();
		testPool5();
	}

	function testPool1() {
		final o1 = Object1.alloc();

		Assert.assert(o1 != null);

		o1.xInt = 5;
		o1.dispose();

		// ensure that o1.xInt is set to 0
		Assert.assert(o1.xInt == 0);

		@:privateAccess Assert.assert(Object1.__pool__ == o1);

		final o2 = Object1.alloc();

		// ensure we got back the same object
		Assert.assert(o1 == o2);
	}

	/**
		testPool2/testPool3/testPool4 are the same except

		testPool2 - dispose method is not defined.
		testPool3 - dispose method is defined.
		testPool4 - child class of an object with pool
	**/
	function testPool2() {
		final o = Object2.alloc();

		o.object1 = Object1.alloc();

		final o1 = o.object1;

		o1.xInt = 5;
		o.xInt = 6;
		o.xArr.push(3);

		o.dispose();

		Assert.assert(o.object1 == null);
		Assert.assert(o.xInt == 0);
		Assert.assert(o.xArr.length == 0);
		Assert.assert(o1.xInt == 0);
	}

	function testPool3() {
		final o = Object3.alloc();

		o.object1 = Object1.alloc();

		final o1 = o.object1;

		o1.xInt = 5;
		o.xInt = 6;
		o.xArr.push(3);

		o.dispose();

		Assert.assert(o.object1 == null);
		Assert.assert(o.xInt == 0);
		Assert.assert(o.xArr.length == 0);
		Assert.assert(o1.xInt == 0);
	}

	function testPool4() {
		final o = Object4.alloc();

		o.object1 = Object1.alloc();

		final o1 = o.object1;

		o1.xInt = 5;
		o.xInt = 6;
		o.xArr.push(3);

		o.dispose();

		Assert.assert(o.object1 == null);
		Assert.assert(o.xInt == 0);
		Assert.assert(o.xArr.length == 0);
		Assert.assert(o1.xInt == 0);
	}

	function testPool5() {
		final o = Object5.alloc();

		o.object1 = Object1.alloc();

		o.obj1Arr1 = [];
		o.obj1Arr1.push(Object1.alloc());
		o.obj1Arr1.push(Object1.alloc());

		var obj1Arr1 = o.obj1Arr1;
		var obj1Arr1_0 = o.obj1Arr1[0];
		var obj1Arr1_1 = o.obj1Arr1[1];

		obj1Arr1_0.xInt = 100;
		obj1Arr1_1.xInt = 200;

		o.obj1Arr2 = [];
		o.obj1Arr2.push(Object1.alloc());
		o.obj1Arr2.push(Object1.alloc());

		var obj1Arr2 = o.obj1Arr2;
		var obj1Arr2_0 = o.obj1Arr2[0];
		var obj1Arr2_1 = o.obj1Arr2[1];

		o.obj1Arr3 = [];
		o.obj1Arr3.push(Object1.alloc());
		o.obj1Arr3.push(Object1.alloc());

		var obj1Arr3 = o.obj1Arr3;
		var obj1Arr3_0 = o.obj1Arr3[0];
		var obj1Arr3_1 = o.obj1Arr3[1];

		obj1Arr3_0.xInt = 100;
		obj1Arr3_1.xInt = 200;

		final o1 = o.object1;

		o1.xInt = 5;
		Assert.assert(o1.xInt == 5);

		o.xInt = 6;
		o.xInt2 = 12;
		o.eValue = V2;
		o.xArr.push(3);

		o.dispose();

		Assert.assert(o.object1 == null);
		Assert.assert(o.xInt == 0);
		Assert.assert(o.xInt2 == 5);
		Assert.assert(o.xArr.length == 0);
		Assert.assert(o.eValue == V1);
		// ensure o1 isn't disposed
		Assert.assert(o1.xInt == 5);
		@:privateAccess Assert.assert(Object1.__pool__ != o1);

		Assert.assert(obj1Arr1_0.xInt == 0);
		Assert.assert(obj1Arr1_1.xInt == 0);
		Assert.assert(obj1Arr1.length == 0);
		Assert.assert(o.obj1Arr1 != null);
		Assert.assert(o.obj1Arr1.length == 0);

		Assert.assert(obj1Arr2_0.xInt == 0);
		Assert.assert(obj1Arr2_1.xInt == 0);
		Assert.assert(obj1Arr2.length == 0);
		Assert.assert(o.obj1Arr2 == null);

		// Assert that setting will not clear the array
		Assert.assert(obj1Arr3_0.xInt == 100);
		Assert.assert(obj1Arr3_1.xInt == 200);
		Assert.assert(obj1Arr3.length == 2);
		Assert.assert(o.obj1Arr3 == null);
	}
}

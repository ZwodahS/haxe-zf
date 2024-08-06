package tests.zf.serialisetest;
using zf.ds.ArrayExtensions;

class TestSerialise extends TestCase {
	public static final Name = "TestObjectPool";

	override public function get_name(): String {
		return Name;
	}

	override public function run() {
		test1();
	}

	function test1() {
		final obj1 = new Object1();
		obj1.x = 3;
		obj1.mapInt = new Map<String, Int>();
		obj1.mapInt.set("hello", 3);
		obj1.mapInt.set("world", 4);
		obj1.o2 = new Object2("o2_1");
		obj1.o3 = new Object3("o3_1");
		obj1.arrO2 = [new Object2("o2_2"), new Object2("o2_3")];
		obj1.arrO3 = [new Object3("o3_2"), new Object3("o3_3")];

		final ctx = new SerialiseContext();
		var data = obj1.toStruct(ctx);

		Assert.assert(data.x == 3);
		Assert.assert(data.arrInt == null);
		Assert.assert(data.mapInt.hello == 3);
		Assert.assert(data.mapInt.world == 4);
		Assert.assert(data.o2 == "o2_1");
		Assert.assert(data.o3.id == "o3_1");
		Assert.assert(data.arrO2[0] == "o2_2");
		Assert.assert(data.arrO2[1] == "o2_3");
		Assert.assert(data.arrO3[0] != "o3_2");
		Assert.assert(data.arrO3[1] != "o3_3");

		obj1.arrInt = [3, 4];

		data = obj1.toStruct(ctx);
		Assert.assert(data.arrInt != null);
		Assert.assert(data.arrInt.length == 2);
		Assert.assert(data.arrInt[0] == 3);
		Assert.assert(data.arrInt[1] == 4);

		obj1.arrInt.push(5);
		// ensure that it does not changed
		Assert.assert(data.arrInt.length == 2);

		data = obj1.toStruct(ctx);

		final obj2 = new Object1();
		obj2.loadStruct(ctx, data);

		Assert.assert(obj1.x == obj2.x);
		Assert.assert(obj1.arrInt.length == obj2.arrInt.length);
		Assert.assert(obj1.arrInt.isEqual(obj2.arrInt));


	}
}
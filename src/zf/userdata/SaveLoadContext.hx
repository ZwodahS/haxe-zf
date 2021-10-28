package zf.userdata;

/**
	Context for saving and loading
**/
class SaveLoadContext {
	public final objects: Map<String, Identifiable>;

	/**
		A class list that are used to create object.

		We could just use Type.getClassName(Type.getClass(...)) and use Type.resolveClass(...)
		However, that might break when we move files around, and that is a bad way to handling save file.
		This allow us to register an id -> class for save loading.

		The way this is done is via having a static TypeName in the class.
		If this is not present, then Type.getClassName is used.
	**/
	public final classes: Map<String, Class<Dynamic>>;

	public function new() {
		this.objects = new Map<String, Identifiable>();
		this.classes = new Map<String, Class<Dynamic>>();
	}

	public function add(i: Identifiable): String {
		final id = i.identifier();
		this.objects[id] = i;
		return id;
	}

	public function get(i: String): Identifiable {
		return this.objects[i];
	}

	public function registerClass(c: Class<Dynamic>): String {
		final name = getTypeName(c);
		this.classes[name] = c;
		return name;
	}

	public function resolveClass(name: String): Class<Dynamic> {
		return this.classes[name];
	}

	public function getTypeName(c: Class<Dynamic>): String {
		var name = Reflect.field(c, "TypeName");
		if (name == null) name = Type.getClassName(c);
		return name;
	}
}

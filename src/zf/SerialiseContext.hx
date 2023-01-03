package zf;

class SerialiseContext {
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

	/**
		Store messages from the current saving or loading
	**/
	public var messages: Array<String>;

	/**
		Store warning messages from the current saving or loading
	**/
	public var warnings: Array<String>;

	/**
		Store errors from the current saving or loading
	**/
	public var errors: Array<String>;

	/**
		Flag to denote if the save or load is successful
	**/
	public var success: Bool = true;

	public function new() {
		this.objects = new Map<String, Identifiable>();
		this.classes = new Map<String, Class<Dynamic>>();
		this.messages = [];
		this.warnings = [];
		this.errors = [];
	}

	/**
		Add an identifiable to the context
	**/
	public function add(i: Identifiable): String {
		final id = i.identifier();
		this.objects[id] = i;
		return id;
	}

	/**
		Get item out of context
	**/
	public function get(i: String): Identifiable {
		return this.objects[i];
	}

	/**
		Register a class
	**/
	public function registerClass(c: Class<Dynamic>): String {
		final name = getTypeName(c);
		this.classes[name] = c;
		return name;
	}

	/**
		Resolve a class
	**/
	public function resolveClass(name: String): Class<Dynamic> {
		return this.classes[name];
	}

	public function getTypeName(c: Class<Dynamic>): String {
		var name = Reflect.field(c, "TypeName");
		if (name == null) name = Type.getClassName(c);
		return name;
	}
}

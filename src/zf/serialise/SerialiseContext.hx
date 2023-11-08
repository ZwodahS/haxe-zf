package zf.serialise;

/**
	@stage:stable
**/
class SerialiseContext {
	public final objects: Map<String, Identifiable>;

	/**
		Flag to denote if the save or load is successful
	**/
	public var success: Bool = true;

	public function new() {
		this.objects = new Map<String, Identifiable>();
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
}

package zf.ui.builder;

/**
	Build static h2d.Object from xml/struct
	Unlike domkit, this will not have any css.
	This should be used only to generate static object that doesn't change, i.e. help screen etc.
**/
class Builder {
	/**
		Store all the components that are registered in the builder
	**/
	public var components: Map<String, Component>;

	/**
		Registered fonts that can be used / referenced from other template
	**/
	var fonts: Map<String, h2d.Font>;

	/**
		Default font if all else fails
	**/
	public var defaultFont: h2d.Font;

	/**
		Registered colors
	**/
	var colors: Map<String, Color>;

	public var res: ResourceManager = null;

	public function new(registerDefaultComponents = true) {
		this.components = new Map<String, Component>();
		this.fonts = new Map<String, h2d.Font>();
		this.colors = new Map<String, Color>();
		this.defaultFont = hxd.res.DefaultFont.get();

		CompileTime.importPackage("zf.ui.builder.components");
		if (registerDefaultComponents) {
			final classes = CompileTime.getAllClasses("zf.ui.builder.components", true, Component);
			for (c in classes) {
				registerComponent(Type.createInstance(c, []));
			}
		}
	}

	// ---- Setup methods ---- //

	/**
		Register a component to be used.
		If duplicates are found, the earlier ones will be override
	**/
	public function registerComponent(component: Component) {
#if debug
		if (this.components[component.type] != null) {
			Logger.debug('Existing Component found for ${component.type}', "[UIBuilder]");
		}
		Logger.debug('Builder Component: ${component} registered as "${component.type}"', "[UIBuilder]");
#end
		this.components[component.type] = component;
	}

	inline public function registerFont(name: String, font: h2d.Font) {
		this.fonts[name] = font;
	}

	inline public function registerColor(name: String, color: Color) {
		this.colors[name] = color;
	}

	// ---- Various building method  ---- //

	/**
		Make object from a XML String.
	**/
	public function makeObjectFromXMLString(xmlString: String, context: BuilderContext = null): h2d.Object {
		final xml = Xml.parse(xmlString);
		final element = xml.firstElement();
		return makeObjectFromXMLElement(element, context);
	}

	/**
		Make object from XML element
	**/
	public function makeObjectFromXMLElement(element: Xml, context: BuilderContext = null): h2d.Object {
		// create context if not exists
		if (context == null) context = {};
		// set builder
		context.builder = this;

		if (element.nodeType != Element) return null;
		final comp = this.components[element.nodeName];
		if (comp == null) return null;
		var obj = comp.makeFromXML(element, context);
		if (element.get("id") != null) obj.name = element.get("id");
		return obj;
	}

	/**
		Make object from component struct
	**/
	public function makeObjectFromStruct(conf: ComponentConf, context: BuilderContext = null): h2d.Object {
		// create context if not exists
		if (context == null) context = {};
		// set builder
		context.builder = this;

		final comp = this.components[conf.type];
		if (comp == null) return null;
		final object = comp.makeFromStruct(conf.conf, context);
		if (conf.id != null) object.name = conf.id;
		return object;
	}

	// ---- Methods for getting predefined configurations, i.e fonts,colors etc ---- //

	/**
		Get a predefined font by name
	**/
	inline public function getFont(name: String): h2d.Font {
		if (this.fonts.exists(name)) return this.fonts[name];
		return this.defaultFont;
	}

	/**
		Get a predefined color by name
	**/
	inline public function getColor(name: String): Color {
		return this.colors.exists(name) ? this.colors[name] : 0xFFFFFF;
	}

	public function parseColorString(cs: String): Color {
		final parsed = Std.parseInt(cs);
		if (parsed != null) return parsed;
		return getColor(cs);
	}

	/**
		A function to format all display strings.
	**/
	dynamic public function formatString(str: String, context: BuilderContext): String {
		return str;
	}
}

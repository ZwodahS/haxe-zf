package zf.ui.builder;

import zf.resources.ResourceManager;

/**
	@stage:stable

	Wed 15:55:50 03 May 2023
	Dev Note:
	UI Builder. This is very similar to domkit.
	I started this as a static UI builder, but slowly it becomes more like domkit.
	Honestly, at this point I should just switch to domkit, but I haven't really find this lacking.
	Any time I need new feature, I could just add in.
**/
class Builder {
	/**
		Store all the components that are registered in the builder
	**/
	public var components: Map<String, Component>;

	/**
		Registered colors
	**/
	var colors: Map<String, Color>;

	public var res: ResourceManager = null;

	public function new(registerDefaultComponents = true) {
		this.components = new Map<String, Component>();
		this.colors = new Map<String, Color>();

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

	inline public function registerColor(name: String, color: Color) {
		this.colors[name] = color;
	}

	// ---- Various building method  ---- //

	/**
		Overloaded make method
	**/
	public function make(xmlString: String = null, element: Xml = null, struct: ComponentConf = null,
			context: BuilderContext = null): h2d.Object {
		if (xmlString != null) {
			return makeObjectFromXMLString(xmlString, context);
		} else if (element != null) {
			return makeObjectFromXMLElement(element, context);
		} else if (struct != null) {
			return makeObjectFromStruct(struct, context);
		}
		return null;
	}

	/**
		Make object from a XML String.
	**/
	public function makeObjectFromXMLString(xmlString: String, context: BuilderContext = null): h2d.Object {
		if (xmlString == null) return null;
		final xml = Xml.parse(xmlString);
		final element = xml.firstElement();
		return makeObjectFromXMLElement(element, context);
	}

	/**
		Make object from XML element
	**/
	public function makeObjectFromXMLElement(element: Xml, context: BuilderContext = null): h2d.Object {
		if (element == null) return null;
		// create context if not exists
		if (context == null) context = {};
		// set builder
		context.builder = this;

		if (element.nodeType != Element) return null;
		final comp = this.components[element.nodeName];
		if (comp == null) return null;
		var obj = comp.makeFromXML(element, context);
		if (obj != null && element.get("id") != null) obj.name = element.get("id");
		return obj;
	}

	/**
		Make object from component struct
	**/
	public function makeObjectFromStruct(conf: ComponentConf, context: BuilderContext = null): h2d.Object {
		if (conf == null) return null;
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

	public function fromFile(path: String, context: Dynamic): h2d.Object {
		/**
			Quick way to create object from file
		**/
		try {
			final xml = this.res.getStringFromPath(path);
			final builderContext = Std.isOfType(context, BuilderContext) ? cast context : new BuilderContext(context);
			final object = make(xml, builderContext);
			return object;
		} catch (e) {
			zf.Logger.error(path);
			zf.Logger.exception(e);
			return null;
		}
	}

	// ---- Methods for getting predefined configurations, i.e fonts,colors etc ---- //

	/**
		Get a predefined font by name
	**/
	dynamic public function getFont(name: String): h2d.Font {
		return hxd.res.DefaultFont.get().clone();
	}

	/**
		Get a predefined color by name
	**/
	dynamic public function getColor(name: String): Color {
		return 0xFFFFFF;
	}

	public function parseColorString(cs: String): Color {
		final parsed = Std.parseInt(cs);
		if (parsed != null) return parsed;
		return getColor(cs);
	}

	/**
		Get a haxe Template
	**/
	dynamic public function getStringTemplate(id: String): haxe.Template {
		return null;
	}

	dynamic public function getString(id: String, context: Dynamic): String {
		return null;
	}

	/**
		A function to format all display strings.
	**/
	dynamic public function formatString(str: String, context: BuilderContext): String {
		return str;
	}

	/**
	**/
	dynamic public function getBitmap(conf: zf.Access): h2d.Object {
		if (this.res == null) return null;
		final path = conf.getString("path");
		final index = conf.getInt("index", 0);
		return this.res.getBitmap(path, index);
	}
}

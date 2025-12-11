package zf.ui.builder;

import zf.resources.ResourceManager;

/**
	# Motivation
	Creating UI is tedious, and it is easier if it is easy to do it via XML.

	This is similar to domkit but it was not created to replace domkit, at least not initially.
	It just grew to become similar.

	# How it works.
	Builder need register all the Components that can be build.
	@see zf.ui.builder.Component

	The default components in zf.ui.builder.components are automatically loaded.
	These component are used to create heaps object, like h2d.Flow, h2d.Text etc.

	Custom components can be registered by extending zf.ui.builder.Component and registering them in the Builder.

	Once this is done, h2d.Object can be created by calling `make`.

	## XmlContainer
	The second way that this can be used is to create a XmlContainer.
	@see zf.ui.builder.XmlContainer for more details.

	By extending from XmlContainer, an object can be created using SRC variable or from file.
	The macro then provide access to the different inner object.

	XmlContainer is not registered with the builder, and can only be created with alloc.
	However, we can create a custom Component that help us make XmlContainer.
**/
class Builder {
	/**
		Store all the components that are registered in the builder
	**/
	public var components: Map<String, Component>;

	public var res: ResourceManager = null;

	public function new(registerDefaultComponents = true) {
		this.components = new Map<String, Component>();

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

	public function fromString(string: String, context: Dynamic): h2d.Object {
		try {
			final builderContext = context is BuilderContext ? cast context : new BuilderContext(context);
			final object = make(string, builderContext);
			return object;
		} catch (e) {
			zf.Logger.error(string);
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
		Get a bitmap for the builder.
		Requires "path" and "index" (default 0)
	**/
	dynamic public function getBitmap(conf: zf.Access): h2d.Object {
		if (this.res == null) return null;
		final path = conf.getString("path");
		final index = conf.getInt("index", 0);
		return this.res.getBitmap(path, index);
	}

	dynamic public function getAnim(conf: zf.Access): h2d.Anim {
		if (this.res == null) return null;
		final path = conf.getString("path");
		return this.res.getAnim(path);
	}

	/**
		Get a ScaleGridFactory factory
	**/
	dynamic public function getScaleGridFactory(id: String): ScaleGridFactory {
		if (this.res == null) return null;
		return this.res.getScaleGridFactory(id);
	}

	dynamic public function fromColor(color: Color, width: Float, height: Float): h2d.Bitmap {
		final t = h2d.Tile.fromColor(color, 1, 1);
		final bitmap = new h2d.Bitmap(t);
		bitmap.width = width;
		bitmap.height = height;
		return bitmap;
	}
}

/**
	Fri 14:17:26 13 Jun 2025
	It is more likely than not, moving forward we will be using XML over struct.
	So many of the features that are available in the components will only be implemented in XML
	if it needs to be handled separately.

	Thu 13:42:51 11 Dec 2025
	Rename XmlComponent to XmlContainer
**/

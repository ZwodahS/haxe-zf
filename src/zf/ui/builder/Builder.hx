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

	## Navigation Nodes
	@see zf.nav
	In a game that is controller based, we need to know how to navigate between different UI element.
	This can be done using zf.nav.
	The Builder can also build the navigation graph using xml.

	Each component need to handle the creation and how they are linked.
	Each component also need to provide their own onToggle handling

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
		The main make function.
		This function is overloaded to accept any type of input

		@param data - the data used to build the object. Accept xmlString or Xml element
		@param context - the context for building the object, BuilderContext or a struct
	**/
	public function build(data: Dynamic, context: Dynamic = null): ComponentObject {
		var element: Xml = null;
		if (data is String) {
			try {
				element = Xml.parse(cast data);
				element = element.firstElement();
			} catch (e) {
				Logger.exception(e);
				return null;
			}
		} else if (data is Xml) {
			element = cast data;
		} else {
			throw new zf.exceptions.NotImplemented();
		}

		if (element.nodeType != Element) return null;
		final component = this.components[element.nodeName];
		if (component == null) return null;

		var ctx: BuilderContext = null;
		if (context is BuilderContext) {
			ctx = cast context;
		} else {
			try {
				ctx = new BuilderContext(context);
				ctx.builder = this;
			} catch (e) {
				Logger.exception(e);
				return null;
			}
		}

		Assert.assert(element != null);
		Assert.assert(ctx != null);

		final object = component.build(element, ctx);
		if (object?.object != null && element.get("id") != null) object.object.name = element.get("id");

		return object;
	}

	public function fromFile(path: String, context: Dynamic): ComponentObject {
		/**
			Quick way to create object from file
		**/
		try {
			final xml = this.res.getStringFromPath(path);
			final object = build(xml, context);
			return object;
		} catch (e) {
			zf.Logger.error(path);
			zf.Logger.exception(e);
			return null;
		}
	}

	public function fromString(string: String, context: Dynamic): ComponentObject {
		try {
			final object = build(string, context);
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

		final anim = this.res.getAnim(path);
		if (anim == null) return anim;

		final speed = conf.getFloat("speed");
		anim.speed = speed;

		return anim;
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

	Mon 12:06:05 15 Dec 2025
	Rework builder to also build navigation nodes
**/

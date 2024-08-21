package zf.ui.builder;

import zf.ui.UIElement;

/**
	Thu 19:51:22 19 Oct 2023
	First draft of a xml component, similar to that of a domkit.

	I expect there to be a V2 later.

	# Motivation
	A lot of the time, UI are defined in Xml files. The standard way is to load it from file.

	This component allow me to auto build a lot of variable via metadata

	@:findChild var componentName or @:findChild(path)
	This will assign the variable to a object via h2d.Object.getObjectByName
	if path is not provided, will use the variable name

	@:exposeContext function funcName or @:exposeContext(name)
	will expose the function to the builder context as name.
	if name is not provided, will expose as funcName
**/
@:autoBuild(zf.macros.XmlComponentMacro.build())
class XmlComponent extends UIElement {
	public static var Builder: zf.ui.builder.Builder;

	var filepath: String = null;

	var display: h2d.Object = null;

	/**
		Do not modify this directly in child class
	**/
	var __context__: Dynamic;

	public function new(filepath: String) {
		super();
		this.filepath = filepath;
		this.__context__ = {};
	}

	function initContext() {
		_initContext();
	}

	/**
		call from child to init this xml component
	**/
	function initComponent() {
		if (XmlComponent.Builder == null) throw new haxe.Exception("UIBuilder not set");
		this.addChild(this.display = cast XmlComponent.Builder.fromFile(filepath, getBuildContext()));
		/**
			Fri 14:38:04 19 Jul 2024
			This is weird to be placed here, but I have no idea where else this can be done.
			Might be considered as a hack ?
		**/
		if (this.display is UIElement && cast(this.display, UIElement).interactive != null) {
			this.interactive = cast(this.display, UIElement).interactive;
		}
		_buildVariables();
	}

	/**
		Override this to provide more variable to the builder context
	**/
	function getBuildContext(): Dynamic {
		return Reflect.copy(__context__);
	}

	/**
		Build by macro
	**/
	function _initContext() {}

	/**
		Build by macro
	**/
	function _buildVariables() {}
}

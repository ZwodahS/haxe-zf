package zf.ui.builder;

import zf.ui.UIElement;
import zf.h2d.Container;

enum ConfMode {
	File; // treat confString as a filepath
	XML; // treat confString as string
}

/**
	# Motivation
	A lot of the time, UI are defined in Xml files. The standard way is to load it from file.

	This component allow me to auto build a lot of variable via metadata

	@:findChild var componentName or @:findChild(path)
	This will assign the variable to a object via h2d.Object.getObjectByName
	if path is not provided, will use the variable name

	@:findChildren or @:findChildren(path)
	This will assign a list of h2d.Object via h2d.Object.getObjectsByName

	@:exposeContext function funcName or @:exposeContext(name)
	will expose the function to the builder context as name.
	if name is not provided, will expose as funcName

	@see XmlContainerMacro for more information
**/
@:autoBuild(zf.macros.XmlContainerMacro.build())
class XmlContainer extends zf.h2d.Container {
	public static var Builder: zf.ui.builder.Builder;

	final confString: String = null;

	final mode: ConfMode = File;

	var display: h2d.Object = null;

	/**
		Do not modify this directly in child class
	**/
	var __context__: Dynamic;

	public function new(confString: String, mode: ConfMode = File) {
		super();
		this.confString = confString;

		this.mode = mode;
		this.__context__ = {};
	}

	function initContext() {
		_initContext();
	}

	/**
		call from child to init this xml component
	**/
	function initComponent() {
		if (XmlContainer.Builder == null) throw new haxe.Exception("UIBuilder not set");
		switch (mode) {
			case File:
				final cObject = XmlContainer.Builder.fromFile(this.confString, getBuildContext());
				this.addChild(this.display = cObject.object);
			case XML:
				final cObject = XmlContainer.Builder.fromString(this.confString, getBuildContext());
				this.addChild(this.display = cObject.object);
		}

		if (this.display is Container && cast(this.display, Container).interactive != null) {
			this.interactive = cast(this.display, Container).interactive;
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

/**
	Thu 19:51:22 19 Oct 2023
	First draft of a xml component, similar to that of a domkit.

	I expect there to be a V2 later.

	Wed 16:57:07 11 Jun 2025
	More and more I realised that I don't really want to define it in a file.
	This is funny, because part of the reason why I didn't use domkit is because
	I want it in a file instead of SRC.
**/

package zf.nav.ext;

import zf.ui.UIElement;

/**
	Can be used by UIElement that is statically linked, i.e. MenuItems / Hud
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class NavigationUIElementNode extends StaticNavigationNode {
	@:dispose public var element: UIElement = null;

	override public function onEnter() {
		this.element.toggled = true;
	}

	override public function onExit() {
		this.element.toggled = false;
	}

	override public function activate() {
		if (this.element == null) return;
		try {
			this.element._onClick(null);
		} catch (e) {}
	}

	public static function alloc(element: UIElement): NavigationUIElementNode {
		final node = NavigationUIElementNode.__alloc__();

		node.element = element;

		return node;
	}
}

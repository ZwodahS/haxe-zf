package zf.ui.builder;

/**
	Subclass the Static Navigation Node to handle UI-type handling
**/
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class UINavigationNode extends zf.nav.StaticNavigationNode {
	@:dispose public var _onEnter: Void->Void = null;
	@:dispose public var _onExit: Void->Void = null;
	@:dispose public var _onActivate: Void->Void = null;

	public static function alloc(_onEnter: Void->Void = null, _onExit: Void->Void = null,
			_onActivate: Void->Void = null): UINavigationNode {
		final node = UINavigationNode.__alloc__();

		node._onEnter = _onEnter;
		node._onExit = _onExit;
		node._onActivate = _onActivate;

		return node;
	}

	override public function onEnter() {
		if (this._onEnter != null) this._onEnter();
	}

	override public function onExit() {
		if (this._onExit != null) this._onExit();
	}

	override public function activate() {
		if (this._onActivate != null) this._onActivate();
	}
}

package zf.debug;

/**
	@stage:stable
**/
class D {
	public static function makeMovable(object: h2d.Object): UIElementMove {
#if !debug
		Logger.warn("D is used outside of debug mode");
		return null;
#else
		return new UIElementMove(object);
#end
	}

	public static function makeDebugDraw(object: h2d.Object): DebugDraw {
#if !debug
		Logger.warn("D is used outside of debug mode");
		return null;
#else
		return new DebugDraw(object);
#end
	}

	public static function makeResizable(object: h2d.Object): UIElementResize {
#if !debug
		Logger.warn("D is used outside of debug mode");
		return null;
#else
		return new UIElementResize(object);
#end
	}
}

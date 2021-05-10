package zf.h2d;

enum SetMode {
	Set;
	AnchorLeft;
	AnchorRight;
	AnchorTop;
	AnchorBottom;
	AlignCenter;
}

class ObjectExtensions {
	public static function putAbove(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
			overrideX: Null<Int> = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var objSize = obj.getSize();
		if (overrideX == null) {
			obj.x = component.x + offset.x;
		} else {
			obj.x = overrideX;
		}
		obj.y = component.y - objSize.height - offset.y;
		return obj;
	}

	public static function putBelow(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
			overrideX: Null<Int> = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var componentSize = component.getSize();
		if (overrideX == null) {
			obj.x = component.x + offset.x;
		} else {
			obj.x = overrideX;
		}
		obj.y = component.y + componentSize.height + offset.y;
		return obj;
	}

	public static function putOnLeft(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
			overrideY: Null<Int> = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var objSize = obj.getSize();
		obj.x = component.x - objSize.width - offset.x;
		if (overrideY == null) {
			obj.y = component.y + offset.y;
		} else {
			obj.y = overrideY;
		}
		return obj;
	}

	public static function putOnRight(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
			overrideY: Null<Int> = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var componentSize = component.getSize();
		obj.x = component.x + componentSize.width + offset.x;
		if (overrideY == null) {
			obj.y = component.y + offset.y;
		} else {
			obj.y = overrideY;
		}
		return obj;
	}

	inline public static function centerX(obj: h2d.Object, startX: Float, width: Float): h2d.Object {
		return setX(obj, width, AlignCenter, startX);
	}

	inline public static function centerY(obj: h2d.Object, startY: Float, height: Float): h2d.Object {
		return setY(obj, height, AlignCenter, startY);
	}

	/** Chain Functions set values and return the object **/
	public static function setX(obj: h2d.Object, x: Float, setMode: SetMode = Set,
			padding: Float = 0): h2d.Object {
		switch (setMode) {
			case Set:
				obj.x = x;
			case AnchorLeft:
				obj.x = x + padding;
			case AnchorRight:
				obj.x = x - padding - obj.getSize().width;
			case AlignCenter:
				obj.x = padding + (x - obj.getSize().width) / 2;
			default:
				obj.x = x;
		}
		return obj;
	}

	public static function setY(obj: h2d.Object, y: Float, setMode: SetMode = Set,
			padding: Float = 0): h2d.Object {
		switch (setMode) {
			case Set:
				obj.y = y;
			case AnchorTop:
				obj.y = y + padding;
			case AnchorBottom:
				obj.y = y - padding - obj.getSize().height;
			case AlignCenter:
				obj.y = padding + (y - obj.getSize().height) / 2;
			default:
				obj.y = y;
		}
		return obj;
	}

	/**
		Set scale of object and return
	**/
	public static function cSetScale(obj: h2d.Object, scale: Float): h2d.Object {
		obj.scale(scale);
		return obj;
	}
}

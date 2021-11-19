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
	public static function putAbove(obj: h2d.Object, component: h2d.Object, offset: Point2f = null,
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

	public static function putAboveBound(obj: h2d.Object, bounds: h2d.col.Bounds, offset: Point2f = null,
			overrideX: Null<Int> = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		final objSize = obj.getSize();
		if (overrideX == null) {
			obj.x = bounds.xMin + offset.x;
		} else {
			obj.x = overrideX;
		}
		obj.y = bounds.yMin - objSize.height - offset.y;
		return obj;
	}

	public static function putBelow(obj: h2d.Object, component: h2d.Object, offset: Point2f = null,
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

	public static function putBelowBound(obj: h2d.Object, bounds: h2d.col.Bounds, offset: Point2f = null,
			overrideX: Null<Int> = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		if (overrideX == null) {
			obj.x = bounds.xMin + offset.x;
		} else {
			obj.x = overrideX;
		}
		obj.y = bounds.yMax + offset.y;
		return obj;
	}

	public static function putOnLeft(obj: h2d.Object, component: h2d.Object, offset: Point2f = null,
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

	public static function putOnRight(obj: h2d.Object, component: h2d.Object, offset: Point2f = null,
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

	public static function alignXWithin(obj: h2d.Object, component: h2d.Object): h2d.Object {
		setX(obj, component.getSize().width, AlignCenter, component.x);
		return obj;
	}

	public static function alignYWithin(obj: h2d.Object, component: h2d.Object): h2d.Object {
		setY(obj, component.getSize().height, AlignCenter, component.y);
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
		obj.x = calculateXPosition(obj, x, setMode, padding);
		return obj;
	}

	public static function setY(obj: h2d.Object, y: Float, setMode: SetMode = Set,
			padding: Float = 0): h2d.Object {
		obj.y = calculateYPosition(obj, y, setMode, padding);
		return obj;
	}

	/** Chain Functions set values and return the object **/
	public static function calculateXPosition(obj: h2d.Object, x: Float, setMode: SetMode = Set,
			padding: Float = 0): Float {
		switch (setMode) {
			case Set:
				return x;
			case AnchorLeft:
				return x + padding;
			case AnchorRight:
				return x - padding - obj.getSize().width;
			case AlignCenter:
				return padding + (x - obj.getSize().width) / 2;
			default:
				return x;
		}
		return x;
	}

	public static function calculateYPosition(obj: h2d.Object, y: Float, setMode: SetMode = Set,
			padding: Float = 0): Float {
		switch (setMode) {
			case Set:
				return y;
			case AnchorTop:
				return y + padding;
			case AnchorBottom:
				return y - padding - obj.getSize().height;
			case AlignCenter:
				return padding + (y - obj.getSize().height) / 2;
			default:
				return y;
		}
		return y;
	}

	/**
		Set scale of object and return
	**/
	public static function cSetScale(obj: h2d.Object, scale: Float): h2d.Object {
		obj.scale(scale);
		return obj;
	}

	public static function cSetText(obj: h2d.Text, text: String): h2d.Text {
		obj.text = text;
		return obj;
	}
}

package zf.h2d;

class ObjectExtensions {
	public static function anchorAbove(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
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

	public static function anchorBelow(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
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

	public static function anchorLeft(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
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

	public static function anchorRight(obj: h2d.Object, component: h2d.Object, offset: Point2i = null,
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

	public static function centerX(obj: h2d.Object, startX: Float, width: Float): h2d.Object {
		var objSize = obj.getSize();
		obj.x = startX + ((width - objSize.width) / 2);
		return obj;
	}

	public static function centerY(obj: h2d.Object, startY: Float, height: Float): h2d.Object {
		var objSize = obj.getSize();
		obj.y = startY + ((height - objSize.height) / 2);
		return obj;
	}

	public static function setPosition(obj: h2d.Object, x: Float, y: Float): h2d.Object {
		obj.x = x;
		obj.y = y;
		return obj;
	}

	public static function setX(obj: h2d.Object, x: Float): h2d.Object {
		obj.x = x;
		return obj;
	}

	public static function setY(obj: h2d.Object, y: Float): h2d.Object {
		obj.y = y;
		return obj;
	}
}

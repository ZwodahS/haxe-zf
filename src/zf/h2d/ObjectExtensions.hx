package zf.h2d;

class ObjectExtensions {
	public static function anchorAbove(obj: h2d.Object, component: h2d.Object,
			offset: Point2i = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var objSize = obj.getSize();
		obj.x = component.x + offset.x;
		obj.y = component.y - objSize.height - offset.y;
		return obj;
	}

	public static function anchorBelow(obj: h2d.Object, component: h2d.Object,
			offset: Point2i = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var componentSize = component.getSize();
		obj.x = component.x + offset.x;
		obj.y = component.y + componentSize.height + offset.y;
		return obj;
	}

	public static function anchorLeft(obj: h2d.Object, component: h2d.Object,
			offset: Point2i = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var objSize = obj.getSize();
		obj.x = component.x - objSize.width - offset.x;
		obj.y = component.y + offset.y;
		return obj;
	}

	public static function anchorRight(obj: h2d.Object, component: h2d.Object,
			offset: Point2i = null): h2d.Object {
		if (offset == null) offset = [0, 0];
		var componentSize = component.getSize();
		obj.x = component.x + componentSize.width + offset.x;
		obj.y = component.y + offset.y;
		return obj;
	}
}
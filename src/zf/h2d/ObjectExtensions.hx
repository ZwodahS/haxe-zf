package zf.h2d;

enum SetMode {
	Set;
	AnchorLeft;
	AnchorRight;
	AnchorTop;
	AnchorBottom;
	AnchorCenter;
	AlignCenter;
}

/**
	@stage:stable
**/
class ObjectExtensions {
	/**
		Wrap a object around a object and center it
	**/
	public static function centerWrapped(obj: h2d.Object): h2d.Object {
		final newObject = new h2d.Object();
		newObject.addChild(obj);
		final bounds = obj.getBounds();
		obj.x = -bounds.width / 2;
		obj.y = -bounds.height / 2;
		return newObject;
	}

	/**
		Put an object above another object

		@param obj the object to be placed
		@param relativeTo the object to placed relative to
		@param offset additional offset, default null
		@param overrideX the value to override the X value instead of using the x value of the target

		Note: this is the same as putAboveBound(obj, relativeTo.getBounds(relativeTo.parent);
		@return the object being set
	**/
	public static function putAbove(obj: h2d.Object, relativeTo: h2d.Object, offset: Point2f = null,
			overrideX: Null<Int> = null): h2d.Object {
		final bounds = relativeTo == null ? null : relativeTo.getBounds(relativeTo.parent);
		return putAboveBound(obj, bounds, offset, overrideX);
	}

	/**
		Put an object above a bound

		@param obj the object to be placed
		@param bounds the bounds to placed relative to
		@param offset additional offset, default null
		@param overrideX the value to override the X value instead of using the x value of the target

		@return the object being set
	**/
	public static function putAboveBound(obj: h2d.Object, bounds: h2d.col.Bounds, offset: Point2f = null,
			overrideX: Null<Int> = null): h2d.Object {
		if (bounds == null) {
			obj.x = 0;
			obj.y = 0;
			return obj;
		}
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

	/**
		Put an object below another object

		@param obj the object to be placed
		@param relativeTo the object to placed relative to
		@param offset additional offset, default null
		@param overrideX the value to override the X value instead of using the x value of the target

		Note: this is the same as putBelowBound(obj, relativeTo.getBounds(relativeTo.parent);
		@return the object being set
	**/
	public static function putBelow(obj: h2d.Object, relativeTo: h2d.Object, offset: Point2f = null,
			overrideX: Null<Int> = null): h2d.Object {
		final bounds = relativeTo == null ? null : relativeTo.getBounds(relativeTo.parent);
		return putBelowBound(obj, bounds, offset, overrideX);
	}

	/**
		Put an object below a bound

		@param obj the object to be placed
		@param bounds the bounds to placed relative to
		@param offset additional offset, default null
		@param overrideX the value to override the X value instead of using the x value of the target

		@return the object being set
	**/
	public static function putBelowBound(obj: h2d.Object, bounds: h2d.col.Bounds, offset: Point2f = null,
			overrideX: Null<Int> = null): h2d.Object {
		if (bounds == null) {
			obj.x = 0;
			obj.y = 0;
			return obj;
		}
		if (offset == null) offset = [0, 0];
		if (overrideX == null) {
			obj.x = bounds.xMin + offset.x;
		} else {
			obj.x = overrideX;
		}
		obj.y = bounds.yMax + offset.y;
		return obj;
	}

	/**
		Put an object on the left of another object

		@param obj the object to be placed
		@param relativeTo the object to placed relative to
		@param offset additional offset, default null
		@param overrideY the value to override the Y value instead of using the y value of the target

		@return the object being set
	**/
	public static function putOnLeft(obj: h2d.Object, relativeTo: h2d.Object, offset: Point2f = null,
			overrideY: Null<Float> = null): h2d.Object {
		if (relativeTo == null) {
			obj.x = 0;
			obj.y = 0;
			return obj;
		}
		if (offset == null) offset = [0, 0];
		var objSize = obj.getSize();
		obj.x = relativeTo.x - objSize.width - offset.x;
		if (overrideY == null) {
			obj.y = relativeTo.y + offset.y;
		} else {
			obj.y = overrideY;
		}
		return obj;
	}

	/**
		Put an object on the right of another object

		@param obj the object to be placed
		@param relativeTo the object to placed relative to
		@param offset additional offset, default null
		@param overrideY the value to override the Y value instead of using the y value of the target

		@return the object being set
	**/
	public static function putOnRight(obj: h2d.Object, component: h2d.Object, offset: Point2f = null,
			overrideY: Null<Float> = null): h2d.Object {
		if (component == null) {
			obj.x = 0;
			obj.y = 0;
			return obj;
		}
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

	@:deprecated("renamed to centerXWithin(obj, component)")
	public static function alignXWithin(obj: h2d.Object, component: h2d.Object): h2d.Object {
		return centerXWithin(obj, component);
	}

	/**
		Center a object in the X-axis relative to another object

		@param obj the object to be placed
		@param relativeTo the object to be placed relative to
	**/
	public static function centerXWithin(obj: h2d.Object, relativeTo: h2d.Object): h2d.Object {
		return setXInBound(obj, relativeTo.getBounds(relativeTo.parent), AlignCenter);
	}

	@:deprecated("renamed to centerYWithin(obj, relativeTo)")
	public static function alignYWithin(obj: h2d.Object, relativeTo: h2d.Object): h2d.Object {
		return centerYWithin(obj, relativeTo);
	}

	/**
		Center a object in the Y-axis relative to another object

		@param obj the object to be placed
		@param relativeTo the object to be placed relative to
	**/
	public static function centerYWithin(obj: h2d.Object, relativeTo: h2d.Object): h2d.Object {
		return setYInBound(obj, relativeTo.getBounds(relativeTo.parent), AlignCenter);
	}

	/**
		Center an object relative to another object.
	**/
	public static function centerWithinObject(obj: h2d.Object, relativeTo: h2d.Object): h2d.Object {
		return centerWithinBounds(obj, relativeTo.getBounds());
	}

	/**
		Center an object within a bound
	**/
	public static function centerWithinBounds(obj: h2d.Object, bounds: h2d.col.Bounds): h2d.Object {
		centerXWithinBounds(obj, bounds);
		centerYWithinBounds(obj, bounds);
		return obj;
	}

	public static function centerXWithinBounds(obj: h2d.Object, bounds: h2d.col.Bounds): h2d.Object {
		setX(obj, bounds.width, AlignCenter, bounds.x);
		return obj;
	}

	public static function centerYWithinBounds(obj: h2d.Object, bounds: h2d.col.Bounds): h2d.Object {
		setY(obj, bounds.height, AlignCenter, bounds.y);
		return obj;
	}

	inline public static function centerX(obj: h2d.Object, startX: Float, width: Float): h2d.Object {
		return setX(obj, width, AlignCenter, startX);
	}

	inline public static function centerY(obj: h2d.Object, startY: Float, height: Float): h2d.Object {
		return setY(obj, height, AlignCenter, startY);
	}

	/**
		Center the object such that the x and y is -width/2 and -height/2 respectively.
	**/
	inline public static function center(obj: h2d.Object, centerX: Bool = true, centerY: Bool = true): h2d.Object {
		final bounds = obj.getBounds();
		if (centerX == true) obj.x = bounds.xMin - (bounds.width / 2);
		if (centerY == true) obj.y = bounds.yMin - (bounds.height / 2);
		return obj;
	}

	/** Chain Functions set values and return the object **/
	/**
		A chain method for setting the x position

		@param obj the object to be placed
		@param x the x position to set
		@param setMode the mode to set the X value. See calculateXPosition to see how the X position are set.
		@param padding additional padding to the x value
	**/
	inline public static function setX(obj: h2d.Object, x: Float, setMode: SetMode = Set,
			padding: Float = 0): h2d.Object {
		obj.x = calculateXPosition(obj, x, setMode, padding);
		return obj;
	}

	/**
		A chain method for setting the y position

		@param obj the object to be placed
		@param y the y position to be set
		@param setMode the mode to set the Y value. See calculateYPosition to see how to Y position are set.
		@param padding additional padding to the y value
	**/
	inline public static function setY(obj: h2d.Object, y: Float, setMode: SetMode = Set,
			padding: Float = 0): h2d.Object {
		obj.y = calculateYPosition(obj, y, setMode, padding);
		return obj;
	}

	/**
		Calculate X position.

		@param obj the obj that x value will be used on
		@param x the x value
		@param setMode the mode to set
			Set - set to the x position provided
			AnchorLeft - put the x position on the left side of the object
			AnchorRight - put the x position on the right side of the object
			AnchorCenter - put the x position in the middle of the object
			AlignCenter - same as AnchorCenter
		@param padding additional x padding

		Note1: For Set, no padding will be applied
	**/
	public static function calculateXPosition(obj: h2d.Object, x: Float, setMode: SetMode = Set,
			padding: Float = 0): Float {
		switch (setMode) {
			case Set:
				return x;
			case AnchorLeft:
				return x + padding;
			case AnchorRight:
				return x - padding - obj.getSize().width;
			case AnchorCenter:
				return x - (obj.getSize().width / 2) + padding;
			case AlignCenter:
				return padding + (x - obj.getSize().width) / 2;
			default:
				return x;
		}
		return x;
	}

	/**
		Calculate Y position.

		@param obj the obj that y value will be used on
		@param y the y value
		@param setMode the mode to set
			Set - set to the y position provided
			AnchorTop - put the y position above the object
			AnchorBottom - put the y position below the object
			AnchorCenter - put the y position in the middle of the object
			AlignCenter - same as AnchorCenter
		@param padding additional y padding

		Note1: For Set, no padding will be applied
	**/
	public static function calculateYPosition(obj: h2d.Object, y: Float, setMode: SetMode = Set,
			padding: Float = 0): Float {
		switch (setMode) {
			case Set:
				return y;
			case AnchorTop:
				return y + padding;
			case AnchorBottom:
				return y - padding - obj.getSize().height;
			case AnchorCenter:
				return y - (obj.getSize().height / 2) + padding;
			case AlignCenter:
				return padding + (y - obj.getSize().height) / 2;
			default:
				return y;
		}
		return y;
	}

	/**
		Set the x position of a object relative to a bound

		@param obj the obj to set
		@param bound the relative bound
		@param setMode the mode of setting. See calculateXPositionInBound
		@param padding additional x padding
	**/
	public static function setXInBound(obj: h2d.Object, bound: h2d.col.Bounds, setMode = AlignCenter,
			padding: Float = 0) {
		obj.x = calculateXPositionInBound(obj, bound, setMode, padding);
		return obj;
	}

	/**
		Set the y position of a object relative to a bound

		@param obj the obj to set
		@param bound the relative bound
		@param setMode the mode of setting. See calculateXPositionInBound
		@param padding additional x padding
	**/
	public static function setYInBound(obj: h2d.Object, bound: h2d.col.Bounds, setMode = AlignCenter,
			padding: Float = 0) {
		obj.y = calculateYPositionInBound(obj, bound, setMode, padding);
		return obj;
	}

	/**
		calculate the target X position of an object relative to a bound

		@param obj the obj
		@param bound the relative bound
		@param setMode

			Set - set to the x position to the x position of the bound
			AnchorLeft - anchor the object to the left side of the bound
			AnchorRight - anchor the object to the right side of the bound
			AlignCenter - center the object within the bound

		@param padding additional x padding
	**/
	public static function calculateXPositionInBound(obj: h2d.Object, bound: h2d.col.Bounds, setMode: SetMode = Set,
			padding: Float = 0): Float {
		if (setMode == AnchorCenter) setMode = AlignCenter; // this does the same thing for this case
		switch (setMode) {
			case Set:
				return bound.x;
			case AnchorLeft:
				return bound.x + padding;
			case AnchorRight:
				return bound.xMax - padding - obj.getSize().width;
			case AlignCenter:
				return padding + bound.x + ((bound.width - obj.getSize().width) / 2);
			default:
				return bound.x;
		}
		return bound.x;
	}

	/**
		calculate the target Y position of an object relative to a bound

		@param obj the obj
		@param bound the relative bound
		@param setMode

			Set - set to the y position to the y position of the bound
			AnchorTop - anchor the object to the top of the bound
			AnchorBottom - anchor the object to the bottom of the bound
			AlignCenter - center the object within the bound
	**/
	public static function calculateYPositionInBound(obj: h2d.Object, bound: h2d.col.Bounds, setMode: SetMode = Set,
			padding: Float = 0): Float {
		if (setMode == AnchorCenter) setMode = AlignCenter; // this does the same thing for this case
		switch (setMode) {
			case Set:
				return bound.y;
			case AnchorTop:
				return bound.y + padding;
			case AnchorBottom:
				return bound.yMax - padding - obj.getSize().height;
			case AlignCenter:
				return padding + bound.y + ((bound.height - obj.getSize().height) / 2);
			default:
				return bound.y;
		}
		return bound.y;
	}

	/**
		Set scale of object and return
	**/
	public static function cSetScale(obj: h2d.Object, scale: Float): h2d.Object {
		obj.scale(scale);
		return obj;
	}

	/**
		Set the text of a Text and return
	**/
	public static function cSetText(obj: h2d.Text, text: String): h2d.Text {
		obj.text = text;
		return obj;
	}

	/**
		Set the text color of an object and return
	**/
	public static function cSetTextColor(obj: h2d.Text, color: Int): h2d.Text {
		obj.textColor = color;
		return obj;
	}

	public static function cSetColor(obj: h2d.Drawable, color: Int): h2d.Drawable {
		obj.color.setColor(color);
		return obj;
	}

	public static function cSetAlpha(obj: h2d.Object, alpha: Float): h2d.Object {
		obj.alpha = alpha;
		return obj;
	}

	public static function isReallyVisible(obj: h2d.Object): Bool {
		// recursively check if parent is visible
		if (!obj.visible) return false;
		if (obj.parent == null) return true;
		return isReallyVisible(obj.parent);
	}

	/**
		Move an object from the current parent to a target parent keep the screen position.

		@return object to be added

		Note: this does not add it to target.
		You can chain it to add it, i.e.
		target.addChild(object.moveTo(target));

		Main reason is we might want to add it using Layers.add or Object.addChild
	**/
	public static function moveTo(object: h2d.Object, target: h2d.Object) {
		var pos = new h2d.col.Point(object.x, object.y);
		if (object.parent != null) {
			pos = object.parent.localToGlobal(pos);
		}
		pos = target.globalToLocal(pos);
		object.x = pos.x;
		object.y = pos.y;
		return object;
	}

	/**
		Adjust position of the object based on a targetX, a delta and a movement speed
	**/
	public static function adjustPosition(object: h2d.Object, targetX: Float, targetY: Float, delta: Float,
			movementSpeed: Point2f) {
		if (object.x == targetX && object.y == targetY) return;

		if (object.x > targetX) {
			final move = delta * movementSpeed.x;
			object.x -= move;
			if (object.x < targetX) object.x = targetX;
		} else if (object.x < targetX) {
			final move = delta * movementSpeed.x;
			object.x += move;
			if (object.x > targetX) object.x = targetX;
		}

		if (object.y > targetY) {
			final move = delta * movementSpeed.y;
			object.y -= move;
			if (object.y < targetY) object.y = targetY;
		} else if (object.y < targetY) {
			final move = delta * movementSpeed.y;
			object.y += move;
			if (object.y > targetY) object.y = targetY;
		}
	}

#if sys
	public static function toPng(object: h2d.Object, path: String = null): haxe.io.Bytes {
		final size = object.getSize();
		final mat = new h3d.mat.Texture(Math.floor(size.width), Math.floor(size.height), [Target]);
		object.drawTo(mat);
		final pixels = mat.capturePixels();
		final bytes = pixels.toPNG();
		if (path != null) sys.io.File.saveBytes(path, bytes);
		return bytes;
	}
#end
}

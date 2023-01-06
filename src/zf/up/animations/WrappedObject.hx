package zf.up.animations;

using zf.h2d.ObjectExtensions;

/**
	@stage:stable
**/
class WrappedObject implements Alphable implements Scalable implements Positionable implements Rotatable {
	public var object: h2d.Object;

	var originalObject: h2d.Object;
	var originalX: Float;
	var originalY: Float;

	public function new(o: h2d.Object) {
		this.object = o;
	}

	/**
		create a new object to hold the object, while keeping the center.
		returnCenter needs to be called once the animation is finish
	**/
	public function alignCenter() {
		if (this.originalObject != null) return;
		final parent = this.object.parent;
		if (parent == null) return;

		this.originalObject = this.object;
		this.object = new h2d.Object();

		final insertIndex = getInsertIndex(parent, this.originalObject);
		parent.addChildAt(this.object, insertIndex);

		final bounds = this.originalObject.getBounds();
		this.originalX = this.originalObject.x;
		this.originalY = this.originalObject.y;
		this.originalObject.setX(-bounds.width / 2).setY(-bounds.height / 2);
		this.object.addChild(this.originalObject);
		this.object.setX(originalX + (bounds.width / 2)).setY(originalY + (bounds.height / 2));
	}

	public function returnCenter() {
		if (originalObject == null) return;
		this.originalObject.x = originalX;
		this.originalObject.y = originalY;
		final parent = this.object.parent;
		// if parent != null then we we add it back
		if (parent != null) {
			final insertIndex = getInsertIndex(this.object.parent, this.object);
			this.object.parent.addChildAt(this.originalObject, insertIndex);
			this.object.remove();
			this.object = originalObject;
		}
	}

	function getInsertIndex(parent: h2d.Object, child: h2d.Object) {
		if (Std.isOfType(parent, h2d.Layers)) {
			return cast(parent, h2d.Layers).getChildLayer(child);
		} else {
			return parent.getChildIndex(child);
		}
	}

	public var alpha(get, set): Float;

	inline public function set_alpha(a: Float): Float {
		return object.alpha = a;
	}

	inline public function get_alpha(): Float {
		return object.alpha;
	}

	public var scaleX(get, set): Float;

	inline public function set_scaleX(x: Float): Float {
		return this.object.scaleX = x;
	}

	inline public function get_scaleX(): Float {
		return this.object.scaleX;
	}

	public var scaleY(get, set): Float;

	inline public function set_scaleY(y: Float): Float {
		return this.object.scaleY = y;
	}

	inline public function get_scaleY(): Float {
		return this.object.scaleY;
	}

	public var x(get, set): Float;

	inline public function set_x(x: Float): Float {
		return this.object.x = x;
	}

	inline public function get_x(): Float {
		return this.object.x;
	}

	public var y(get, set): Float;

	inline public function set_y(y: Float): Float {
		return this.object.y = y;
	}

	inline public function get_y(): Float {
		return this.object.y;
	}

	public var rotation(get, set): Float;

	inline public function get_rotation(): Float {
		return this.object.rotation;
	}

	inline public function set_rotation(r: Float): Float {
		return this.object.rotation = r;
	}

	public static function wo(obj: h2d.Object, alignCenter: Bool = false): WrappedObject {
		final wo = new WrappedObject(obj);
		if (alignCenter == true) wo.alignCenter();
		return wo;
	}
}

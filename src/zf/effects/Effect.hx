package zf.effects;

import zf.ui.UIElement;

/**
	@stage:unstable

	Parent class for Effect

	The idea behind effect class is to provide a different way to handle animation,
	similar to the zf.up.animations.

	The goal is to provide a way to do this such that the object owns the animation rather than having
	another class owns it.

	This also allow us to have the effect be automatically removed once the object is removed.

	Key difference here is

	1. Effect should be used when we want effect to be looped indefinitely.
	2. The effect we want cannot be done using a shader of some sort
	3. There should *NEVER* be any logic.

	For example, there can be a Shake effect that is similar to the Shake animation.
	In the Shake animation, there might be an end to the animation.
	However, in the shake effect, the effect should continue, perhaps with a pause between the shake.

	This don't have to be the case.
	We can also have one off effect that removes itself once it is completed.

	Effect hijack the sync method of h2d.Object to do this.
	All Effect should override update method

	Effect can also be removed after they are added to the object.
	Child class of effect should override onEffectRemove to handle any cleanup.
	For example, some effect may make use of filter / shader.
	In those case, we need to clean them up when the effect is removed
	This also means that we can use Effect as a wrapper for filter

	All Effect object should be self-contained.
**/
class Effect extends h2d.Object {
	public var object: h2d.Object;
	public var uiElement: UIElement;

	public function new(object: h2d.Object) {
		super();
		this.object = object;
		if (Std.isOfType(object, UIElement)) this.uiElement = cast object;
		if (this.uiElement != null) {
			if (this.uiElement.uiEffects == null) this.uiElement.uiEffects = [];
			this.uiElement.uiEffects.push(this);
		}
	}

	override function sync(ctx: h2d.RenderContext) {
		update(ctx.elapsedTime);
		super.sync(ctx);
	}

	function update(dt: Float) {}

	override function onAdd() {
		super.onAdd();
		onEffectAdd();
	}

	override function onRemove() {
		super.onRemove();
		onEffectRemove();
	}

	function onEffectAdd() {}

	function onEffectRemove() {}

	/**
		Remove the effect from the object
	**/
	public function removeFromObject() {
		this.remove(); // remove from the object
		if (this.uiElement != null && this.uiElement.uiEffects != null) this.uiElement.uiEffects.remove(this);
	}
}
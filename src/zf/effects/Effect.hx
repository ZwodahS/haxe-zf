package zf.effects;

import zf.ui.UIElement;

typedef EffectConf = {};

class EffectWrap extends h2d.Object {
	var effect: Effect;

	public function new(effect: Effect) {
		super();
		this.effect = effect;
	}

	override function onAdd() {
		super.onAdd();
		this.effect.onEffectAdd();
	}

	override function onRemove() {
		super.onRemove();
		this.effect.onEffectRemove();
	}

	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		if (this.effect.update(ctx.elapsedTime) == true) {
			this.effect.onEffectFinished();
			this.removeFromObject();
			return;
		}
	}

	/**
		Remove the effect from the object
	**/
	public function removeFromObject() {
		this.remove(); // remove from the object
		this.effect.cleanup();
	}
}

/**
	@stage:stable

	Parent class for Effect

	The idea behind effect class is to provide a different way to handle animation, similar to the zf.up.animations.

	The goal is to provide a way to do this such that the object owns the animation rather than having
	another class owns it.

	This also allow us to have the effect be automatically removed once the object is removed.

	Effect hijack the sync method of h2d.Object to do this.
	All Effect should override update method

	Effect can also be removed after they are added to the object.
	Child class of effect should override onRemove to handle any cleanup.

	For example, some effect may make use of filter / shader.
	In those case, we need to clean them up when the effect is removed
	This also means that we can use Effect as a wrapper for filter

	All Effect object should be self-contained.

	A lot of the same functionality from zf.up can be found here.
	- Batch (for running multiple uieffects at once)
	- Chain (for running effects after one another)
	- Wait (wait for X seconds, only make sense in Chain)

	There are also 2 kinds of effect.
	The first kind is meant to be loop (i.e. effect)
	The second is run and terminate (i.e. animations)

	The second kind is almost a mirror of zf.up.animations, just that the owner now is the object rather than an updater.
	The first kind is an effect that loops, which means we will need to reset the object to the original state
	when the effect is removed from the object.

	Sometimes effect can have both, i.e. be configured to behave like either

	# Note
	1. What happen when the effect finishes, i.e. update returning true
	If the owner is a ownerObject, i.e. update via sync function, when the effect finishes, it will be removed
	from the object. If the owner is effect, then when update finishes, the parent effect should handle it by itself.
	In summary, the owner is in charge of what happen when the updates finishes.

	2. Don't create the EffectWrap directly.
	Set ownerObject and the effect wrap will be created automatically
**/
@:allow(zf.effects.EffectWrap)
class Effect {
	var wrapper: EffectWrap;

	/**
		The owner of the effect decide who call the `update` function of the Effect.

		If ownerObject is provided, the owner will be the ownerObject.
		If ownerEffect is provided, the owner will the effect.

		If both are not provided, we will assume that it will be handled later by the child

		If ownerObject is also a UIElement, this effect will be added to the UIElement
	**/
	/**
		These needs to be set by the child.

		Only one of the owner can be set at once.
	**/
	public var ownerObject(default, set): h2d.Object;

	var uiElement: UIElement;

	public function set_ownerObject(v: h2d.Object): h2d.Object {
		if (v == this.ownerObject) return this.ownerObject;

		if (this.wrapper == null) this.wrapper = new EffectWrap(this);

		// remove from the previous owner
		if (this.ownerObject != null) this.wrapper.remove();
		if (this.uiElement != null) this.uiElement.uiEffects.remove(this);

		this.ownerObject = null;
		this.uiElement = null;

		if (v == null) return v;
		this.reset();

		// set the owner
		this.ownerObject = v;
		this.ownerObject.addChild(this.wrapper);
		if (Std.isOfType(ownerObject, UIElement)) this.uiElement = cast ownerObject;

		if (this.uiElement != null) {
			if (this.uiElement.uiEffects == null) this.uiElement.uiEffects = [];
			this.uiElement.uiEffects.push(this);
		}
		return this.ownerObject;
	}

	public var ownerEffect(default, set): Effect;

	public function set_ownerEffect(v: Effect): Effect {
		this.ownerEffect = v;
		return this.ownerEffect;
	}

	public function new(conf: EffectConf) {}

	/**
		returns true if this effect is done, false otherwise
	**/
	function update(dt: Float): Bool {
		return true;
	}

	public function onEffectAdd() {}

	public function onEffectRemove() {}

	public function onEffectFinished() {}

	/**
		Reset the effect to the start of the effect.
	**/
	public function reset() {}

	function cleanup() {
		if (this.uiElement != null && this.uiElement.uiEffects != null) this.uiElement.uiEffects.remove(this);
	}

	/**
		Remove the effect

		If the parent is an object, remove from the object
		If the parent is a effect, this will have no effect, the parent will manage it.
	**/
	public function remove() {
		if (this.wrapper != null) this.wrapper.removeFromObject();
	}
}

package zf.effects;

import zf.ui.UIElement;

typedef EffectConf = {};

@:allow(zf.effects.Effect)
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
		var shouldRemove = false;
		/**
			Tue 16:50:11 16 May 2023
			For effects, if it caused exception, we should just remove it and hope for the best 😭
			Crashing because of a effect is not a good idea.
		**/
		try {
			shouldRemove = this.effect.update(ctx.elapsedTime) == true;
		} catch (e) {
			Logger.exception(e);
			shouldRemove = true;
		}
		if (shouldRemove == true) {
			this.effect.onEffectFinished();
			this.effect.ownerObject = null;
			return;
		}
	}
}

/**
	@stage:unstable
	Parent class for Effect

	The idea behind effect is to provide a different way to handle animation or apply effect to an object.
	The previous method of handling this is to use the animator/updater.
	This means that the ownership of the animations is at the updater.

	The goal with the effect system is to provide a way that the object owns the animations rather
	than a class outside. This allow us to have the effect be automatically removed once the object is removed.
	Effect hijack the sync method of h2d.Object to achieve this.

	Effect can also be removed after they are added to the object.
	Child class of effect should override onEffectRemove to handle any cleanup.

	All Effect object should be self-contained.

	A lot of the same functionality from zf.up can be found here.
	- Batch (for running multiple effect at once)
	- Chain (for running effects after one another)
	- Wait (wait for X seconds, only make sense in Chain)

	There are also 2 kinds of effect.
	The first kind is meant to be loop (i.e. effect)
	The second is run and terminate (i.e. animations)

	The first kind is an effect that loops, which means we will need to reset the object to the original state
	when the effect is removed from the object.
	The second kind is almost a mirror of zf.up.animations, just that the owner now is the object rather
	than an animator.

	Sometimes effect can have both, i.e. be configured to behave like either

	Usage (Ideal):

	var effect = new ....Effect(conf); // stored in a global state or something (created once like a factory)
	.
	.
	.
	.
	effect.applyTo(object);

	If we do not want to apply as a factory, i.e. the effect will be use as it is.

	effect.applyTo(object, false);

	Once a effect has been applied to an object but is not removed, applyTo will first remove itself,
	then apply to the new object.

	Key method to override for *All* effects

	1. reset - reset the effect to the initial state after construction
	2. copy - make a copy of the effect (recursively)
	3. update - main update method to update the effect
	4. applyTo - apply the effect to an object (recursively)
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

		Note: Do not use these directly, use apply or removeFrom or remove to modify the effect
	**/
	/**
		These needs to be set by the child.

		Only one of the owner can be set at once.
	**/
	var ownerObject(default, set): h2d.Object;

	var uiElement: UIElement;

	/**
		Parent effect object.
		This is set when effect is created as a "factory"
	**/
	var parent: Effect;

	function set_ownerObject(v: h2d.Object): h2d.Object {
		if (v == this.ownerObject) return this.ownerObject;

		// remove from the previous owner
		if (this.wrapper != null && this.wrapper.parent != null) this.wrapper.remove();
		if (this.ownerObject != null && this.wrapper != null) this.wrapper.remove();
		if (this.uiElement != null && this.uiElement.uiEffects != null) this.uiElement.uiEffects.remove(this);

		this.ownerObject = null;
		this.uiElement = null;

		if (v == null) return null;

		// create the wrapper if not exist
		if (this.wrapper == null) this.wrapper = new EffectWrap(this);

		// set the owner
		this.ownerObject = v;
		this.ownerObject.addChildAt(this.wrapper, 0);
		if (Std.isOfType(ownerObject, UIElement)) this.uiElement = cast ownerObject;

		if (this.uiElement != null) {
			if (this.uiElement.uiEffects == null) this.uiElement.uiEffects = [];
			this.uiElement.uiEffects.push(this);
		}
		return this.ownerObject;
	}

	var ownerEffect(default, set): Effect;

	function set_ownerEffect(v: Effect): Effect {
		this.ownerEffect = v;
		return this.ownerEffect;
	}

	public function new(conf: EffectConf) {}

	/**
		Remove the effect

		If the parent is an object, remove from the object
		If the parent is a effect, this will have no effect, the parent will manage it.
	**/
	public function remove() {
		if (this.ownerObject != null) this.ownerObject = null;
	}

	/**
		Remove the first instance of this effect from an object.
	**/
	public function removeFrom(object: h2d.Object) {
		// This handles non-copy usage of the effect
		if (this.ownerObject == object) {
			this.remove();
			return;
		}
		// This handles when the effect is copied
		if (Std.isOfType(object, UIElement)) {
			// if the element is uielement, we can just loop the uiEffects
			final uie: UIElement = cast object;
			if (uie.uiEffects == null) return;
			for (effect in uie.uiEffects) {
				if (effect.parent == this) {
					effect.remove();
					break;
				}
			}
		} else {
			// sadly I will have to loop all children
			@:privateAccess for (child in object.children) {
				if (Std.isOfType(child, EffectWrap) == false) continue;
				if (cast(child, EffectWrap).effect.parent == this) {
					child.remove();
					break;
				}
			}
		}
	}

	// ---- Key methods to be overridden by children ---- //

	/**
		Reset the effect to the start of the effect.
		Do not remove the parent call when overriding
	**/
	public function reset() {}

	/**
		Make a copy of the effect. Do not call parent when overriding
	**/
	public function copy(): Effect {
		throw new zf.exceptions.NotImplemented();
	}

	/**
		Main update method

		@return true if this effect is to be terminated, false otherwise
	**/
	function update(dt: Float): Bool {
		return true;
	}

	/**
		Apply the effect to an object.
		Do not remove the parent call when overriding.

		If copy is true, child should do *NOTHING*

		@return the effect that is applied to the child. If copy is false, this is returned.
	**/
	public function applyTo(object: h2d.Object, copy: Bool = false): Effect {
		// if copy, make a copy and apply
		if (copy == true) {
			final effect = this.copy();
			effect.parent = this;
			effect.applyTo(object, false);
			return effect;
		}

		// reset the effect
		this.reset();

		// if we are not owned by another effect, we will wrap this object.
		if (this.ownerEffect == null) this.ownerObject = object;
		return this;
	}

	public function onEffectAdd() {}

	public function onEffectRemove() {}

	public function onEffectFinished() {}
}

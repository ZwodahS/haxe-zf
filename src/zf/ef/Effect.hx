package zf.ef;

import zf.ui.UIElement;

/**
	# Motivation
	During the development of CR, I created zf.effects to handle animations and have it owned by
	object instead of zf.up.

	However, since then, I have updated the engine to have object pool.
	With object pool, I need to change the lifecycle of the effect a lot.
	This means we need to rewrite part of Effect.

	Secondly, I also used Effect as a means to handle logic sometimes, which is what zf.up
	was meant to do. The reason why I choose to use Effect instead of zf.up is because
	Effect way of doing things is much easier.

	Since I am rewriting zf.effects -> zf.ef, it is time to unify zf.effects and zf.up.
	At the end of this, zf.effects should be deprecated. zf.up.animations will also be
	deprecated. Both of them will be removed once all code stop using them.

	Here is how zf.effects used to work.

	var effect = new Effect(conf);
	effect.applyTo(object)

	this will hand the object the control of the effect and remove it when it is done.

	effect.applyTo(object, true) also clones the effect, allowing for effect templating.

	we can then allow for a 3rd arg to pass the updater

	effect.applyTo(object, updater);

	the method signature of applyTo will now be

	function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null) {}

	# Lifecycle of effect

	The effect lifecycle is as follows

	1. Constructed
	2. Running
	3. Completed
	4. Disposed (object pool related)

	When the effect is first constructed, it will be in the constructed phase
	This is denote by the fact that "object" key is not set.

	When applyTo is first called, the object key will be set. and this denote the running state.

	When the effect is completed, i.e. update returns true, the effect is completed and removed.
	After which, dispose will be called.

	# Assumption

	1. Effect is always applied to an Object

	# Differences between zf.effects and zf.ef
	- zf.effects uses conf to store the configuration of effect. In zf.ef, we will not use conf
**/
@:allow(zf.ef.Effect)
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class EffectWrap extends h2d.Object {
	var effect: Effect;

	var _blockRemoveCallback = false;

	public function new() {
		super();
	}

	override function onRemove() {
		super.onRemove();
		if (this._blockRemoveCallback == true) return;
		if (this.effect != null) {
			this.effect.onObjectRemoved();
			this.effect.remove();
		}
	}

	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		var isDone = false;

		try {
			isDone = this.effect.update(ctx.elapsedTime) == true;
		} catch (e) {
			Logger.exception(e);
			isDone = true;
		}

		if (isDone == true) {
			this._blockRemoveCallback = true;
			if (this.parent != null) this.remove();
			this._blockRemoveCallback = false;
			this.effect.onEffectCompleted();
			this.effect.remove();
		}
	}

	public static function alloc(effect: Effect): EffectWrap {
		final object = EffectWrap.__alloc__();
		object.effect = effect;
		return object;
	}

	public function reset() {
		this.effect = null;
		// remove it from the object
		this.remove();
	}
}

@:allow(zf.ef.Effect)
#if !macro @:build(zf.macros.ObjectPool.build()) #end
class UpdateWrap {
	/**
		Mon 15:45:32 21 Oct 2024
		Might need to just extends zf.up.Update instead of Updatable
	**/
	@:dispose("set") var effect: Effect = null;

	@:dispose var _isDone: Bool = false;

	public function new() {}

	public function init(u: zf.up.Updater) {}

	public function update(dt: Float) {
		try {
			this._isDone = this.effect.update(dt) == true;
		} catch (e) {
			Logger.exception(e);
			this._isDone = true;
		}
	}

	public function isDone() {
		return this._isDone;
	}

	public function onFinish() {
		if (this.effect != null) this.effect.onEffectCompleted();
	}

	public function onRemoved() {}

	public static function alloc(effect: Effect): UpdateWrap {
		final object = UpdateWrap.__alloc__();
		object.effect = effect;
		return object;
	}
}

@:allow(zf.ef.EffectWrap)
@:allow(zf.ef.UpdateWrap)
class Effect implements Disposable {
	var effectWrap: EffectWrap;

	var updateWrap: UpdateWrap;

	var completed: Bool = false;

	/**
		The object that the effect is applied to.
	**/
	var object: h2d.Object = null;

	/**
		Parent effect object.
		This is set when effect is created as a "factory"
		This is used in removeFrom to identify the effect
	**/
	var parent: Effect;

	/**
		One of this 3 owners will be set
		Owner is used to define who is calling the update function
	**/
	/**
		Effect is owned by the h2d.Object, and is wrapped in effectWrap
	**/
	var ownerObject: h2d.Object = null;

	var uiElement: UIElement = null;

	/**
		Effect is owned by another effect, i.e. Batch or Chain
	**/
	var ownerEffect: Effect = null;

	/**
		Effect is owned by zf.up.Updater, and is wrapped in updateWrap
	**/
	var ownerUpdater: zf.up.Updater = null;

	/**
		Called by onEffectCompleted
	**/
	var whenDoneCallback: Void->Void = null;

	public function new() {}

	/**
		Restart the effect.
		This is used in Loop to reset all the effects to the start
	**/
	public function restart() {}

	public function dispose() {
		/**
			if (this.uiElement != null) {
				if (this.uiElement.uiEffects != null) this.uiElement.uiEffects.remove(this);
				this.uiElement = null;
			}
		**/
		if (this.effectWrap != null) {
			this.effectWrap.dispose();
			this.effectWrap = null;
		}

		if (this.updateWrap != null) {
			this.updateWrap.dispose();
			this.updateWrap = null;
		}

		this.completed = false;
		this.object = null;
		this.ownerObject = null;
		this.ownerEffect = null;
		this.ownerUpdater = null;
		this.parent = null;
		this.whenDoneCallback = null;
	}

	/**
		Make a copy of the effect. Do not call parent when overriding
	**/
	public function clone(): Effect {
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

		@:param copy If copy is true, child should do *NOTHING*
		@:param updater If provided, this effect will run in the updater instead of the object

		@return the effect that is applied to the child. If copy is false, this is returned.
	**/
	public function applyTo(object: h2d.Object, copy: Bool = false, updater: zf.up.Updater = null,
			whenDone: Void->Void = null): Effect {
		/**
			If the effect is already applied to a object, do nothing
		**/
		if (this.object != null) return this;

		// if copy is true, we clone the effect first, and run the apply on the cloned effect
		if (copy == true) {
			final effect = this.clone();
			effect.parent = this;
			effect.applyTo(object, false, updater, whenDone);
			return effect;
		}

		this.object = object;
		if (whenDone != null) this.whenDoneCallback = whenDone;

		// decide who owns the effect
		if (this.ownerEffect != null) {
			// this is owned by another effect, so we do nothing here
		} else if (updater != null) {
			this.updateWrap = UpdateWrap.alloc(this);
			this.ownerUpdater = updater;
			updater.run(this.updateWrap);
		} else {
			this.effectWrap = EffectWrap.alloc(this);
			this.ownerObject = object;
			this.ownerObject.addChildAt(this.effectWrap, 0);
			if (this.ownerObject is UIElement) {
				this.uiElement = cast this.ownerObject;
				if (this.uiElement.uiEffects == null) this.uiElement.uiEffects = [];
				this.uiElement.uiEffects.push(this);
			}
		}
		return this;
	}

	/**
		Remove this effect from this object
	**/
	public function removeFrom(object: h2d.Object) {
		if (this.object == object) {
			this.remove();
			return;
		}

		// In this case, we are trying to remove a cloned effect
		if (object is UIElement && false) {
			/**
				final uie: UIElement = cast object;
				if (uie.uiEffects == null) return;
				for (effect in uie.uiEffects) {
					if (effect.parent == this) {
						effect.remove();
						break;
					}
				}
			**/
		} else {
			// sadly I will have to loop all children
			@:privateAccess for (child in object.children) {
				if (child is EffectWrap == false) continue;
				final wrap: EffectWrap = cast child;
				if (wrap.effect.parent == this) {
					wrap.effect.remove();
					break;
				}
			}
		}
	}

	/**
		Remove this effect
	**/
	public function remove() {
		this.onEffectRemoved();
		this.dispose();
	}

	public function onObjectRemoved() {}

	/**
		This is called when the effect is removed, regardless if it is currently running.
	**/
	public function onEffectRemoved() {}

	/**
		This is called when update returns true
	**/
	public function onEffectCompleted() {
		if (this.whenDoneCallback != null) whenDoneCallback();
	}
}

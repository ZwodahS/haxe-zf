package zf.ui;

import hxd.Cursor;

import zf.h2d.Interactive;

class UIElement extends zf.h2d.Container {
	/**
		flag for if the button is toggled/selected.
	**/
	public var toggled(default, set): Bool = false;

	public function set_toggled(b: Bool): Bool {
		this.toggled = b;
		updateRendering();
		return this.toggled;
	}

	// ---- Bounds Fields ---- //
	public var width(get, never): Float;

	public function get_width() {
		return getSize().width;
	}

	public var height(get, never): Float;

	public function get_height() {
		return getSize().height;
	}

	override function onInteractiveAttached() {
		super.onInteractiveAttached();
		if (this.interactive == null) return;
		this.interactive.enableRightButton = true;
		this.interactive.propagateEvents = false;
	}

	/**
		Called when the element is removed
	**/
	public function onHide() {}

	override public function reset() {
		super.reset();
	}

	// ---- Other ---- //
	override function onRemove() {
		super.onRemove();
		this.onHide();
		if (this.useShowDelay == true) {
			this.visible = false;
			this.showDelayDelta = 0;
		}
		if (this.tooltipWindow != null) this.tooltipWindow.remove();
	}

	/**
		Add custom cursor to the UI Element.
		This should not be used for logic, and instead use for just rendering and playing sound
	**/
	public function addCustomCursors(defaultCursor: Cursor, downCursor: Cursor, toggledCursor: Cursor = null,
			disabledCursor: Cursor = null, onDown: Void->Void = null) {
		if (this.interactive != null) this.interactive.cursor = defaultCursor;
		this.addOnPushListener("UIElement", (e) -> {
			if (this.disabled == true || this.toggled == true) return;
			hxd.System.setCursor(downCursor);
			if (onDown != null) onDown();
		});

		this.addOnReleaseListener("UIElement", (e) -> {
			// Bug: If release outside, it will trigger. Need to fix this.... probably
			hxd.System.setCursor(this.interactive.cursor);
		});
	}

	// ---- Dynamic Layout Stuffs ---- //

	/**
		Tue 15:00:28 15 Aug 2023
		I don't really like using this as the way to handle show delay and delay hover.
		I don't really know how to do this otherwise without having to manually call a update function.
	**/
	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		handleShowDelay(ctx.elapsedTime);
	}

	// ---- Delay showing ---- //

	/**
		If enabled, after the element is added, it will show after X seconds
	**/
	public var showDelay(default, set): Float = 0;

	public function set_showDelay(f: Float): Float {
		this.showDelay = f;
		this.useShowDelay = this.showDelay > 0;
		return this.showDelay;
	}

	public var useShowDelay: Bool = false;

	var showDelayDelta: Float = 0.;

	function handleShowDelay(delta: Float) {
		if (this.visible == false && this.useShowDelay == true) {
			this.showDelayDelta += delta;
			if (this.showDelayDelta >= showDelay) {
				this.visible = true;
				this.showDelayDelta = 0;
			}
		}
	}

	// ---- Factory method ---- //

	/**
		Create a UIElement.

		Tue 16:10:52 31 Jan 2023
		Extending this class the main way to use this.
		The child class should handle the interactive creation manually.

		However, sometimes we just want to create a simple element around the object with a interactive
	**/
	public static function makeWithObject(object: h2d.Object, center: Bool = false) {
		final uie = new UIElement();
		uie.addChild(object);
		final bounds = object.getBounds();
		uie.interactive = new Interactive(bounds.width, bounds.height);
		uie.addChild(uie.interactive);
		if (center == true) {
			uie.x = object.x + (bounds.width / 2);
			uie.y = object.y + (bounds.height / 2);
			object.x = -bounds.width / 2;
			object.y = -bounds.height / 2;
			uie.interactive.x = -bounds.width / 2;
			uie.interactive.y = -bounds.height / 2;
		}
		return uie;
	}

	public static function makeWithInteractive(size: Point2i) {
		final uie = new UIElement();
		uie.interactive = new Interactive(size.x, size.y);
		uie.addChild(uie.interactive);
		return uie;
	}
}
/**
	Motivation:

	Often I want to create UI Element onto the screen that are not static, like icons, etc.
	These UI elements usually have features like

	- handling click events
	- tooltips
	- disabling

	Due to the architecture, most of the logic are not in the UIElement, but are in the systems.
	Because of that, I will need to have dynamic functions to handle these interactions,
	and most of the time I need access to the interactive object.

	Wed 19:58:48 02 Nov 2022
	WIP, might want to change of the code here but the idea should be quite fixed.
	Essentially this will be a generalised form of zf.ui.Button
	Ideally that will be refactored to extend this instead.

	Mon 11:44:42 07 Nov 2022
	Another question is whether or not we want Windows to extends this.
	For now we will opt not to do that.

	Tue 15:08:30 31 Jan 2023
	Add tooltip handling

	Sat 15:58:06 02 Aug 2025
	Migrate code to Container.
	UIElement might be deprecated in the future.
**/

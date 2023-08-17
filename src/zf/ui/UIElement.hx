package zf.ui;

import zf.ui.layout.DynamicLayout;
import zf.ui.layout.DynamicLayout.DynamicPosition;
import zf.h2d.Interactive;

import hxd.Cursor;

typedef TooltipShowConf = {
	> zf.ui.WindowRenderSystem.ShowWindowConf,

	/**
		If this is set to true, then instead of showing above the bounds,
		the window will be shown at the cursor instead.
	**/
	public var ?relativeToCursor: Bool;
}

/**
	@stage:stable

	A parent class for all UIElement
**/
class UIElement extends h2d.Object {
	// ---- Interactive Fields ---- //

	/**
		The main interactive for the UIElement
	**/
	public var interactive(default, set): Interactive;

	inline function set_interactive(i: Interactive): Interactive {
		this.interactive = i;
		// note that the interactive is not added to any parent.
		onInteractiveAttached();
		return this.interactive;
	}

	/**
		Set if the element is disabled
	**/
	public var disabled(default, set): Bool = false;

	function set_disabled(b: Bool): Bool {
		this.disabled = b;
		updateRendering();
		return this.disabled;
	}

	/**
		flag for if the button is toggled/selected.
	**/
	public var toggled(default, set): Bool = false;

	public function set_toggled(b: Bool): Bool {
		this.toggled = b;
		updateRendering();
		return this.toggled;
	}

	/**
		Flag for whether the mouse is over the element
	**/
	public var isOver(default, null): Bool = false;

	// ---- Bounds Fields ---- //
	public var width(get, never): Float;

	function get_width() return getSize().width;

	public var height(get, never): Float;

	function get_height() return getSize().height;

	public function new() {
		super();
		this.hoverDelay = UIElement.defaultHoverDelay;
	}

	/**
		Handling on Interactive attached.
		Do not remove super call when overriding
	**/
	function onInteractiveAttached() {
		if (this.interactive == null) return;
		this.interactive.enableRightButton = true;
		this.interactive.propagateEvents = false;

		this.interactive.dyOnRemove = function() {
			_dyOnRemove();
		}
		this.interactive.onOver = function(e: hxd.Event) {
			this.isOver = true;
			updateRendering();
			_onOver(e);
		}
		this.interactive.onOut = function(e: hxd.Event) {
			this.isOver = false;
			updateRendering();
			_onOut(e);
		}
		this.interactive.onClick = function(e: hxd.Event) {
			if (this.disabled) return;
			if (e.button == 0) {
				_onLeftClick(e);
			} else if (e.button == 1) {
				_onRightClick(e);
			}
			_onClick(e);
		}
		this.interactive.onPush = function(e: hxd.Event) {
			updateRendering();
			_onPush(e);
		}
		this.interactive.onRelease = function(e: hxd.Event) {
			updateRendering();
			_onRelease(e);
		}
		this.interactive.onWheel = function(e: hxd.Event) {
			updateRendering();
			_onWheel(e);
		}
		this.interactive.onKeyDown = function(e: hxd.Event) {
			updateRendering();
			_onKeyDown(e);
		}
		this.interactive.onKeyUp = function(e: hxd.Event) {
			updateRendering();
			_onKeyUp(e);
		}
		this.interactive.onMove = function(e: hxd.Event) {
			updateRendering();
			_onMove(e);
		}
	}

	/**
		Called to update the rendering of the element.
	**/
	function updateRendering() {}

	/**
		Called when the element is shown via WindowRenderSystem
	**/
	public function onShow() {}

	/**
		Called when the element is removed
	**/
	public function onHide() {}

	// ---- For Interactive and handle custom cursors ---- //

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

	// ---- Tooltips ---- //

	/**
		If tooltip window is set, this will be shown when on over
		The tooltipHelper must also be set so we can show the window properly
	**/
	public var tooltipWindow(default, set): UIElement;

	public function set_tooltipWindow(e: UIElement): UIElement {
		this.tooltipWindow = e;
		if (tooltipWindow == null) {
			this.removeAllListeners("UIElement.tooltip");
		} else {
			this.addOnOverListener("UIElement.tooltip", showTooltip);
			this.addOnOutListener("UIElement.tooltip", hideTooltip);
			this.addOnMoveListener("UIElement.tooltip", moveTooltip);
		}
		return this.tooltipWindow;
	}

	function showTooltip(e: hxd.Event) {
		if (this.tooltipWindow == null) return;
		if (this.tooltipHelper == null) return;
		this.tooltipHelper.showWindow(this.tooltipWindow, getTooltipBounds(), this.tooltipShowConf);
		if (this.tooltipShowConf != null && this.tooltipShowConf.relativeToCursor == true) {
			moveTooltip(e);
		}
	}

	function hideTooltip(e: hxd.Event) {
		if (this.tooltipWindow == null) return;
		if (this.tooltipHelper != null && this.tooltipWindow.parent != this.tooltipHelper.windowRenderSystem.layer)
			return;
		this.tooltipWindow.remove();
	}

	function moveTooltip(e: hxd.Event) {
		if (this.tooltipWindow == null || this.tooltipWindow.parent == null) return;
		if (this.tooltipShowConf == null || this.tooltipShowConf.relativeToCursor != true) return;
		final scene = this.getScene();
		final positionX = scene.mouseX;
		final positionY = scene.mouseY;
		this.tooltipHelper.windowRenderSystem.adjustWindowPosition(this.tooltipWindow,
			h2d.col.Bounds.fromValues(positionX - 2, positionY - 2, 4, 4), this.tooltipShowConf);
	}

	/**
		The relative bound to show the tooltip
		Ideally, this should return the bounds relative to a common parent of window layer and this element.
	**/
	dynamic public function getTooltipBounds(): h2d.col.Bounds {
		return null;
	}

	/**
		The tooltip helper used to show the tooltip window
	**/
	public var tooltipHelper: TooltipHelper;

	/**
		The conf used to show the window
	**/
	public var tooltipShowConf: TooltipShowConf = null;

	// ---- Event handling for the interactive ---- //

	/**
		Thu 09:55:16 03 Nov 2022
		This uses the same handling as interactive component.
		Instead of creating new interactive, we will add listeners to the interactive in this element.
		This allow us not to have to redefine the interactive especially when there is complex shape involved.
		On top of that, this fits into the system architecture approach.
	**/
	// ---- On out ---- //
	var onOutListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onOut(e: hxd.Event) {
		this.hoverDelayEvent = null;
		for (p in this.onOutListeners) p.second(e);
	}

	public function addOnOutListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onOutListeners) {
			if (o.first == id) return false;
		}
		this.onOutListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnOutListener(id: String): Bool {
		for (o in this.onOutListeners) {
			if (o.first == id) {
				this.onOutListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Over ---- //
	var onOverListeners: Array<Pair<String, hxd.Event->Void>> = [];

	/**
		Hover delay
		This is set to 0.05 (aka 3 frames @ 60fps) so that the on hover don't get triggered immediately for just moving
		over elements, and 0.05 is quite reasonable.
		This can be overriden if some part of the game feels sluggish
	**/
	public static var defaultHoverDelay: Float = 0.05;

	public var hoverDelay: Float = 0.05;

	var hoverDelayDelta: Float = 0.;
	var hoverDelayEvent: hxd.Event = null;

	public function _onOver(e: hxd.Event) {
		if (this.hoverDelay > 0) {
			this.hoverDelayDelta = 0;
			this.hoverDelayEvent = e;
			return;
		}
		for (p in this.onOverListeners) p.second(e);
	}

	function handleDelayHover(dt: Float) {
		if (this.isOver == true && this.hoverDelay > 0 && this.hoverDelayEvent != null) {
			this.hoverDelayDelta += dt;
			if (this.hoverDelayDelta > this.hoverDelay) {
				final e = this.hoverDelayEvent;
				this.hoverDelayEvent = null;
				for (p in this.onOverListeners) p.second(e);
			}
		}
	}

	public function addOnOverListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onOverListeners) {
			if (o.first == id) return false;
		}
		this.onOverListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnOverListener(id: String): Bool {
		for (o in this.onOverListeners) {
			if (o.first == id) {
				this.onOverListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Click ---- //
	var onClickListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onClick(e: hxd.Event) {
		for (p in this.onClickListeners) p.second(e);
	}

	public function addOnClickListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onClickListeners) {
			if (o.first == id) return false;
		}
		this.onClickListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnClickListener(id: String): Bool {
		for (o in this.onClickListeners) {
			if (o.first == id) {
				this.onClickListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Left Click ---- //
	var onLeftClickListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onLeftClick(e: hxd.Event) {
		for (p in this.onLeftClickListeners) p.second(e);
	}

	public function addOnLeftClickListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onLeftClickListeners) {
			if (o.first == id) return false;
		}
		this.onLeftClickListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnLeftClickListener(id: String): Bool {
		for (o in this.onLeftClickListeners) {
			if (o.first == id) {
				this.onLeftClickListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Right Click ---- //
	var onRightClickListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onRightClick(e: hxd.Event) {
		for (p in this.onRightClickListeners) p.second(e);
	}

	public function addOnRightClickListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onRightClickListeners) {
			if (o.first == id) return false;
		}
		this.onRightClickListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnRightClickListener(id: String): Bool {
		for (o in this.onRightClickListeners) {
			if (o.first == id) {
				this.onRightClickListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Push ---- //
	var onPushListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onPush(e: hxd.Event) {
		for (p in this.onPushListeners) p.second(e);
	}

	public function addOnPushListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onPushListeners) {
			if (o.first == id) return false;
		}
		this.onPushListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnPushListener(id: String): Bool {
		for (o in this.onPushListeners) {
			if (o.first == id) {
				this.onPushListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Release ---- //
	var onReleaseListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onRelease(e: hxd.Event) {
		for (p in this.onReleaseListeners) p.second(e);
	}

	public function addOnReleaseListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onReleaseListeners) {
			if (o.first == id) return false;
		}
		this.onReleaseListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnReleaseListener(id: String): Bool {
		for (o in this.onReleaseListeners) {
			if (o.first == id) {
				this.onReleaseListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Wheel ---- //
	var onWheelListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onWheel(e: hxd.Event) {
		for (p in this.onWheelListeners) p.second(e);
	}

	public function addOnWheelListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onWheelListeners) {
			if (o.first == id) return false;
		}
		this.onWheelListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnWheelListener(id: String): Bool {
		for (o in this.onWheelListeners) {
			if (o.first == id) {
				this.onWheelListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Removed ---- //
	var onRemoveListeners: Array<Pair<String, Void->Void>> = [];

	public function _dyOnRemove() {
		for (p in this.onRemoveListeners) p.second();
	}

	public function addOnRemoveListener(id: String, func: Void->Void): Bool {
		for (o in this.onRemoveListeners) {
			if (o.first == id) return false;
		}
		this.onRemoveListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnRemoveListener(id: String): Bool {
		for (o in this.onRemoveListeners) {
			if (o.first == id) {
				this.onRemoveListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Key Down ---- //
	var onKeyDownListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onKeyDown(e: hxd.Event) {
		for (p in this.onKeyDownListeners) p.second(e);
	}

	public function addOnKeyDownListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onKeyDownListeners) {
			if (o.first == id) return false;
		}
		this.onKeyDownListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnKeyDownListener(id: String): Bool {
		for (o in this.onKeyDownListeners) {
			if (o.first == id) {
				this.onKeyDownListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Key Up ---- //
	var onKeyUpListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onKeyUp(e: hxd.Event) {
		for (p in this.onKeyUpListeners) p.second(e);
	}

	public function addOnKeyUpListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onKeyUpListeners) {
			if (o.first == id) return false;
		}
		this.onKeyUpListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnKeyUpListener(id: String): Bool {
		for (o in this.onKeyUpListeners) {
			if (o.first == id) {
				this.onKeyUpListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- On Move ---- //
	var onMoveListeners: Array<Pair<String, hxd.Event->Void>> = [];

	public function _onMove(e: hxd.Event) {
		for (p in this.onMoveListeners) p.second(e);
	}

	public function addOnMoveListener(id: String, func: hxd.Event->Void): Bool {
		for (o in this.onMoveListeners) {
			if (o.first == id) return false;
		}
		this.onMoveListeners.push(new Pair(id, func));
		return true;
	}

	public function removeOnMoveListener(id: String): Bool {
		for (o in this.onMoveListeners) {
			if (o.first == id) {
				this.onMoveListeners.remove(o);
				return true;
			}
		}
		return false;
	}

	// ---- remove all listeners ---- //
	public function removeAllListeners(id: String) {
		removeOnOutListener(id);
		removeOnOverListener(id);
		removeOnClickListener(id);
		removeOnLeftClickListener(id);
		removeOnRightClickListener(id);
		removeOnPushListener(id);
		removeOnReleaseListener(id);
		removeOnRemoveListener(id);
		removeOnMoveListener(id);
		removeOnKeyUpListener(id);
		removeOnKeyDownListener(id);
	}

	public function reset() {
		this.isOver = false;
		updateRendering();
	}

	// ---- Override parent methods ---- //
	override function onRemove() {
		super.onRemove();
		this.onHide();
		if (this.useShowDelay == true) {
			this.visible = false;
			this.showDelayDelta = 0;
		}
		if (this.tooltipWindow != null) this.tooltipWindow.remove();
	}

	// ---- For effects ---- //

	/**
		Store all the effects added to the element.
		Do not add directly to this.
	**/
	public var uiEffects: Array<zf.effects.Effect>;

	// ---- Other ---- //

	/**
		Tue 15:00:28 15 Aug 2023
		I don't really like using this as the way to handle show delay and delay hover.
		I don't really know how to do this otherwise without having to manually call a update function.
	**/
	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		handleShowDelay(ctx.elapsedTime);
		handleDelayHover(ctx.elapsedTime);
	}

	// ---- Dynamic Layout Stuffs ---- //

	/**
		This part of the code works with DynamicLayout

		See DynamicLayout for more information
	**/
	public var position: DynamicPosition;

	/**
		Reposition the UIElement relative to the parent resize.
		If parent is not a DynamicLayout or if the dynamic position is not set, nothing happens.

		Child class can override this
	**/
	public function reposition() {
		// if there is no position, return
		if (this.position == null) return;
		if (this.parent == null || Std.isOfType(this.parent, DynamicLayout) == false) return;
		final layout: DynamicLayout = cast this.parent;
		@:privateAccess final size: Point2i = layout.size;

		/**
		**/
		switch (this.position) {
			case Fixed(x, y):
				this.x = x;
				this.y = y;
			case AnchorTopLeft(spacingX, spacingY):
				final bounds = this.getBounds(this);
				this.x = 0 + spacingX - bounds.xMin;
				this.y = 0 + spacingY - bounds.yMin;
			case AnchorTopCenter(spacingX, spacingY):
				final bounds = this.getBounds(this);
				this.x = ((size.x - bounds.width) / 2) + spacingX - bounds.xMin;
				this.y = 0 + spacingY - bounds.yMin;
			case AnchorTopRight(spacingX, spacingY):
				final bounds = this.getBounds(this);
				this.x = size.x - bounds.width - bounds.xMin - spacingX;
				this.y = spacingY - bounds.yMin;
			case AnchorCenter(spacingX, spacingY):
				final bounds = this.getBounds(this);
				this.x = ((size.x - bounds.width) / 2) + spacingX - bounds.xMin;
				this.y = ((size.y - bounds.height) / 2) + spacingY - bounds.yMin;
			case AnchorBottomLeft(spacingX, spacingY):
				final bounds = this.getBounds(this);
				this.x = spacingX - bounds.xMin;
				this.y = size.y - bounds.height - bounds.yMin - spacingY;
			case AnchorBottomRight(spacingX, spacingY):
				final bounds = this.getBounds(this);
				this.x = size.x - bounds.width - bounds.xMin - spacingX;
				this.y = size.y - bounds.height - bounds.yMin - spacingY;
		}
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
**/

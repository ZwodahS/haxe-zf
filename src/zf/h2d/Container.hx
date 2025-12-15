package zf.h2d;

import zf.h2d.Interactive;
import zf.ui.TooltipHelper;

typedef DragHandler = {
	/**
		If not provided, default false
	**/
	public var ?allowRightClick: Bool;

	/**
		Called at the start of drag and return an object that is being moved around
		Returning uie will just drag the object around.

		Use this function to add the object to the dragging layer
	**/
	public var onStartDrag: (uie: Container, e: hxd.Event) -> h2d.Object;

	/**
		Called when the drag stop
	**/
	public var ?onRelease: (h2d.Object, hxd.Event) -> Void;

	/**
		Called when the drag stop
	**/
	public var ?onReleaseOutside: (o: h2d.Object, hxd.Event) -> Void;

	/**
		Called when another key is push
	**/
	public var ?onPush: (h2d.Object, hxd.Event) -> Void;

	/**
		Called when the object is moved
	**/
	public var ?onMove: (h2d.Object, hxd.Event) -> Void;
}

typedef TooltipShowConf = {
	> zf.ui.WindowRenderSystem.ShowWindowConf,

	/**
		If this is set to true, then instead of showing above the bounds,
		the window will be shown at the cursor instead.
	**/
	public var ?relativeToCursor: Bool;
}

/**
	A parent class for all container type object
**/
class Container extends Object {
	// ---- Override h2d.Object ---- //
	override function setParentContainer(c) {
		// a container will ensure that this container will be the parent container for all child objects
		this.parentContainer = c;
	}

	override function addChildAt(child: h2d.Object, pos: Int) {
		super.addChildAt(child, pos);
		child.setParentContainer(this);
	}

	// ---- Override parent methods ---- //
	override function onRemove() {
		super.onRemove();
		if (this.tooltipWindow != null) this.tooltipWindow.remove();
	}

	override function sync(ctx: h2d.RenderContext) {
		super.sync(ctx);
		handleDelayHover(ctx.elapsedTime);
	}

	// ---- Interactive Fields ---- //

	/**
		The main interactive for the Container
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
		Flag for whether the mouse is over the element
	**/
	public var isOver(default, set): Bool = false;

	public function set_isOver(v: Bool): Bool {
		this.isOver = v;
		updateRendering();
		return this.isOver;
	}

	public function new() {
		super();
		this.hoverDelay = Container.defaultHoverDelay;
	}

	/**
		Trigger when interactive is attached.
		Child class are in charged of positioning the interactive.
	**/
	function onInteractiveAttached() {
		if (this.interactive == null) return;

		this.interactive.dyOnRemove = function() {
			_dyOnRemove();
		}
		this.interactive.onOver = function(e: hxd.Event) {
			this.isOver = true;
			_onOver(e);
		}
		this.interactive.onOut = function(e: hxd.Event) {
			this.isOver = false;
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

	// ---- Tooltips ---- //

	/**
		If tooltip window is set, this will be shown when on over
		The tooltipHelper must also be set so we can show the window properly
	**/
	public var tooltipWindow(default, set): Container;

	public function set_tooltipWindow(e: Container): Container {
		this.tooltipWindow = e;
		if (tooltipWindow == null) {
			this.removeAllListeners("Container.tooltip");
		} else {
			this.addOnOverListener("Container.tooltip", _showTooltip);
			this.addOnOutListener("Container.tooltip", _hideTooltip);
			this.addOnMoveListener("Container.tooltip", _moveTooltip);
		}
		return this.tooltipWindow;
	}

	public function showTooltip() {
		if (this.tooltipWindow == null) return;
		if (this.tooltipHelper == null) return;
		this.tooltipHelper.showWindow(this.tooltipWindow, getTooltipBounds(), this.tooltipShowConf);
	}

	public function hideTooltip() {
		if (this.tooltipWindow == null) return;
		if (this.tooltipHelper != null && this.tooltipWindow.parent != this.tooltipHelper.windowRenderSystem.layer)
			return;
		this.tooltipWindow.remove();
	}

	function _showTooltip(e: hxd.Event) {
		if (this.tooltipWindow == null) return;
		if (this.tooltipHelper == null) return;
		this.tooltipHelper.showWindow(this.tooltipWindow, getTooltipBounds(), this.tooltipShowConf);
		if (this.tooltipShowConf != null && this.tooltipShowConf.relativeToCursor == true) {
			_moveTooltip(e);
		}
	}

	function _hideTooltip(e: hxd.Event) {
		hideTooltip();
	}

	function _moveTooltip(e: hxd.Event) {
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
		if (this.tooltipHelper != null) return this.getBounds(this.tooltipHelper.referenceLayer);
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

	// ---- Handle Dragging ---- //
	public var dragHandler(default, set): DragHandler;

	public function set_dragHandler(v: DragHandler): DragHandler {
		/**
			If the dragHandler is not null, then we don't have set up anymore
		**/
		final old = this.dragHandler;

		this.dragHandler = v;
		if (old == null && this.dragHandler != null) {
			this.addOnPushListener("Container.dragHandler", (e) -> {
				if (e.button != 0 && this.dragHandler.allowRightClick != true) return;
				final dragObject = this.dragHandler.onStartDrag(this, e);
				final scene = dragObject.getScene();
				if (scene == null) return;

				final bounds = dragObject.getBounds();
				var offsetX = bounds.width / 2;
				var offsetY = bounds.height / 2;

				scene.startCapture((e) -> {
					switch (e.kind) {
						case ERelease:
							if (this.dragHandler != null && this.dragHandler.onRelease != null) {
								this.dragHandler.onRelease(dragObject, e);
							}
							scene.stopCapture();
						case EReleaseOutside:
							if (this.dragHandler != null && this.dragHandler.onReleaseOutside != null) {
								this.dragHandler.onReleaseOutside(dragObject, e);
							}
							scene.stopCapture();
						case EPush:
							if (this.dragHandler != null && this.dragHandler.onPush != null) {
								this.dragHandler.onPush(dragObject, e);
							}
						case EMove:
							final positionX = e.relX;
							final positionY = e.relY;
							final pos = dragObject.parent.globalToLocal(new h2d.col.Point(positionX, positionY));
							dragObject.x = Std.int(pos.x - offsetX);
							dragObject.y = Std.int(pos.y - offsetY);
							if (this.dragHandler != null && this.dragHandler.onMove != null) {
								this.dragHandler.onMove(dragObject, e);
							}
						default:
					}
					e.propagate = false;
				});
			});
		}
		return this.dragHandler;
	}

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

	override public function reset() {
		this.isOver = false;
		this.tooltipHelper = null;
		this.tooltipShowConf = null;
		this.tooltipWindow = null;
		this.onOutListeners.clear();
		this.onOverListeners.clear();
		this.onClickListeners.clear();
		this.onLeftClickListeners.clear();
		this.onRightClickListeners.clear();
		this.onPushListeners.clear();
		this.onReleaseListeners.clear();
		this.onWheelListeners.clear();
		this.onRemoveListeners.clear();
		this.onKeyDownListeners.clear();
		this.onKeyUpListeners.clear();
		this.onMoveListeners.clear();
		updateRendering();
	}
}

/**
	Sat 15:41:26 02 Aug 2025
	Refactored some parts of DynamicLayout into a Container.
**/

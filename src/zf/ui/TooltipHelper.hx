package zf.ui;

import zf.ui.WindowRenderSystem.ShowWindowConf;
import zf.h2d.Interactive;

/**
	@stage:stable

	A generic tooltip helper
**/
class TooltipHelper {
	public var windowRenderSystem: WindowRenderSystem;

	public function new(windowRenderSystem: WindowRenderSystem) {
		this.windowRenderSystem = windowRenderSystem;
	}

	// ---- Tooltip handling  ---- //
	public function attachWindowTooltip(obj: h2d.Object, window: Window, conf: ShowWindowConf = null): Window {
		final bound = obj.getSize();
		final width = Std.int(bound.width);
		final height = Std.int(bound.height);
		var interactive = new Interactive(width, height, obj);

		if (conf == null) conf = {overrideSpacing: 5};

		interactive.onOver = function(e: hxd.Event) {
			final bound = obj.getBounds();
			window.onShow();
			this.windowRenderSystem.showWindow(window, bound, conf);
		}

		interactive.onOut = function(e: hxd.Event) {
			window.remove();
			window.onHide();
		}

		interactive.dyOnRemove = function() {
			if (window.parent != null) {
				window.remove();
				window.onHide();
			}
		}
		interactive.propagateEvents = true;

		return window;
	}

	/**
		Forward this to window render system
	**/
	inline public function showWindow(w: h2d.Object, r: h2d.col.Bounds = null, conf: ShowWindowConf = null) {
		return this.windowRenderSystem.showWindow(w, r, conf);
	}
}

package zf.ui;

import zf.ui.WindowRenderSystem.ShowWindowConf;
import zf.h2d.Interactive;

/**
	A generic tooltip helper
**/
class TooltipHelper {
	public var windowRenderSystem: WindowRenderSystem;

	public var referenceLayer(get, never): h2d.Object;

	public var overrideReferenceLayer: h2d.Object = null;

	inline public function get_referenceLayer(): h2d.Object {
		return this.overrideReferenceLayer != null ? this.overrideReferenceLayer : this.windowRenderSystem.layer;
	}

	public function new(windowRenderSystem: WindowRenderSystem) {
		this.windowRenderSystem = windowRenderSystem;
	}

	/**
		Forward this to window render system
	**/
	inline public function showWindow(w: h2d.Object, r: h2d.col.Bounds = null, conf: ShowWindowConf = null) {
		return this.windowRenderSystem.showWindow(w, r, conf);
	}
}

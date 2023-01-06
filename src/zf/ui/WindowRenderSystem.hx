package zf.ui;

import zf.Direction;

using zf.h2d.col.BoundsExtensions;

typedef ShowWindowConf = {
	/**
		If true, the window will be adjusted to fit into the renderingBounds. (default. true)
	**/
	public var ?adjustWindow: Bool;

	/**
		The prefer direction to render the window.
		Allowed direction [Down, Right, Up, Left]
		Any direction other than these 4 will be ignored.
	**/
	public var ?preferredDirection: Array<Direction>;

	/**
		If provided, this will override the spacing defined in WindowRenderSystem
	**/
	public var ?overrideSpacing: Float;
}

/**
	@stage:stable

	Manage Window within a certain bound.
**/
class WindowRenderSystem {
	/**
		provide the layer to draw. If not provided, one will be created
	**/
	public var layer: h2d.Layers;

	/**
		The bounds that the window can be render on
	**/
	public var renderingBounds: h2d.col.Bounds;

	public var defaultSpacing: Float = 1;

	public var defaultRenderDirection: Array<Direction> = [Down, Right, Up, Left];

	public function new(bounds: h2d.col.Bounds, layer: h2d.Layers = null) {
		layer = layer != null ? layer : new h2d.Layers();
		this.layer = layer;
		this.renderingBounds = bounds;
	}

	/**
		Thu 15:35:36 24 Feb 2022
		For now we will accept all h2d.Object, might change before moving to zf
	**/
	public function showWindow(w: h2d.Object, relativeTo: h2d.col.Bounds = null, conf: ShowWindowConf = null) {
		var adjustWindow: Bool = true;
		if (conf != null && conf.adjustWindow != null) adjustWindow = conf.adjustWindow;

		if (Std.isOfType(w, zf.ui.Window)) {
			cast(w, zf.ui.Window).onShow();
		}

		this.layer.addChild(w);

		if (adjustWindow == true) {
			adjustWindowPosition(w, relativeTo, conf);
		}
	}

	public function adjustWindowPosition(w: h2d.Object, relativeTo: h2d.col.Bounds = null,
			conf: ShowWindowConf = null) {
		// if there is no relative bound, we will just use the current position of w and force it within
		// the boundary of renderingBounds
		if (relativeTo == null) return forceWindowWithinBound(w);

		// get the preferred direction
		var preferredOrder: Array<Direction> = this.defaultRenderDirection;
		if (conf != null && conf.preferredDirection != null) preferredOrder = conf.preferredDirection;

		var spacing = this.defaultSpacing;
		if (conf != null && conf.overrideSpacing != null) spacing = conf.overrideSpacing;

		final wBounds = w.getBounds();
		function getBoundsInDirection(direction: Direction): h2d.col.Bounds {
			var b = wBounds.clone();
			switch (direction) {
				case Up:
					b.x = relativeTo.xMin;
					b.y = relativeTo.yMin - spacing - b.height;
				case Down:
					b.x = relativeTo.xMin;
					b.y = relativeTo.yMax + spacing;
				case Left:
					b.x = relativeTo.xMin - spacing - b.width;
					b.y = relativeTo.yMin;
				case Right:
					b.x = relativeTo.xMax + spacing;
					b.y = relativeTo.yMin;
				default:
					return null;
			}
			return b;
		}

		for (direction in preferredOrder) {
			final testBound = getBoundsInDirection(direction);
			// let's test each of this
			if (this.renderingBounds.containsBounds(testBound)) {
				// if the testBounds works, we are done :)
				w.x = testBound.x;
				w.y = testBound.y;
				return;
			}
			// if it doesn't work, we will need to see if we can adjust
			// check the details on how it is intersecting
			final iDetails = this.renderingBounds.intersectWithDetails(testBound);

			if (direction == Up || direction == Down) {
				// if the direction is up|down, we can only shift left and right
				// if y is not contained, then we will not shift
				if (iDetails.yType != Contains) continue;

				// adjust x
				switch (iDetails.xType) {
					case Negative:
						testBound.x = renderingBounds.xMax - testBound.width;
					case Positive:
						testBound.x = renderingBounds.xMin;
					default:
				}
			} else if (direction == Left || direction == Right) {
				// if the direction is left|right, we can only shift up and down
				if (iDetails.xType != Contains) continue;

				// adjust y
				switch (iDetails.yType) {
					case Negative:
						testBound.y = renderingBounds.yMax - testBound.height;
					case Positive:
						testBound.y = renderingBounds.yMin;
					default:
				}
			}

			// test if we can place the new bound
			if (this.renderingBounds.containsBounds(testBound)) {
				w.x = testBound.x;
				w.y = testBound.y;
				return;
			}
		}

		// if all else fails, force the window within bound
		forceWindowWithinBound(w);
	}

	function forceWindowWithinBound(w: h2d.Object) {
		final bounds = w.getBounds();
		if (bounds.xMax >= this.renderingBounds.xMax) {
			w.x = this.renderingBounds.xMax - bounds.width;
		} else if (bounds.xMin < this.renderingBounds.xMin) {
			w.x = this.renderingBounds.xMin;
		}

		if (bounds.yMax >= this.renderingBounds.yMax) {
			w.y = this.renderingBounds.yMax - bounds.height;
		} else if (bounds.yMin < this.renderingBounds.yMin) {
			w.x = this.renderingBounds.yMin;
		}
	}
}

/**
	# Thu 15:30:24 24 Feb 2022
	This is planned to be moved into zf, hence written in a very generic way.
	Also, this might be useful to merge with TooltipHelper

	# Sun 13:12:54 03 Apr 2022
	Added this to zf temporary to help with LD50.
	Refactor later
	This is also merged with TooltipHelper as well. Deal with that later

	# Sat 14:56:25 30 Jul 2022
	R lefactor and clean up the tooltip code and move it into a tooltiphelper
**/

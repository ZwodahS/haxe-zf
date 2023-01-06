package zf.h2d.col;

import zf.Rectf;

/**
	@stage:stable
**/
class BoundsExtensions {
	/**
		Check if a bound is fully contain in another.

		@param parent the bigger bound
		@param child the smaller bound
		@return true if child is fully contained in parent, false otherwise
	**/
	public static function containsBounds(parent: h2d.col.Bounds, child: h2d.col.Bounds): Bool {
		return (child.xMin >= parent.xMin
			&& child.xMax <= parent.xMax
			&& child.yMin >= parent.yMin
			&& child.yMax <= parent.yMax);
	}

	/**
		Provide information on the intersection between 2 bounds
	**/
	public static function intersectWithDetails(b1: h2d.col.Bounds, b2: h2d.col.Bounds): IntersectDetail {
		// this is copied from Rectf, because I don't want to construct a Rectf just to perform this operation
		var xDetail = Rectf.intersectType(b1.xMin, b1.xMax, b2.xMin, b2.xMax);
		if (xDetail.type == None) return {
			x: 0,
			y: 0,
			xType: None,
			yType: None
		};
		var yDetail = Rectf.intersectType(b1.yMin, b1.yMax, b2.yMin, b2.yMax);
		if (yDetail.type == None) return {
			x: 0,
			y: 0,
			xType: None,
			yType: None
		};
		return {
			x: xDetail.amount,
			y: yDetail.amount,
			xType: xDetail.type,
			yType: yDetail.type
		};
	}
}

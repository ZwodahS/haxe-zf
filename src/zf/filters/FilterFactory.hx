package zf.filters;

/**
	@stage:stable
	Extends h2d.filter.Filter to provide some simple filter constructor
**/
class FilterFactory {
	public static function makeColorSaturate(f: Float): h2d.filter.ColorMatrix {
		final m = new h3d.Matrix();
		m.identity();
		m.colorSaturate(f);
		return new h2d.filter.ColorMatrix(m);
	}
}

package zf.filters;

class Filters {
	@:deprecated
	public static function makeColorSaturate(f: Float): h2d.filter.ColorMatrix {
		final m = new h3d.Matrix();
		m.identity();
		m.colorSaturate(f);
		return new h2d.filter.ColorMatrix(m);
	}

	public static function saturation(f: Float): h2d.filter.ColorMatrix {
		final m = new h3d.Matrix();
		m.identity();
		m.colorSaturate(f);
		return new h2d.filter.ColorMatrix(m);
	}
}

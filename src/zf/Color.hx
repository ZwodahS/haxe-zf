package zf;

using zf.math.MathExtensions;

/**
	@stage:stable

	Color will be immutable, so all method will return a new instance of Color

	Methods will be added when needed
**/
abstract Color(Int) from Int to Int {
	public var alpha(get, set): Int;

	public function get_alpha(): Int {
		return (this & 0xff000000) >>> (8 * 3);
	}

	inline public function set_alpha(v: Int): Int {
		v = Math.clampI(v, 0, 255);
		this = (this & 0x00ffffff) + (v << (8 * 3));
		return this;
	}

	public var red(get, set): Int;

	inline public function get_red(): Int {
		return (this & 0x00ff0000) >>> (8 * 2);
	}

	inline public function set_red(v: Int): Int {
		v = Math.clampI(v, 0, 255);
		this = (this & 0xff00ffff) + (v << (8 * 2));
		return this;
	}

	public var green(get, set): Int;

	inline public function get_green(): Int {
		return (this & 0x0000ff00) >>> (8 * 1);
	}

	inline public function set_green(v: Int): Int {
		v = Math.clampI(v, 0, 255);
		this = (this & 0xffff00ff) + (v << (8));
		return this;
	}

	public var blue(get, set): Int;

	inline public function get_blue(): Int {
		return (this & 0x000000ff);
	}

	inline public function set_blue(v: Int): Int {
		v = Math.clampI(v, 0, 255);
		this = (this & 0xffffff00) + v;
		return this;
	}

	/**
		This number is always between 0 and 1
	**/
	public var lum(get, set): Float;

	inline public function get_lum(): Float {
		return cast(this, Color).get_hsl()[2];
	}

	inline public function set_lum(v: Float): Float {
		var hsl = cast(this, Color).get_hsl();
		hsl[2] = Math.clampF(v, 0, 1);
		this = Color.fromHSL(hsl[0], hsl[1], hsl[2]);
		return hsl[2];
	}

	/**
		Returns the hue in radians
	**/
	public var hue(get, set): Float;

	inline public function get_hue(): Float {
		return cast(this, Color).get_hsl()[0];
	}

	inline public function set_hue(v: Float): Float {
		var hsl = cast(this, Color).get_hsl();
		hsl[0] = v;
		this = Color.fromHSL(hsl[0], hsl[1], hsl[2]);
		return hsl[0];
	}

	public var sat(get, set): Float;

	inline public function get_sat(): Float {
		return cast(this, Color).get_hsl()[1];
	}

	inline public function set_sat(v: Float): Float {
		var hsl = cast(this, Color).get_hsl();
		hsl[1] = Math.clampF(v, 0, 1);
		this = Color.fromHSL(hsl[0], hsl[1], hsl[2]);
		return hsl[1];
	}

	public var hsl(get, set): Array<Float>;

	inline public function get_hsl(): Array<Float> {
		final c: Color = this;
		final percents = [c.red / 255, c.green / 255, c.blue / 255];
		final max = Math.fMax(percents);
		final min = Math.fMin(percents);

		var hue: Float = 0;
		var sat: Float = 0;
		var lum = 0.5 * (min + max);
		var diff = max - min;

		if (min == max) {
			hue = sat = 0;
		} else {
			var diff = max - min;

			if (max == percents[0]) {
				hue = (percents[1] - percents[2]) / diff + (percents[1] < percents[2] ? 6.0 : 0.0);
			} else if (max == percents[1]) {
				hue = (percents[2] - percents[0]) / diff + 2.0;
			} else {
				hue = (percents[0] - percents[1]) / diff + 4.0;
			}
			hue *= Math.PI / 3.0;
			sat = lum > 0.5 ? diff / (2 - max - min) : diff / (max + min);
		}

		return [hue, sat, lum];
	}

	/**
		Set the color via HSL
	**/
	inline public function set_hsl(hsl: Array<Float>) {
		if (hsl.length < 3) return cast(this, Color).get_hsl();
		this = fromHSL(hsl[0], hsl[1], hsl[2]);
		return cast(this, Color).get_hsl();
	}

	/**
		Modify the HSL of a color and return a new color
	**/
	public function modifyHSL(hsl: Array<Float>): Color {
		var oldHSL = cast(this, Color).hsl;
		oldHSL[0] += hsl[0];
		oldHSL[1] += hsl[1];
		oldHSL[2] += hsl[2];
		var color = Color.fromHSL(oldHSL[0], oldHSL[1], oldHSL[2]);
		color.alpha = cast(this, Color).alpha;
		return color;
	}

	public static function fromHSL(hue: Float, sat: Float, lum: Float): Color {
		/**
			Copied and modified from h3d.Vector
		**/
		hue = hxd.Math.ufmod(hue, Math.PI * 2);

		sat = Math.clampF(sat, 0, 1);
		lum = Math.clampF(lum, 0, 1);
		var c = (1 - Math.abs(2 * lum - 1)) * sat;
		var x = c * (1 - Math.abs((hue * 3 / Math.PI) % 2. - 1));
		var m = lum - c / 2;
		var r, g, b = 0.0;

		if (hue < Math.PI / 3) {
			r = c;
			g = x;
			b = 0;
		} else if (hue < Math.PI * 2 / 3) {
			r = x;
			g = c;
			b = 0;
		} else if (hue < Math.PI) {
			r = 0;
			g = c;
			b = x;
		} else if (hue < Math.PI * 4 / 3) {
			r = 0;
			g = x;
			b = c;
		} else if (hue < Math.PI * 5 / 3) {
			r = x;
			g = 0;
			b = c;
		} else {
			r = c;
			g = 0;
			b = x;
		}
		r += m;
		g += m;
		b += m;
		return 0xff000000 + (Std.int(r * 255) << 16) + (Std.int(g * 255) << 8) + (Std.int(b * 255));
	}

	public function new(i: Int) {
		this = i & 0xffffffff;
	}
}

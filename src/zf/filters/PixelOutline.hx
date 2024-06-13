package zf.filters;

using zf.math.MathExtensions;

/**
	Forked from https://github.com/deepnight/deepnightLibs

	MIT License

	Copyright (c) 2019 Sébastien Bénard

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

	The code is modified to use zf instead of dn
**/
/**
	Add a 1px pixel-perfect outline around h2d.Object
**/
class PixelOutline extends h2d.filter.Shader<InternalShader> {
	/** Outline color (0xRRGGBB) **/
	public var color(default, set): Int;

	public var alpha(default, set): Float;

	/** If TRUE, the original object pixels are discarded, and only the outline remains **/
	public var knockOut(default, set): Bool;

	/** If TRUE, the outline may be drawn outside of the bounds of the object texture, increasing its size. **/
	public var extendBounds = true;

	/** Show left pixels of the outline (default is true) **/
	public var left(default, set): Bool;

	/** Show right pixels of the outline (default is true) **/
	public var right(default, set): Bool;

	/** Show top pixels of the outline (default is true) **/
	public var top(default, set): Bool;

	/** Show bottom pixels of the outline (default is true) **/
	public var bottom(default, set): Bool;

	/** Add a pixel-perfect outline around a h2d.Object using a shader filter **/
	public function new(color = 0x0, a = 1.0, knockOut = false) {
		super(new InternalShader());
		this.color = color;
		alpha = a;
		smooth = false;
		left = true;
		right = true;
		top = true;
		bottom = true;
		this.knockOut = knockOut;
	}

	inline function set_color(v: Int) {
		color = v;
		shader.outlineColor = hxsl.Types.Vec4.fromColor(color);
		shader.outlineColor.a = alpha;
		return v;
	}

	inline function set_alpha(v: Float) {
		alpha = v;
		shader.outlineColor.a = v;
		return v;
	}

	inline function set_knockOut(v) {
		knockOut = v;
		shader.knockOutThreshold = knockOut ? 0 : 1;
		return v;
	}

	inline function set_left(v) {
		left = v;
		shader.leftMul = v ? 1 : 0;
		return v;
	}

	inline function set_right(v) {
		right = v;
		shader.rightMul = v ? 1 : 0;
		return v;
	}

	inline function set_top(v) {
		top = v;
		shader.topMul = v ? 1 : 0;
		return v;
	}

	inline function set_bottom(v) {
		bottom = v;
		shader.bottomMul = v ? 1 : 0;
		return v;
	}

	public function setPartialKnockout(alphaMul: Float) {
		alphaMul = Math.clampF(alphaMul, 0, 1);
		knockOut = alphaMul < 1;
		shader.knockOutThreshold = alphaMul;
	}

	override function sync(ctx: h2d.RenderContext, s: h2d.Object) {
		super.sync(ctx, s);
		boundsExtend = extendBounds ? 1 : 0;
	}

	override function draw(ctx: h2d.RenderContext, t: h2d.Tile) {
		shader.texelSize.set(1 / t.width, 1 / t.height);
		return super.draw(ctx, t);
	}
}

// --- Shader -------------------------------------------------------------------------------
private class InternalShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture: Sampler2D;
		@param var texelSize: Vec2;
		@param var outlineColor: Vec4;
		@param var knockOutThreshold: Float;
		@param var leftMul: Float;
		@param var rightMul: Float;
		@param var topMul: Float;
		@param var bottomMul: Float;
		function fragment() {
			var curColor: Vec4 = texture.get(input.uv);

			var onEdge = ( // Get outline color multiplier based on transparent surrounding pixels
				(1
					- curColor.a) * max(texture.get(vec2(input.uv.x + texelSize.x, input.uv.y))
						.a * leftMul, // left outline
						max(texture.get(vec2(input.uv.x - texelSize.x, input.uv.y)).a * rightMul, // right outline
							max(texture.get(vec2(input.uv.x, input.uv.y + texelSize.y)).a * topMul, // top outline
								texture.get(vec2(input.uv.x, input.uv.y - texelSize.y)).a * bottomMul // bottom outline
							))));

			// Apply color, including outline alpha
			var a = max(onEdge * outlineColor.a, min(knockOutThreshold, curColor.a));
			output.color = vec4(mix(curColor.rgb, outlineColor.rgb, onEdge) * a, a);
		}
	};
}

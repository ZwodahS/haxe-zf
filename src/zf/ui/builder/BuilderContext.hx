package zf.ui.builder;

@:structInit
class BuilderContext {
	public var builder: Builder;
	public var data: DynamicAccess<Dynamic>;

	public function new(data: Dynamic = null) {
		if (data == null) data = {};
		this.data = data;
	}

	public function formatString(str: String): String {
		return builder.formatString(str, this);
	}

	public function formatTemplate(template: haxe.Template): String {
		return template.execute(this.data);
	}

	public function get(key: String): Dynamic {
		if (key == null) return null;
		var value = data.get(key);
		// if we already found the value, we will just return it.
		if (value != null) return value;
		return null;
	}

	public function expandTemplateContext(context: Dynamic): BuilderContext {
		var ctx: BuilderContext = {data: data.copy()};
		ctx.builder = this.builder;
		if (context == null) context = {};
		for (key => value in (context: DynamicAccess<Dynamic>)) {
			ctx.data.set(key, value);
		}
		return ctx;
	}

	inline public function build(data: Dynamic, context: BuilderContext = null): ComponentObject {
		if (context == null) context = this;
		return this.builder.build(data, context);
	}

	public function getBitmap(conf: zf.Access): h2d.Object {
		return this.builder.getBitmap(conf);
	}

	public function getAnim(conf: zf.Access): h2d.Anim {
		return this.builder.getAnim(conf);
	}

	public function getFont(fontName: String): h2d.Font {
		return this.builder.getFont(fontName);
	}

	public function getColor(color: String): Color {
		return this.builder.getColor(color);
	}

	public function getString(id: String, context: Dynamic): String {
		return this.builder.getString(id, context);
	}
}

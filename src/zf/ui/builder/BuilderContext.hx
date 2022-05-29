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

	public function expandTemplateContext(context: Dynamic): BuilderContext {
		var ctx: BuilderContext = {data: data.copy()};
		ctx.builder = this.builder;
		if (context == null) context = {};
		for (key => value in (context: DynamicAccess<Dynamic>)) {
			ctx.data.set(key, value);
		}
		return ctx;
	}

	public function makeObjectFromXMLString(xmlString: String, context: BuilderContext = null): h2d.Object {
		if (context == null) context = this;
		return this.builder.makeObjectFromXMLString(xmlString, context);
	}

	public function makeObjectFromXMLElement(element: Xml, context: BuilderContext = null): h2d.Object {
		if (context == null) context = this;
		return this.builder.makeObjectFromXMLElement(element, context);
	}

	public function makeObjectFromStruct(conf: ComponentConf, context: BuilderContext = null): h2d.Object {
		if (context == null) context = this;
		return this.builder.makeObjectFromStruct(conf, context);
	}

	public function getBitmap(conf: zf.Access): h2d.Object {
		return this.builder.getBitmap(conf);
	}
}

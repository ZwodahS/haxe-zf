package zf.ui.builder.components;

class Anim extends Component {
	public function new() {
		super("anim");
	}

	override public function makeFromXML(element: Xml, context: BuilderContext): h2d.Object {
		return make(zf.Access.xml(element), context);
	}

	override public function makeFromStruct(c: Dynamic, context: BuilderContext) {
		return make(zf.Access.struct(c), context);
	}

	function make(conf: zf.Access, context: BuilderContext): h2d.Object {
		final anim = context.getAnim(conf);

		final speed = conf.getFloat("speed");
		anim.speed = speed;

		return anim;
	}
}

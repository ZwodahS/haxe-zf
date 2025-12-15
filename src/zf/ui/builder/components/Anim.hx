package zf.ui.builder.components;

/**
	Create an Anim
	Wrap Builder.getAnim.
**/
class Anim extends Component {
	public function new() {
		super("anim");
	}

	override function build(element: Xml, context: BuilderContext): ComponentObject {
		final anim = context.getAnim(Access.xml(element));
		return {object: anim};
	}
}

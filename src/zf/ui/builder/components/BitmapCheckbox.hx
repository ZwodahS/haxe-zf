package zf.ui.builder.components;

/**
	Create a bitmap checkbox

	# Attributes
	- bitmapId=String
		index 0 to 4 will be used as [default, hover, toggled, toggledhovered, disabled]
	- onToggle=(Bool -> Void)
**/
class BitmapCheckboxComponent extends Component {
	public function new() {
		super("bitmap-checkbox");
	}

	override public function build(element: Xml, context: BuilderContext): ComponentObject {
		final conf = zf.Access.xml(element);
		final path = conf.getString("bitmapId");
		final objects: Array<h2d.Object> = [];
		final defaultBitmap = context.getBitmap(zf.Access.struct({path: path, index: 0}));
		if (defaultBitmap == null) return null;
		objects.push(defaultBitmap);
		for (i in 1...5) {
			var bm = context.getBitmap(zf.Access.struct({path: path, index: i}));
			if (bm == null) bm = context.getBitmap(zf.Access.struct({path: path, index: 0}));
			objects.push(bm);
		}

		final component = zf.ui.Checkbox.fromObjects({
			objects: objects,
		});

		if (conf.get("onToggle") != null) {
			try {
				final func: Bool->Void = context.data.get(conf.get("onToggle"));
				if (func != null) component.onToggled = func;
			} catch (e) {}
		}

		return {object: component};
	}
}

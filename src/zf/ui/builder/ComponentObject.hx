package zf.ui.builder;

import zf.nav.StaticNavigationNode;

typedef ComponentObject = {
	public var object: h2d.Object;

	public var ?navNode: StaticNavigationNode; // the node for this object
}

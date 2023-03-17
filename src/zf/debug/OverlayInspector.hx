package zf.debug;

class OverlayInspector extends h2d.Object {
	var game: Game;

	public var conf = {
		alpha: 0.5,
		bgColor: 0xff111012,
		width: 0, // set by DebugOverlay
		height: 0, // set by DebugOverlay
	}

	public function new(font: h2d.Font, game: Game) {
		super();
		this.game = game;
	}

	public function init() {
		final bg = new h2d.Bitmap(h2d.Tile.fromColor(this.conf.bgColor));
		bg.width = this.conf.width;
		bg.height = this.conf.height;
		bg.alpha = this.conf.alpha;
		this.addChild(bg);
	}
}

package zf.ren.ext.tbr;

import zf.ren.core.messages.MOnEntityMoved;
import zf.ren.core.components.LocationComponent;

/**
	Provide a generic tile based rendering system.

	**Assumptions**
	(0) A child class will be created to provide more concrete implementation.
	(1) What is rendered is always relative to the player, and only the current level is rendered.

	Mon 12:29:36 18 Nov 2024
	Migrated from ren.
	Visibility code is removed because I don't need it for abyss yet.
	We will bring it back later when I need it.

	When I bring them back, I don't really want the fog rendering to be part of render system.
**/
#if !macro @:build(zf.macros.Messages.build()) #end
class RenderSystem extends zf.engine2.System {
	/** various configuration for handling light level **/
	/**
		The maximum light level. Any value above this will be treated as this value.
	**/
	public var MaxLightLevel: Int = 100;

	public final gridSizeX: Int;
	public final gridSizeY: Int;

	/**
		The main draw layer
	**/
	var drawLayer: h2d.Layers;

	var level: RenderedLevel;

	var entities: Map<Int, {e: Entity, rc: RenderComponent}>;

	public var bgColor: Null<Color> = null;

	/**
		The viewport of the rendersystem. This handles centering of the world.
	**/
	public var viewport(default, set): Rectf = null;

	public function set_viewport(v: Rectf): Rectf {
		this.viewport = v;
		centerOn(this.centeredEntity);
		return this.viewport;
	}

	/**
		If set, the render system will center on the entity whenever any entity is moved.
	**/
	public var followEntity: Entity = null;

	public function set_followEntity(e: Entity): Entity {
		this.followEntity = e;
		centerOn(this.followEntity);
		return this.followEntity;
	}

	/**
		if non-0, the priority that the entity is rendered on is added with y
		i.e. priority = yIndexMultiplier * y + priority

		this will currently be applied to the entitiesDrawLayer.
		for the other layers, only the priority will be used.
	**/
	public var yIndexMultiplier: Int = 0;

	public var layerIds: Map<String, Int>;

	/** End of flags **/
	public function new(drawLayer: h2d.Layers, gridSizeX: Int, gridSizeY: Int, layers: Map<String, Int>) {
		super();
		this.drawLayer = drawLayer;
		this.gridSizeX = gridSizeX;
		this.gridSizeY = gridSizeY;
		this.layerIds = layers;
	}

	override public function init(world: zf.engine2.World) {
		super.init(world);
		setupMessages(world.dispatcher);
	}

	@:handleMessage("MOnEntityMoved", 100)
	function mUpdateEntityOnLevel(m: MOnEntityMoved) {
		// if no level is loaded yet, then we don't even care
		if (this.level == null) return;

		if (m.newLevel == null) { // if we are removing from the level
			// if the previous level is not the rendered level, then we don't care
			if (m.oldLevel == null || m.oldLevel != this.level.level) return;

			final tile = m.oldLevel.tiles.get(m.oldPosition.x, m.oldPosition.y);
			if (tile == null) return;

			tryRemoveEntityFromDrawLayer(m.entity);
			syncTile(tile);
		} else {
			// if the entity is not in the current level then we don't have to care
			final lc = LocationComponent.get(m.entity);
			if (lc == null || lc.level == null || lc.level != this.level.level) return;

			final newPosition = m.newPosition;
			final oldPosition = m.oldPosition;

			if (newPosition != null) {
				// update entity if oldPosition is null, i.e. moving entity into a new level
				// update entity if yindex matters and yindex has changed
				if (oldPosition == null || (this.yIndexMultiplier != 0 && newPosition.y != oldPosition.y)) {
					tryAddEntityToLevel(m.entity);
				}
			}
			// sync both the old and new tiles
			syncTile(oldPosition == null ? null : lc.level.tiles.get(oldPosition.x, oldPosition.y));
			syncTile(newPosition == null ? null : lc.level.tiles.get(newPosition.x, newPosition.y));

			if (this.followEntity != null) centerOn(this.followEntity);
		}
	}

	function hideEntity(e: Entity, ?rc: RenderComponent) {
		if (rc == null) rc = RenderComponent.get(e);
		if (rc != null) rc.ro.visible = false;
	}

	function showEntity(e: Entity, ?rc: RenderComponent) {
		if (rc == null) rc = RenderComponent.get(e);
		if (rc != null) rc.ro.visible = true;
	}

	/**
		update the rendering for a tile.

		@param tile the tile to update. if null, nothing happens
	**/
	function syncTile(tile: Tile) {
		if (tile == null) return;

		for (e in tile.entities) {
			final rc = RenderComponent.get(e);
			if (rc == null || rc.ro == null) continue;
			/**
				Thu 00:20:16 22 Jan 2026
				Not sure why i need to set this to be visible.
				I think I need to be able to set them to be invisible, and forcing them to be visible here
				created some animation bug.
				Let's remove this for now and see what breaks.
			**/
			// rc.ro.visible = true;
			alignEntity(e);
		}
	}

	function tryAddEntityToLevel(e: Entity) {
		if (this.level == null) return;
		final lc = LocationComponent.get(e);
		final rc = RenderComponent.get(e);

		if (this.level.level != lc.level) return;

		if (rc != null && rc.ro != null) {
			final layer = this.level.get(rc.layer);
			if (layer == null) return;

			var priority = rc.priority;
			/**
				Mon 13:23:06 18 Nov 2024
				Previously only entities have yIndexMultiplier
				I think we can do it for everything
			**/
			priority += this.yIndexMultiplier * lc.y;
			layer.add(rc.ro, priority);
			showEntity(e, rc);
		}

		alignEntity(e, rc, lc);
	}

	inline public function renderPriority(rc: RenderComponent, tileY: Int) {
		return priority(rc.priority, tileY);
	}

	inline public function priority(p: Int, tileY: Int) {
		return p + this.yIndexMultiplier * tileY;
	}

	override public function onEntityRemoved(e: Entity) {
		tryRemoveEntityFromDrawLayer(e);
	}

	function tryRemoveEntityFromDrawLayer(e: Entity) {
		var rc = RenderComponent.get(e);
		if (rc.ro != null) rc.ro.remove();
	}

	inline public function alignEntity(entity: Entity, rc: RenderComponent = null, lc: LocationComponent = null) {
		if (lc == null) lc = LocationComponent.get(entity);
		if (rc == null) rc = RenderComponent.get(entity);

		alignRenderObjectToGrid(rc.ro, lc.x, lc.y);
	}

	public inline function alignRenderObjectToGrid(obj: h2d.Object, positionX: Int, positionY: Int, offsetX: Int = 0,
			offsetY: Int = 0) {
		if (obj == null) return;

		obj.x = positionX * this.gridSizeX + offsetX;
		obj.y = positionY * this.gridSizeY + offsetY;
	}

	inline public function gridXToPosX(x: Int, center: Bool = false): Float {
		return x * this.gridSizeX + (center == true ? this.gridSizeX / 2 : 0);
	}

	inline public function gridYToPosY(y: Int, center: Bool = false): Float {
		return y * this.gridSizeY + (center == true ? this.gridSizeY / 2 : 0);
	}

	public function loadLevel(level: Level) {
		// already loaded, don't load again
		if (this.level?.level == level) return;

		// unload current level
		unloadLevel();

		// if new level is null, don't do anything
		if (level == null) return;

		// create the new level
		this.level = new RenderedLevel(level);
		this.drawLayer.addChild(this.level.mainLayers);

		for (l => ind in this.layerIds) {
			this.level.add(l, new h2d.Layers(), ind);
		}

		// add all the entities
		for (xy => tile in level.tiles.iterateYX()) {
			if (tile == null) continue;
			for (e in tile.entities) {
				tryAddEntityToLevel(e);
			}
			syncTile(tile);
		}

		if (this.bgColor != null) {
			final width = level.tiles.size.x * this.gridSizeX;
			final height = level.tiles.size.y * this.gridSizeY;

			final bgBm = new h2d.Bitmap(h2d.Tile.fromColor(this.bgColor, width, height));
			if (this.level.exists("bg") == false) this.level.add("bg", new h2d.Layers(), 0);

			final bgLayer = this.level.get("bg");
			bgLayer.addChild(bgBm);
		}
	}

	public function unloadLevel() {
		if (this.level == null) return;
		this.level.remove();
		this.level = null;
	}

	public function animateBump(entity: Entity, tile: Tile, ?onFinish: Void->Void, animateDuration: Float = .15,
			blocking: Bool = true) {
		final targetPositionX = gridXToPosX(tile.x);
		final targetPositionY = gridYToPosY(tile.y);

		final rc = RenderComponent.get(entity);

		// HACK: if we are moving down, we need to update the layer that it is rendered at before the move finishes
		final priority = renderPriority(rc, tile.y);
		if (targetPositionY > rc.ro.y) {
			this.level.get(rc.layer).add(rc.ro, priority);
		}

		final updater = blocking ? this.__world__.updater : null;

		E.moveTo(targetPositionX, targetPositionY, animateDuration).applyTo(rc.ro, updater, () -> {
			final lc = LocationComponent.get(entity);
			alignRenderObjectToGrid(rc.ro, lc.x, lc.y);
			final priority = renderPriority(rc, lc.y);
			this.level.get(rc.layer).add(rc.ro, priority);
			if (onFinish != null) onFinish();
		});
	}

	public function animateMove(entity: Entity, tile: Tile, ?onFinish: Void->Void, duration: Float = 0.15,
			blocking: Bool = true) {
		final targetPositionX = gridXToPosX(tile.x);
		final targetPositionY = gridYToPosY(tile.y);

		final rc = RenderComponent.get(entity);

		// HACK: if we are moving down, we need to update the layer that it is rendered at before the move finishes
		final priority = renderPriority(rc, tile.y);
		if (targetPositionY > rc.ro.y) {
			this.level.get(rc.layer).add(rc.ro, priority);
		}

		final animator = blocking ? this.__world__.updater : null;
		E.moveTo(targetPositionX, targetPositionY, duration).applyTo(rc.ro, animator, () -> {
			/**
				Tue 13:59:24 25 Nov 2025
				This is bugged if 2 ice is on the same tiles.
				Adding a check to be safe.
			**/
			if (rc.ro != null) this.level.get(rc.layer).add(rc.ro, priority);
			if (onFinish != null) onFinish();
		});
	}

	public function animateProjectile(projectile: h2d.Object, sourceX: Int, sourceY: Int, destinationX: Int,
			destinationY: Int, ?onFinish: Void->Void, animationDuration: Float = 1.0, drawLayer: Int = 15,
			blocking: Bool = true, offsetX: Float = 0, offsetY: Float = 0) {
		projectile.x = gridXToPosX(sourceX, true) + offsetX;
		projectile.y = gridYToPosY(sourceY, true) + offsetY;
		this.level.get("entity").add(projectile, drawLayer);

		final endX = gridXToPosX(destinationX, true) + offsetX;
		final endY = gridYToPosY(destinationY, true) + offsetY;
		final animator = blocking ? this.__world__.updater : null;

		E.moveTo(endX, endY, animationDuration).applyTo(projectile, animator, () -> {
			projectile.remove();
			if (onFinish != null) onFinish();
		});
	}

	public function animateParabolic(object: h2d.Object, sourceX: Int, sourceY: Int, destinationX: Int,
			destinationY: Int, ?onFinish: Void->Void, animationDuration: Float = 1.0, drawLayer: Int = 15,
			blocking: Bool = true, offsetX: Float = 0, offsetY: Float = 0) {
		final startX = gridXToPosX(sourceX, true) + offsetX;
		final startY = gridYToPosY(sourceY, true) + offsetY;
		this.level.get("entity").add(object, drawLayer);

		object.x = startX;
		object.y = startY;

		final endX = gridXToPosX(destinationX, true) + offsetX;
		final endY = gridYToPosY(destinationY, true) + offsetY;
		final animator = blocking ? this.__world__.updater : null;

		final moveX = endX - startX;
		final moveY = endY - startY;

		function parabolicFunc(dt: Float, pt: Point2f): Point2f {
			pt.x = (dt / animationDuration) * moveX;
			pt.y = (1.5 * -this.gridSizeY * Math.sin(dt / animationDuration * Math.PI))
				+ (dt / animationDuration) * moveY;
			return pt;
		}

		E.batch([
			E.scaleTo(animationDuration / 2, 1.2, 1.2),
			E.scaleTo(animationDuration / 2, 1, 1)
		]).with(E.moveByFunc(parabolicFunc, animationDuration)).applyTo(object, animator, () -> {
			object.remove();
			if (onFinish != null) onFinish();
		});
	}

	public function animateFalling(object: h2d.Object, tileX: Int, tileY: Int, ?onFinish: Void->Void,
			duration: Float = 1.0, drawLayer: Int = 15, blocking: Bool = true, offsetX: Float = 0, offsetY: Float = 0) {
		final startX = gridXToPosX(tileX, true) + offsetX;
		final startY = gridYToPosY(tileY, true) + offsetY - 40;
		this.level.get("entity").add(object, drawLayer);

		object.x = startX;
		object.y = startY;
		object.alpha = 0;

		final endX = gridXToPosX(tileX, true) + offsetX;
		final endY = gridYToPosY(tileY, true) + offsetY;

		final animator = blocking ? this.__world__.updater : null;

		final moveX = endX - startX;
		final moveY = endY - startY;

		E.moveTo(endX, endY, duration).with(E.alphaTo(1, duration / 2)).applyTo(object, animator, () -> {
			object.remove();
			if (onFinish != null) onFinish();
		});
	}

	var centeredEntity: Entity = null;
	public function centerOn(e: Entity) {
		this.centeredEntity = e;
		if (this.centeredEntity == null) return;
		if (this.viewport == null) return;

		final lc = LocationComponent.get(e);
		if (lc == null || lc.level == null) return;
		var x = this.drawLayer.x;
		var y = this.drawLayer.y;

		final centerX = this.viewport.xMin + (this.viewport.width / 2);
		final centerY = this.viewport.yMin + (this.viewport.height / 2);

		x = centerX - (lc.x * this.gridSizeX * this.drawLayer.scaleX) - (this.gridSizeX / 2 * this.drawLayer.scaleX);
		y = centerY - (lc.y * this.gridSizeY * this.drawLayer.scaleY) - (this.gridSizeY / 2 * this.drawLayer.scaleY);

		this.drawLayer.x = x;
		this.drawLayer.y = y;
	}

	inline public function recenter() {
		if (this.centeredEntity == null) return;
		this.centerOn(this.centeredEntity);
	}
}

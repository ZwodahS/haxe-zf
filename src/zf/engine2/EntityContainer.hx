package zf.engine2;

/**
	@stage:stable

	See Engine2.collectEntities
**/
interface EntityContainer {
	public function collectEntities(entities: Entities<Entity>): Void;
}

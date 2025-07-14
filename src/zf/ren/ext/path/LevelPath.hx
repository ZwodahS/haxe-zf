package zf.ren.ext.path;

import astar.map2d.Map2D;
import astar.map2d.Direction in ASDirection;
import astar.map2d.types.MovementDirection;

import zf.ren.core.Level;

typedef CostFunc = (Tile->Int);

/**
	Provide a simple way to use astar to path find on a 2D level

**/
class LevelPath {
	/** Path finding related data **/
	/**
		Sun May 23 14:59:36 2021
		The previous implementation of dynamic cost function for individiual entity is very slow.
		Considering that the cost of each tile don't change often, and even when they do change,
		only a few will change at any one time, it is better to generate a fixed cost array and
		update the array if there are changes. However, there is a need to handle different mode
		of movement, e.g. Flying vs Walking

		Because of this, a single cost array is not sufficient, hence we will be handling this
		by having multiple cost functions and caches.

		This is broken down into a few parts
		1.	graphTileCostsFunction stores an id -> CostFunc.
		2.	graphDefaultCostFunc stores the id of the cost func to use if one is not provided or
				the one provided is not valid.
		3.	graphArray stores the cached values for the costs of all the tiles calculated using
				the various cost functions.
		The graphcost however, will be the same.
	**/
	// graph for path finding on this level
	public var graph: Map2D;

	public var graphTileCostsFunction: Map<String, CostFunc>;
	public var graphDefaultCostFunc: String = "default";
	public var graphArray: Map<String, Array<Int>>;
	// this need to be set to 8 way cost
	public var graphCosts = [
		0 => [N => 1., S => 1., W => 1., E => 1., NE => 1.3, NW => 1.3, SE => 1.3, SW => 1.3],
	];
	// set the movement direction, default to FourWay
	public var movementDirection: MovementDirection = FourWay;

	public var level: Level;

	public function new(level: Level, movementDirection: MovementDirection = FourWay) {
		this.level = level;
		this.movementDirection = movementDirection;
		this.graphTileCostsFunction = [];
	}

	public function setupGraphs() {
		if (this.graphTileCostsFunction.isEmpty()) return;

		Assert.assert(this.graphTileCostsFunction[graphDefaultCostFunc] != null);

		final size = this.level.tiles.size;
		this.graph = new Map2D(size.x, size.y, this.movementDirection);
		this.graphArray = new Map<String, Array<Int>>();

		for (id => func in this.graphTileCostsFunction) {
			this.graphArray[id] = [for (i in 0...(size.x * size.y)) 0];
		}

		this.graph.setMap(this.graphArray[graphDefaultCostFunc]);
		this.graph.setCosts(graphCosts);
	}

	/** Path finding related code **/
	/**
		Convert a position to the a index in graphArray

		@param position the position to convert
		@return return the graphArray index
	**/
	inline function apos(x: Int, y: Int): Int {
		return y * this.level.tiles.size.x + x;
	}

	/**
		Find a path from start to end

		@param start the start position to search path from
		@param end the end position to search path to
		@return Array of points to end, null if path not found
	**/
	public function pathTo(startX: Int, startY: Int, endX: Int, endY: Int, graphId: String): zf.Point2i.ArrPoint2i {
		final p1 = apos(startX, startY);
		final p2 = apos(endX, endY);

		final ga = getGraphArray(graphId);

		// cache the value of start and end and set it to 0
		final o1 = ga[p1];
		final o2 = ga[p2];
		ga[p1] = 0;
		ga[p2] = 0;

		// resync the graph
		resyncWorld(ga);

		// get the path
		final result = this.graph.solve(startX, startY, endX, endY);
		var path: Array<Point2i> = null;
		if (result.result == Solved) {
			path = [for (p in result.path) [p.x, p.y]];
		}

		// set back the ga values
		ga[p1] = o1;
		ga[p2] = o2;

		return path;
	}

	/**
		draw a from start to line
		this uses getCost to decide if it is passable

		@param start the start position. start position's cost is never checked
		@param end the end position. end position's cost is never checked
		@param costFunc the cost function for the line check. Cost Func should return 1 when blocked, 0 when not
		@return 2 x LinePoint2i, one for each direction.
			The first will be forward direction, the second will be from end to start.
			If there is no line, the value will be null.
			This will always return an array with size 2
	**/
	public function lineTo(startX: Int, startY: Int, endX: Int, endY: Int, costFunc: CostFunc,
			diagonalBlock: BlockType = NoBlock): Array<LinePoint2i> {
		final lines = Line2i.getLinesBothDirection(startX, startY, endX, endY);
		final result = [null, null];
		if (checkIfLinePassable(lines[0], costFunc, diagonalBlock) == true) {
			result[0] = lines[0];
		} else {
			for (pt in lines[0]) pt.dispose();
		}
		if (checkIfLinePassable(lines[1], costFunc, diagonalBlock) == true) {
			result[1] = lines[1];
		} else {
			for (pt in lines[1]) pt.dispose();
		}
		return result;
	}

	function checkIfLinePassable(line: LinePoint2i, costFunc: CostFunc, diagonalBlock: BlockType): Bool {
		// if line length is 2, then we just return true
		// this is because the entity is beside each other
		if (line.length == 2) return true;

		var prev = null;
		var last = line.last();

		for (p in line) {
			if (prev == null) {
				// first one, we don't care
			} else {
				/**
					Mon 14:57:25 18 Nov 2024
					Porting from old code but for some reason we don't check the costFunc for the last tile
					Pretty sure there was a reason for it
				**/
				if (p != last && costFunc(this.level.tiles.get(p.x, p.y)) == 1) return false;
				if (diagonalBlock != NoBlock && isDiagonalBlock(prev.x, prev.y, p.x, p.y, costFunc,
					diagonalBlock)) return false;
			}
			prev = p;
		}

		return true;
	}

	function isDiagonalBlock(pt1x: Int, pt1y: Int, pt2x: Int, pt2y: Int, costFunc: CostFunc,
			diagonalBlock: BlockType): Bool {
		final prev: Point2i = [pt1x, pt1y];
		final next: Point2i = [pt2x, pt2y];
		var d: Direction = next - prev;
		final split = d.split();
		var blocked = false;
		// if split is 2, means that there are 2 direction in this 1 spot, i.e. diagonal
		if (split.length == 2) {
			var blockCount = 0;
			for (s in split) {
				final adjP = prev + s;
				if (costFunc(this.level.tiles.get(adjP.x, adjP.y)) == 1) blockCount += 1;
				adjP.dispose();
			}
			if (blockCount == 2 || (blockCount == 1 && diagonalBlock == FullyBlocked)) {
				blocked = true;
			}
		}
		prev.dispose();
		next.dispose();
		return blocked;
	}

	inline function resyncWorld(g: Array<Int>) {
		this.graph.setMap(g);
		this.graph.setCosts(graphCosts);
	}

	function getGraphArray(graphId: String, useDefault: Bool = true) {
		var ga = this.graphArray[graphId];
		if (ga == null && useDefault) ga = this.graphArray[graphDefaultCostFunc];
		Assert.assert(ga != null || useDefault == false);
		return ga;
	}

	/**
		Force a recalculation of all graphs cost on the level
		This should be done once when all the entities are loaded, and just before it is added to the world.
	**/
	public function recalculateAllGraphs() {
		for (id in this.graphTileCostsFunction.keys()) {
			recalculateGraph(id);
		}
	}

	public function recalculateGraph(id: String) {
		final ga = getGraphArray(id, false);
		if (ga == null) return;
		final costFunc = this.graphTileCostsFunction[id];

		Assert.assert(costFunc != null);

		var p = 0;
		for (y in 0...this.level.tiles.size.y) {
			for (x in 0...this.level.tiles.size.x) {
				ga[p++] = costFunc(this.level.tiles.get(x, y));
			}
		}
	}

	public function recalculatePosition(x: Int, y: Int) {
		final p = apos(x, y);

		var tile = this.level.tiles.get(x, y);
		if (tile == null) return;

		for (id => costFunc in this.graphTileCostsFunction) {
			var ga = getGraphArray(id, false);
			Assert.assert(ga != null);

			ga[p] = costFunc(tile);
		}
	}
}

/**
	Tue 16:08:43 26 Nov 2024
	Previously this is done in ren.core.Level.
	However, there are times that requires a different approach, especially when there are a lot of
	dynamic entities.

	Because the implementation might be different, moving it out of Level is a good idea.
**/

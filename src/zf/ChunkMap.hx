package zf;

/**
	ChunkMap is a 2D array that allow for infinite coordinates system
**/
typedef TranslatedCoord = {
	var chunkId: String;
	var x: Int;
	var y: Int;
}

class ChunkMap<T> {
	public var chunkSize(default, null): Int;

	var chunks: Map<String, Vector2D<T>>;
	var nullValue: T;

	public function new(chunkSize: Int, nullValue: T) {
		this.chunks = new Map<String, Vector2D<T>>();
		this.chunkSize = chunkSize;
		this.nullValue = nullValue;
	}

	public function set(x: Int, y: Int, value: T): T {
		var translateCoord = this.translateCoord(x, y);
		var chunk = this.chunks.get(translateCoord.chunkId);
		if (chunk == null) {
			chunk = this.createChunk();
			this.chunks[translateCoord.chunkId] = chunk;
		}
		var existing = chunk.get(translateCoord.x, translateCoord.y);
		chunk.set(translateCoord.x, translateCoord.y, value);
		return existing;
	}

	// TODO: setChunk function to set the entire chunk

	public function get(x: Int, y: Int): T {
		var translateCoord = this.translateCoord(x, y);
		var chunk = this.chunks.get(translateCoord.chunkId);
		if (chunk == null) {
			return null;
		}
		return chunk.get(translateCoord.x, translateCoord.y);
	}

	function createChunk(): Vector2D<T> {
		return new Vector2D<T>([this.chunkSize, this.chunkSize], this.nullValue);
	}

	function translateCoord(x: Int, y: Int): TranslatedCoord {
		var xChunk: Int = Math.floor(x / this.chunkSize);
		var xCoord: Int = x % this.chunkSize;
		if (xCoord < 0) xCoord += this.chunkSize;

		var yChunk: Int = Math.floor(y / this.chunkSize);
		var yCoord: Int = y % this.chunkSize;
		if (yCoord < 0) yCoord += this.chunkSize;

		return {chunkId: '$xChunk.$yChunk', x: xCoord, y: yCoord};
	}
}

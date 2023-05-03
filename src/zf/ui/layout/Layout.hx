package zf.ui.layout;

class Layout {
	/**
		Compute the positions of items. Usually we use Flow, but this may be needed sometimes

		@param total total size of the layout
		@param itemSize the size of each item in the layout
		@param spacing spacing between each item
		@param numItems the number of items
	**/
	public static function computePositions(total: Float, itemSize: Float, spacing: Float,
			numItems: Int): Array<Float> {
		// calculate how much size we need
		final need = (itemSize * numItems) + (spacing * (numItems - 1));
		final start = (total - need) / 2;
		final positions: Array<Float> = [];
		for (i in 0...numItems) {
			positions.push(start + (i * (itemSize + spacing)));
		}
		return positions;
	}
}

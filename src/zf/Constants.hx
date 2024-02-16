package zf;

/**
	@stage:stable
**/
class Constants {
	public static final MaxInt32: Int = 0x7FFFFFFE;
	public static final SeedMax: Int = MaxInt32 - 1;

	/**
		Tue 12:59:41 30 Jan 2024
		Not sure where to put this
	**/
	public static function gridRangeDynamic(): Dynamic {
		return {
			Adjacent: zf.ds.GridRange.Adjacent,
			Around: zf.ds.GridRange.Around,
			Row: zf.ds.GridRange.Row,
			Column: zf.ds.GridRange.Column,
			RowColumn: zf.ds.GridRange.RowColumn,
			All: zf.ds.GridRange.All,
		}
	}
}

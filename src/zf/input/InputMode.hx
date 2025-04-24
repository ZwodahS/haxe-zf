package zf.input;

enum abstract InputMode(String) from String to String {
	public final KBM: String = "KBM";
	public final Controller: String = "Controller";
	// TODO: Add KBO (KB only) and MO (Mouse only)
}

package zf.input;

class PadExtensions {
	public static function getPadType(pad: hxd.Pad): PadType {
		final name = pad.name;
		if (name.indexOf("Xbox") != -1) return Xbox;
		if (name.indexOf("XInput") != -1) return XInput;
		if (name.indexOf("PS") != -1) return PS;
		if (name.indexOf("Steam Virtual") != -1) return SteamDeck;
		return Unknown;
	}
}

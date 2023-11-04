package zf;

/**
	@stage:stable
**/
class StringExtensions {
	public static function multiply(string: String, count: Int, joinString: String = "") {
		return [for (_ in 0...count) string].join(joinString);
	}

	public static function removeXmlTag(string: String): String {
		final node = Xml.parse(string);

		function parseString(x: Xml) {
			switch (x.nodeType) {
				case Xml.PCData:
					return x.nodeValue;
				case Xml.Element, Xml.Document:
					var strbuf = new StringBuf();
					for (e in x) {
						final s = parseString(e);
						if (s != null) strbuf.add(s);
					}
					return strbuf.toString();
				default:
					return null;
			}
		}
		return parseString(node);
	}
}

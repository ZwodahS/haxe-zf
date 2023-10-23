package zf.xml;

using StringTools;

using zf.StringExtensions;

import zf.Logger;

typedef PrinterConf = {
	public var ?pretty: Bool;
	public var ?singleLinePCData: Bool;
	public var ?useSpaceAsTab: Int;
	public var ?alignPCData: Bool;
}

/**
	Ported from haxe.xml with additional formatting options
**/
class Printer {
	/**
		Convert `Xml` to string representation.

		Set `pretty` to `true` to prettify the result.
	**/
	static public function print(xml: Xml, ?conf: PrinterConf) {
		if (conf == null) conf = {};
		var printer = new Printer(conf);
		printer.writeNode(xml, "");
		return printer.output.toString();
	}

	var output: StringBuf;
	var conf: PrinterConf;

	var tabChar: String = "\t";

	function new(conf: PrinterConf) {
		output = new StringBuf();
		this.conf = conf;
		if (this.conf.useSpaceAsTab != null) {
			this.tabChar = [for (_ in 0...this.conf.useSpaceAsTab) " "].join("");
		}
	}

	function writeNode(value: Xml, tabs: String) {
		switch (value.nodeType) {
			case CData:
				write(tabs + "<![CDATA[");
				write(value.nodeValue);
				write("]]>");
				newline();
			case Comment:
				var commentContent: String = value.nodeValue;
				commentContent = ~/[\n\r\t]+/g.replace(commentContent, "");
				commentContent = "<!--" + commentContent + "-->";
				write(tabs);
				write(StringTools.trim(commentContent));
				newline();
			case Document:
				for (child in value) {
					writeNode(child, tabs);
				}
			case Element:
				write(tabs + "<");
				write(value.nodeName);
				for (attribute in value.attributes()) {
					write(" " + attribute + "=\"");
					write(StringTools.htmlEscape(value.get(attribute), true));
					write("\"");
				}
				if (hasChildren(value)) {
					write(">");
					final nl = shouldNewLine(value);
					if (nl == true) newline();
					for (child in value) {
						writeNode(child, conf.pretty == true ? tabs + '${this.tabChar}' : tabs);
					}
					write((nl == true ? tabs : "") + "</");
					write(value.nodeName);
					write(">");
					newline();
				} else {
					write("/>");
					newline();
				}
			case PCData:
				var nodeValue: String = value.nodeValue;
				if (nodeValue.length != 0) {
					var nl = nodeValue.indexOf("\n") != -1;
					if (nl == true) {
						if (this.conf.alignPCData == true) {
							for (s in nodeValue.split("\n")) {
								if (s != "") write(tabs + StringTools.htmlEscape(s));
								newline();
							}
						} else {
							write((nl ? tabs : "") + StringTools.htmlEscape(nodeValue));
							newline();
						}
					} else {
						if (this.conf.singleLinePCData == true) {
							write(StringTools.htmlEscape(nodeValue));
						} else {
							write(tabs + StringTools.htmlEscape(nodeValue));
							newline();
						}
					}
				}
			case ProcessingInstruction:
				write("<?" + value.nodeValue + "?>");
				newline();
			case DocType:
				write("<!DOCTYPE " + value.nodeValue + ">");
				newline();
		}
	}

	inline function write(input: String) {
		output.add(input);
	}

	inline function newline() {
		if (this.conf.pretty == true) {
			output.add("\n");
		}
	}

	function hasChildren(value: Xml): Bool {
		for (child in value) {
			switch (child.nodeType) {
				case Element, PCData:
					return true;
				case CData, Comment:
					if (StringTools.ltrim(child.nodeValue).length != 0) {
						return true;
					}
				case _:
			}
		}
		return false;
	}

	function shouldNewLine(value: Xml): Bool {
		if (value.firstChild().nodeType == Xml.PCData) {
			if (this.conf.singleLinePCData != true) return true;
			if (value.firstChild().nodeValue.indexOf("\n") != -1) return true;
			return false;
		}
		return true;
	}
}

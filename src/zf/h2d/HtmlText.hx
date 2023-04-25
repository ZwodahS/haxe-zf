package zf.h2d;

import h2d.RenderContext;
import h2d.Text.Align;

/**
	@stage:stable
	See end of file for logs
**/
/**
	The line height calculation rules.
**/
enum LineHeightMode {
	/**
		Accurate line height calculations. Each line will adjust it's height accordih2ng to it's contents.
	**/
	Accurate;

	/**
		Only text adjusts line heights, and `<img>` tags do not affect it (partial legacy behavior).
	**/
	TextOnly;

	/**
		Legacy line height mode. When used, line heights remain constant based on `Text.font` variable.
	**/
	Constant;
}

/**
	img tag vertical alignment rules.
**/
enum ImageVerticalAlign {
	/**
		Align images along the top of the text line.
	**/
	Top;

	/**
		Align images to sit on the base line of the text.
	**/
	Bottom;

	/**
		Align images to the middle between the top of the text line its base line.
	**/
	Middle;
}

private typedef LineInfo = {
	var width: Float;
	var height: Float;
	var baseLine: Float;
}

private typedef SplitNode = {
	var node: Xml;
	var prevChar: Int;
	var pos: Int;
	var width: Float;
	var height: Float;
	var baseLine: Float;
	var font: h2d.Font;
}

/**
	A Text object
**/
class HtmlText extends h2d.Text {
	/**
		The function use to load <img> tag
	**/
	public static dynamic function defaultLoadImage(url: String): h2d.Tile {
		return null;
	}

	/**
		The function use to load face attribute in <font> tags.
	**/
	public static dynamic function defaultLoadFont(name: String): h2d.Font {
		return null;
	}

	/**
		The default method to format text.
	**/
	public static dynamic function defaultFormatText(text: String): String {
		return text;
	}

	/**
		Instead of color #fff for font, use colorId this will be used
	**/
	public static dynamic function defaultGetColor(c: String): Int {
		return 0xffffffff;
	}

	/**
		When enabled, condenses extra spaces (carriage-return, line-feed, tabulation and space character) to one space.
		If not set, uncondensed whitespace is left as is, as well as line-breaks.
	**/
	public var condenseWhite(default, set): Bool = true;

	/**
		The spacing after `<img>` tags in pixels.
	**/
	public var imageSpacing(default, set): Float = 1;

	/**
		Line height calculation mode controls how much space lines take up vertically.
		Changing mode to `Constant` restores the legacy behavior of HtmlText.
	**/
	public var lineHeightMode(default, set): LineHeightMode = Accurate;

	/**
		Vertical alignment of the images in `<img>` tag relative to the text.
	**/
	public var imageVerticalAlign(default, set): ImageVerticalAlign = Bottom;

	var elements: Array<h2d.Object> = [];
	var xPos: Float;
	var yPos: Float;
	var xMax: Float;
	var xMin: Float;
	var textXml: Xml;
	var sizePos: Int;
	var dropMatrix: h3d.shader.ColorMatrix;
	var prevChar: Int;
	var newLine: Bool;

	/**
		Override the default set_text from h2d.Text
	**/
	override function set_text(t: String) {
		super.set_text(formatText(t));
		return t;
	}

	override function draw(ctx: RenderContext) {
		if (dropShadow != null) {
			var oldX = absX, oldY = absY;
			absX += dropShadow.dx * matA + dropShadow.dy * matC;
			absY += dropShadow.dx * matB + dropShadow.dy * matD;

			if (dropMatrix == null) dropMatrix = new h3d.shader.ColorMatrix();

			addShader(dropMatrix);
			var m = dropMatrix.matrix;
			m.zero();
			m._41 = ((dropShadow.color >> 16) & 0xFF) / 255;
			m._42 = ((dropShadow.color >> 8) & 0xFF) / 255;
			m._43 = (dropShadow.color & 0xFF) / 255;
			m._44 = dropShadow.alpha;

			@:privateAccess glyphs.drawWith(ctx, this);
			removeShader(dropMatrix);
			absX = oldX;
			absY = oldY;
		} else {
			dropMatrix = null;
		}
		@:privateAccess glyphs.drawWith(ctx, this);
	}

	/**
		Method that should return an `h2d.Tile` instance for `<img>` tags.
		By default calls `Text.defaultLoadImage` method.

		Text does not cache tile instances.
		Due to internal structure, method should be deterministic and always return same Tile on consequent calls with same `url` input.
		@param url A value contained in `src` attribute.
	**/
	public dynamic function loadImage(url: String): h2d.Tile {
		return defaultLoadImage(url);
	}

	/**
		Method that should return an `h2d.Font` instance for `<font>` tags with `face` attribute.
		By default calls `Text.defaultLoadFont` method.

		Text does not cache font instances and it's recommended to perform said caching from outside.
		Due to internal structure, method should be deterministic and always return same Font instance on consequent calls with same `name` input.
		@param name A value contained in `face` attribute.
		@returns Method should return loaded font instance or `null`. If `null` is returned - currently active font is used.
	**/
	public dynamic function loadFont(name: String): h2d.Font {
		var f = defaultLoadFont(name);
		if (f == null) return this.font;
		return f;
	}

	public dynamic function getColor(cId: String): Int {
		return defaultGetColor(cId);
	}

	/**
		Called when text is assigned, allowing to process arbitrary text to a valid XHTML.
	**/
	public dynamic function formatText(text: String): String {
		return defaultFormatText(text);
	}

	function parseText(text: String) {
		return try Xml.parse(text) catch (e: Dynamic) throw "Could not parse " + text + " (" + e + ")";
	}

	inline function makeLineInfo(width: Float, height: Float, baseLine: Float): LineInfo {
		return {width: width, height: height, baseLine: baseLine};
	}

	/**
		Override the validateText of h2d.Text
	**/
	override function validateText() {
		this.textXml = parseText(text);
		validateNodes(this.textXml);
	}

	function validateNodes(xml: Xml) {
		switch (xml.nodeType) {
			case Element:
				var nodeName = xml.nodeName.toLowerCase();
				switch (nodeName) {
					case "img":
						loadImage(xml.get("src"));
					case "font":
						if (xml.exists("face")) {
							loadFont(xml.get("face"));
						}
					case "b", "bold":
						loadFont("bold");
					case "i", "italic":
						loadFont("italic");
				}
				for (child in xml) validateNodes(child);
			case Document:
				for (child in xml) validateNodes(child);
			default:
		}
	}

	override function initGlyphs(text: String, rebuild = true) {
		if (rebuild == true) {
			glyphs.clear();
			for (e in elements) e.remove();
			// note that we don't remove the interactives from the map.
			elements = [];
		}
		glyphs.setDefaultColor(textColor);

		var doc: Xml;
		if (this.textXml == null) {
			doc = parseText(text);
		} else {
			doc = this.textXml;
		}

		this.yPos = 0;
		this.xMax = 0;
		this.xMin = Math.POSITIVE_INFINITY;
		this.sizePos = 0;
		this.calcYMin = 0;

		var metrics: Array<LineInfo> = [makeLineInfo(0, font.lineHeight, font.baseLine)];
		this.prevChar = -1;
		this.newLine = true;
		var splitNode: SplitNode = {
			node: null,
			pos: 0,
			font: font,
			prevChar: -1,
			width: 0,
			height: 0,
			baseLine: 0
		};
		for (e in doc) buildSizes(e, font, metrics, splitNode);

		var max = 0.;
		for (info in metrics) {
			if (info.width > max) max = info.width;
		}
		this.calcWidth = max;

		this.prevChar = -1;
		this.newLine = true;
		nextLine(textAlign, metrics[0].width);
		for (e in doc) addNode(e, font, textAlign, rebuild, metrics);

		if (xPos > xMax) this.xMax = xPos;

		this.textXml = null;

		var y = yPos;
		this.calcXMin = xMin;
		this.calcWidth = xMax - xMin;
		this.calcHeight = y + metrics[sizePos].height;
		this.calcSizeHeight = y + metrics[sizePos].baseLine; // (font.baseLine > 0 ? font.baseLine : font.lineHeight);
		this.calcDone = true;
		if (rebuild == true) this.needsRebuild = false;
	}

	function buildSizes(e: Xml, font: h2d.Font, metrics: Array<LineInfo>, splitNode: SplitNode) {
		function wordSplit() {
			var fnt = splitNode.font;
			var str = splitNode.node.nodeValue;
			var info = metrics[metrics.length - 1];
			var w = info.width;
			var cc = str.charCodeAt(splitNode.pos);
			// Restore line metrics to ones before split.
			// Potential bug: `Text<split> [Image] text<split>text` - third line will use metrics as if image is present in the line.
			info.width = splitNode.width;
			info.height = splitNode.height;
			info.baseLine = splitNode.baseLine;
			var char = fnt.getChar(cc);
			if (lineBreak && fnt.charset.isSpace(cc)) {
				// Space characters are converted to \n
				w -= (splitNode.width + letterSpacing + char.width + char.getKerningOffset(splitNode.prevChar));
				splitNode.node.nodeValue = str.substr(0, splitNode.pos) + "\n" + str.substr(splitNode.pos + 1);
			} else {
				w -= (splitNode.width + letterSpacing + char.getKerningOffset(splitNode.prevChar));
				splitNode.node.nodeValue = str.substr(0, splitNode.pos + 1) + "\n" + str.substr(splitNode.pos + 1);
			}
			splitNode.node = null;
			return w;
		}
		inline function lineFont() {
			return lineHeightMode == Constant ? this.font : font;
		}
		if (e.nodeType == Xml.Element) {
			inline function makeLineBreak() {
				var fontInfo = lineFont();
				metrics.push(makeLineInfo(0, fontInfo.lineHeight, fontInfo.baseLine));
				splitNode.node = null;
				newLine = true;
				prevChar = -1;
			}

			var nodeName = e.nodeName.toLowerCase();
			switch (nodeName) {
				case "p":
					if (!newLine) {
						makeLineBreak();
					}
				case "br":
					makeLineBreak();
				case "img":
					// TODO: Support width/height attributes
					// Support max-width/max-height attributes (downscale)
					// Support min-width/min-height attributes (upscale)
					var i: h2d.Tile = loadImage(e.get("src"));
					if (i == null) i = h2d.Tile.fromColor(0xFF00FF, 8, 8);

					var size = metrics[metrics.length - 1].width + i.width + imageSpacing;
					if (realMaxWidth >= 0 && size > realMaxWidth && metrics[metrics.length - 1].width > 0) {
						if (splitNode.node != null) {
							size = wordSplit() + i.width + imageSpacing;
							var info = metrics[metrics.length - 1];
							// Bug: height/baseLine may be innacurate in case of sizeA sizeB<split>sizeA where sizeB is larger.
							switch (lineHeightMode) {
								case Accurate:
									var grow = i.height - i.dy - info.baseLine;
									var h = info.height;
									var bl = info.baseLine;
									if (grow > 0) {
										h += grow;
										bl += grow;
									}
									metrics.push(makeLineInfo(size, Math.max(h, bl + i.dy), bl));
								default:
									metrics.push(makeLineInfo(size, info.height, info.baseLine));
							}
						}
					} else {
						var info = metrics[metrics.length - 1];
						info.width = size;
						if (lineHeightMode == Accurate) {
							var grow = i.height - i.dy - info.baseLine;
							if (grow > 0) {
								switch (imageVerticalAlign) {
									case Top:
										info.height += grow;
									case Bottom:
										info.baseLine += grow;
										info.height += grow;
									case Middle:
										info.height += grow;
										info.baseLine += Std.int(grow / 2);
								}
							}
							grow = info.baseLine + i.dy;
							if (info.height < grow) info.height = grow;
						}
					}
					newLine = false;
					prevChar = -1;
				case "font":
					for (a in e.attributes()) {
						var v = e.get(a);
						switch (a.toLowerCase()) {
							case "face": font = loadFont(v);
							default:
						}
					}
				case "b", "bold":
					font = loadFont("bold");
				case "i", "italic":
					font = loadFont("italic");
				default:
			}
			for (child in e) buildSizes(child, font, metrics, splitNode);
			switch (nodeName) {
				case "p":
					if (!newLine) {
						makeLineBreak();
					}
				default:
			}
		} else if (e.nodeValue.length != 0) {
			newLine = false;
			var text = htmlToText(e.nodeValue);
			var fontInfo = lineFont();
			var info: LineInfo = metrics.pop();
			var leftMargin = info.width;
			var maxWidth = realMaxWidth < 0 ? Math.POSITIVE_INFINITY : realMaxWidth;
			var textSplit = [], restPos = 0;
			var x = leftMargin;
			var breakChars = 0;
			for (i in 0...text.length) {
				var cc = text.charCodeAt(i);
				var g = font.getChar(cc);
				var newline = cc == '\n'.code;
				var esize = g.width + g.getKerningOffset(prevChar);
				var nc = text.charCodeAt(i + 1);
				if (font.charset.isBreakChar(cc) && (nc == null || !font.charset.isComplementChar(nc))) {
					// Case: Very first word in text makes the line too long hence we want to start it off on a new line.
					if (x > maxWidth && textSplit.length == 0 && splitNode.node != null) {
						metrics.push(makeLineInfo(x, info.height, info.baseLine));
						x = wordSplit();
					}

					var size = x + esize + letterSpacing;
					var k = i + 1, max = text.length;
					var prevChar = cc;
					while (size <= maxWidth && k < max) {
						var cc = text.charCodeAt(k++);
						if (lineBreak && (font.charset.isSpace(cc) || cc == '\n'.code)) break;
						var e = font.getChar(cc);
						size += e.width + letterSpacing + e.getKerningOffset(prevChar);
						prevChar = cc;
						var nc = text.charCodeAt(k);
						if (font.charset.isBreakChar(cc) && (nc == null || !font.charset.isComplementChar(nc))) break;
					}
					// Avoid empty line when last char causes line-break while being CJK
					if (lineBreak && size > maxWidth && i != max - 1) {
						// Next word will reach maxWidth
						newline = true;
						if (font.charset.isSpace(cc)) {
							textSplit.push(text.substr(restPos, i - restPos));
							g = null;
						} else {
							textSplit.push(text.substr(restPos, i + 1 - restPos));
							breakChars++;
						}
						splitNode.node = null;
						restPos = i + 1;
					} else {
						splitNode.node = e;
						splitNode.pos = i + breakChars;
						splitNode.prevChar = this.prevChar;
						splitNode.width = x;
						splitNode.height = info.height;
						splitNode.baseLine = info.baseLine;
						splitNode.font = font;
					}
				}
				if (g != null && cc != '\n'.code) x += esize + letterSpacing;
				if (newline) {
					metrics.push(makeLineInfo(x, info.height, info.baseLine));
					info.height = fontInfo.lineHeight;
					info.baseLine = fontInfo.baseLine;
					x = 0;
					prevChar = -1;
					newLine = true;
				} else {
					prevChar = cc;
					newLine = false;
				}
			}

			if (restPos < text.length) {
				if (x > maxWidth) {
					if (splitNode.node != null && splitNode.node != e) {
						metrics.push(makeLineInfo(x, info.height, info.baseLine));
						x = wordSplit();
					}
				}
				textSplit.push(text.substr(restPos));
				metrics.push(makeLineInfo(x, info.height, info.baseLine));
			}

			if (newLine || metrics.length == 0) {
				metrics.push(makeLineInfo(0, fontInfo.lineHeight, fontInfo.baseLine));
				textSplit.push("");
			}
			// Save node value
			e.nodeValue = textSplit.join("\n");
		}
	}

	static var REG_SPACES = ~/[\r\n\t ]+/g;

	function htmlToText(t: String) {
		if (condenseWhite) t = REG_SPACES.replace(t, " ");
		return t;
	}

	inline function nextLine(align: Align, size: Float) {
		switch (align) {
			case Left:
				this.xPos = 0;
				if (this.xMin > 0) this.xMin = 0;
			case Right, Center, MultilineCenter, MultilineRight:
				var max = 0;
				if (align == MultilineCenter || align == MultilineRight) {
					max = hxd.Math.ceil(calcWidth);
				} else if (calcWidth >= 0) {
					max = hxd.Math.ceil(realMaxWidth);
				}

				var k = align == Center || align == MultilineCenter ? 0.5 : 1;
				this.xPos = Math.ffloor((max - size) * k);
				if (this.xPos < this.xMin) this.xMin = this.xPos;
		}
	}

	override function splitText(text: String): String {
		if (this.realMaxWidth < 0) return text;
		this.yPos = 0;
		this.xMax = 0;
		this.sizePos = 0;
		this.calcYMin = 0;

		var doc = parseText(text);

		/**
			Fri 23:36:27 24 Feb 2023 Note this comment is from h2d.HtmlText
			This might require a global refactoring at some point.
			We would need a way to somehow build an AST from the XML representation
			with all sizes and word breaks so analysis is much more easy.
		**/

		var splitNode: SplitNode = {
			node: null,
			font: font,
			width: 0,
			height: 0,
			baseLine: 0,
			pos: 0,
			prevChar: -1
		};

		var metrics = [makeLineInfo(0, font.lineHeight, font.baseLine)];
		this.prevChar = -1;
		this.newLine = true;

		for (e in doc) buildSizes(e, font, metrics, splitNode);
		this.xMax = 0;

		function addBreaks(e: Xml) {
			if (e.nodeType == Xml.Element) {
				for (x in e) addBreaks(x);
			} else {
				var text = e.nodeValue;
				var startI = 0;
				var index = Lambda.indexOf(e.parent, e);
				for (i in 0...text.length) {
					if (text.charCodeAt(i) == '\n'.code) {
						var pre = text.substring(startI, i);
						if (pre != "") e.parent.insertChild(Xml.createPCData(pre), index++);
						e.parent.insertChild(Xml.createElement("br"), index++);
						startI = i + 1;
					}
				}
				if (startI < text.length) {
					e.nodeValue = text.substr(startI);
				} else {
					e.parent.removeChild(e);
				}
			}
		}
		for (d in doc) addBreaks(d);
		return doc.toString();
	}

	override function getTextProgress(text: String, progress: Float): String {
		if (progress >= text.length) return text;
		var doc = parseText(text);
		function progressRec(e: Xml) {
			if (progress <= 0) {
				e.parent.removeChild(e);
				return;
			}
			if (e.nodeType == Xml.Element) {
				for (x in [for (x in e) x]) progressRec(x);
			} else {
				var text = htmlToText(e.nodeValue);
				var len = text.length;
				if (len > progress) {
					text = text.substr(0, Std.int(progress));
					e.nodeValue = text;
				}
				progress -= len;
			}
		}
		for (x in [for (x in doc) x]) progressRec(x);
		return doc.toString();
	}

	/**
		Store the current interactive
	**/
	var currentInteractive: Interactive;

	var interactiveNames: Array<String>;

	function addNode(e: Xml, font: h2d.Font, align: Align, rebuild: Bool, metrics: Array<LineInfo>) {
		inline function createInteractive() {
			if (interactiveNames == null || interactiveNames.length == 0) return;
			this.currentInteractive = new Interactive(0, metrics[sizePos].height, this);
			this.currentInteractive.x = xPos;
			this.currentInteractive.y = yPos;
			elements.push(this.currentInteractive);
		}

		inline function finalizeInteractive() {
			if (this.currentInteractive != null) {
				this.currentInteractive.width = xPos - this.currentInteractive.x;
				var name = null;
				if (this.interactiveNames != null && this.interactiveNames.length > 0) {
					name = this.interactiveNames[this.interactiveNames.length - 1];
				}
				this.onInteractiveCreated(this.currentInteractive, name);
				this.currentInteractive = null;
			}
		}

		inline function makeLineBreak() {
			finalizeInteractive();
			if (xPos > xMax) xMax = xPos;
			yPos += metrics[sizePos].height + lineSpacing;
			nextLine(align, metrics[++sizePos].width);
			createInteractive();
		}

		var interactiveNode: Interactive = null;

		if (e.nodeType == Xml.Element) {
			var prevColor = null, prevGlyphs = null;
			var oldAlign = align;
			var nodeName = e.nodeName.toLowerCase();

			inline function setFont(v: String) {
				font = loadFont(v);
				if (prevGlyphs == null) prevGlyphs = this.glyphs;
				var prev = this.glyphs;
				this.glyphs = new h2d.TileGroup(font == null ? null : font.tile, this);
				if (font != null) {
					switch (font.type) {
						case SignedDistanceField(channel, alphaCutoff, smoothing):
							var shader = new h3d.shader.SignedDistanceField();
							shader.channel = channel;
							shader.alphaCutoff = alphaCutoff;
							shader.smoothing = smoothing;
							shader.autoSmoothing = smoothing == -1;
							this.glyphs.smooth = this.smooth;
							this.glyphs.addShader(shader);
						default:
					}
				}
				@:privateAccess this.glyphs.curColor.load(prev.curColor);
				elements.push(this.glyphs);
			}

			switch (nodeName) {
				case "font":
					var hasColorId = false;
					for (a in e.attributes()) {
						var v = e.get(a);
						switch (a.toLowerCase()) {
							case "color":
								if (hasColorId == true) continue;
								/**
									Technically we want to deprecate this and use colorId instead.
									We will keep both color and colorId to allow us to have both
									and always take colorId over color.
									This way, the old repo will still work.
								**/
								if (prevColor == null) prevColor = @:privateAccess this.glyphs.curColor.clone();
								if (v.charCodeAt(0) == '#'.code && v.length == 4) v = "#" + v.charAt(1)
									+ v.charAt(1) + v.charAt(2) + v.charAt(2) + v.charAt(3) + v.charAt(3);
								this.glyphs.setDefaultColor(Std.parseInt("0x" + v.substr(1)));
							case "colorid":
								if (prevColor == null) prevColor = @:privateAccess this.glyphs.curColor.clone();
								hasColorId = true;
								this.glyphs.setDefaultColor(this.getColor(v));
							case "opacity":
								if (prevColor == null) prevColor = @:privateAccess this.glyphs.curColor.clone();
								@:privateAccess this.glyphs.curColor.a *= Std.parseFloat(v);
							case "face":
								setFont(v);
							default:
						}
					}
				case "p":
					for (a in e.attributes()) {
						switch (a.toLowerCase()) {
							case "align":
								var v = e.get(a);
								if (v != null) switch (v.toLowerCase()) {
									case "left":
										align = Left;
									case "center":
										align = Center;
									case "right":
										align = Right;
									case "multiline-center":
										align = MultilineCenter;
									case "multiline-right":
										align = MultilineRight;
										// ?justify
								}
							default:
						}
					}
					if (!newLine) {
						makeLineBreak();
						this.newLine = true;
						this.prevChar = -1;
					} else {
						nextLine(align, metrics[sizePos].width);
					}
				case "b", "bold":
					setFont("bold");
				case "i", "italic":
					setFont("italic");
				case "br":
					makeLineBreak();
					newLine = true;
					prevChar = -1;
				case "img":
					var i: h2d.Tile = loadImage(e.get("src"));
					if (i == null) i = h2d.Tile.fromColor(0xFF00FF, 8, 8);
					var py = yPos;
					switch (imageVerticalAlign) {
						case Bottom:
							py += metrics[sizePos].baseLine - i.height;
						case Middle:
							py += metrics[sizePos].baseLine - i.height / 2;
						case Top:
					}
					if (py + i.dy < this.calcYMin) this.calcYMin = py + i.dy;
					if (rebuild == true) {
						var b = new h2d.Bitmap(i, this);
						b.x = xPos;
						b.y = py;
						this.elements.push(b);
					}
					this.newLine = false;
					this.prevChar = -1;
					this.xPos += i.width + imageSpacing;
				case "interactive":
					if (e.exists("name")) {
						finalizeInteractive();
						if (this.interactiveNames == null) this.interactiveNames = [];
						this.interactiveNames.push(e.get("name"));
						createInteractive();
					}
				default:
			}
			for (child in e) addNode(child, font, align, rebuild, metrics);
			align = oldAlign;
			switch (nodeName) {
				case "p":
					if (newLine) {
						nextLine(align, metrics[sizePos].width);
					} else if (sizePos < metrics.length - 2 || metrics[sizePos + 1].width != 0) {
						// Condition avoid extra empty line if <p> was the last tag.
						makeLineBreak();
						this.newLine = true;
						this.prevChar = -1;
					}
				case "interactive":
					if (this.interactiveNames.length > 0) {
						finalizeInteractive();
						this.interactiveNames.pop();
						createInteractive();
					}
				default:
			}
			if (prevGlyphs != null) this.glyphs = prevGlyphs;
			if (prevColor != null) @:privateAccess glyphs.curColor.load(prevColor);
		} else if (e.nodeValue.length != 0) {
			this.newLine = false;
			var t = e.nodeValue;
			var dy = metrics[sizePos].baseLine - font.baseLine;
			for (i in 0...t.length) {
				var cc = t.charCodeAt(i);
				if (cc == "\n".code) {
					makeLineBreak();
					dy = metrics[sizePos].baseLine - font.baseLine;
					this.prevChar = -1;
					continue;
				} else {
					var fc = font.getChar(cc);
					if (fc != null) {
						xPos += fc.getKerningOffset(prevChar);
						if (rebuild) this.glyphs.add(xPos, yPos + dy, fc.t);
						if (yPos == 0 && fc.t.dy + dy < calcYMin) calcYMin = fc.t.dy + dy;
						xPos += fc.width + letterSpacing;
					}
					this.prevChar = cc;
				}
			}
		}
	}

	function set_imageSpacing(s) {
		if (imageSpacing == s) return s;
		imageSpacing = s;
		rebuild();
		return s;
	}

	override function set_textColor(c) {
		if (this.textColor == c) return c;
		this.textColor = c;
		rebuild();
		return c;
	}

	function set_condenseWhite(value: Bool) {
		if (this.condenseWhite != value) {
			this.condenseWhite = value;
			rebuild();
		}
		return value;
	}

	function set_imageVerticalAlign(align) {
		if (this.imageVerticalAlign != align) {
			this.imageVerticalAlign = align;
			rebuild();
		}
		return align;
	}

	function set_lineHeightMode(v) {
		if (this.lineHeightMode != v) {
			this.lineHeightMode = v;
			rebuild();
		}
		return v;
	}

	override function getBoundsRec(relativeTo: h2d.Object, out: h2d.col.Bounds, forSize: Bool) {
		if (forSize) {
			for (i in elements) {
				// we need to remove these from the bounds calculation so that they don't go out of bound.
				if (hxd.impl.Api.isOfType(i, h2d.Bitmap) || hxd.impl.Api.isOfType(i, Interactive)) {
					i.visible = false;
				}
			}
		}
		super.getBoundsRec(relativeTo, out, forSize);
		if (forSize) {
			for (i in elements) i.visible = true;
		}
	}

	dynamic public function onInteractiveCreated(interactive: Interactive, name: String) {}
}

/**
	# Motivation:

	h2d.HtmlText support most of the functionality but I want to add more functionality to it.

	Example of functionality includes
	- Creating Interactive using <interactive> tag.
	- Text effects

	There might be more that I want to do, so I rather just fork HtmlText and upgrade it instead of
	using HtmlText

	# TODO
	- Add a <u> / <underline> tag to draw a line below the text

	Fri 22:57:31 24 Feb 2023
	Forked h2d.HtmlText
	However, I do think that some functionality is not as useful.
	For example, <a> is really a specialised version of <interactive>.
	<a> is removed and is replaced by <interactive> instead.
	Override onInteractiveCreated to handle it
**/

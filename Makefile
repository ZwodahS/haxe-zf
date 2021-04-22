
lint:
	haxelib run formatter -s src

docs: xml pages

xml:
	haxe docs.hxml

pages:
	haxelib run dox -i build/docs -o build/pages --include zf

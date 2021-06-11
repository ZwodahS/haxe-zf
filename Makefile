
tests:
	haxe -L heaps-dev -L hxrandom -L hlsdl -L console -p src -D test -D debug -D loggingLevel=30 --hl test.hl --main tests.Test

docs: xml pages

xml:
	haxe docs.hxml

pages:
	haxelib run dox -i build/docs -o build/pages --include zf

lint:
	haxelib run formatter -s src


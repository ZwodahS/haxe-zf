
ifndef HAXEPATH
HAXEPATH=$(shell which haxe | xargs dirname)
endif

ifndef HASHLINKPATH
HASHLINKPATH=$(shell which hl | xargs dirname)
endif

buildinfo:
	@echo "OS                    : ${OS}"
	@echo "HAXE VERSION          : $(shell ${HAXEPATH}/haxe --version) from ${HAXEPATH}"
	@echo "HASHLINK VERSION      : $(shell ${HASHLINKPATH}/hl --version) from ${HASHLINKPATH}"
	@echo "Building Game Version : ${VERSION}"
	@echo "Flags                 : ${COMPILE_FLAGS} ${BINARY_FLAGS}"
	@echo ""

tests: buildinfo
	haxe -L heaps -L compiletime -L hxrandom -L hlsdl -p src -D test -D debug -D loggingLevel=30 --hl test.hl --main tests.Test

docs: xml pages

xml:
	haxe docs.hxml

pages:
	haxelib run dox -i build/docs -o build/pages --include zf

lint:
	haxelib run formatter -s src


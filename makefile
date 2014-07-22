all: build/eson-min.js


build/eson.js: src/*.coffee
	mkdir -p build
	coffee --map --output build --join eson.js --compile src/eson.coffee src/*.coffee

build/eson-min.js: build/eson.js
	uglifyjs build/eson.js --source-map build/eson-min.map --in-source-map build/eson.map -o build/eson-min.js -c

compile: build/eson.js


clean:
	rm -r build
# GNU Makefile for ESON js implementation


# Compile and minify
all: build/eson-min.js

# Just compile coffee script
coffee: build/eson.js

# Compile all testfiles and run the tests
testfiles=$(patsubst %.coffee,%.js, $(wildcard test/*.coffee))
tests: build/eson.js $(testfiles)
	mocha -R nyan

# Removes gitignores
clean:
	rm -rf build
	rm -f src/*.js
	rm -f src/*.map
	rm -f test/*.js
	rm -f test/*.map



# Rule for joining js-s to one coffee file
build/eson.js: src/*.coffee
	mkdir -p build
	coffee --map --output build --join eson.js \
		--compile src/eson.coffee src/*.coffee

# Minifing using uglifyjs
build/eson-min.js: build/eson.js
	uglifyjs build/eson.js -o build/eson-min.js -c \
		--source-map build/eson-min.map --in-source-map build/eson.map

# Generic rule for testfile
test/%.js: test/%.coffee
	coffee --output test --compile $<






ESON.js
=======

JavaScript ESON implementation.


Makefile
--------

Since project is written in CoffeeScript it has own GNU Makefile.
You'll need [coffee](https://www.npmjs.org/package/coffee-script) for compiling,
[uglifyjs](https://www.npmjs.org/package/uglify-js) for minifying and
[mocha](https://www.npmjs.org/package/mocha) for testing in Node .

Make targets:

  * `all` - compile and minify
  * `compile` - just compile CoffeeScript
  * `tests` - compile also test files
  * `test-run` - run tests
  * `clean` 
  
In browser, you can test without Mocha.
First, make `tests` and then open [test/index.html](test/index.html).

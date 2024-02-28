cleanCssOpts := -O1 all:on -O2 all:on
htmlMinifierOpts := --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true
uglifyOpts := pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe

build: clean
	mkdir -p build
	cp -a site/* build

	find build -type f -name "*.js" \
		| xargs -I{} uglifyjs {} --compress --mangle --output {}
	cleancss ${cleanCssOpts} --batch build/*.css --batch-suffix ''
	find build -type f -name "*.html" \
		| xargs -I{} html-minifier ${htmlMinifierOpts} --output {} {}

	elm make --optimize --output=build/elm.js src/Tonally.elm
	uglifyjs build/elm.js --compress "${uglifyOpts}" \
		| uglifyjs --mangle --output build/elm.js

	@echo DONE!

site/elm.js:
	elm make --optimize --output=site/elm.js src/Tonally.elm

clean:
	rm -f site/elm.js
	rm -rf build

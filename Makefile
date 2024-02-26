in := src/Tonally.elm
out := elm.js

source := site
build := build

cleanCssOpts := -O1 all:on -O2 all:on
htmlMinifierOpts := --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true
uglifyOpts := pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe

build : src site
	make clean
	mkdir -p ${build}
	cp -a ${source}/* ${build}

	find "${build}" -type f -name "*.js" | xargs -I{} uglifyjs {} --compress --mangle --output {}
	cleancss ${cleanCssOpts} --batch "${build}/*.css" --batch-suffix ''
	find "${build}" -type f -name "*.html" | xargs -I{} html-minifier ${htmlMinifierOpts} --output {} {}

	elm make --optimize --output=${build}/${out} ${in}
	uglifyjs ${build}/${out} --compress "${uglifyOpts}" | uglifyjs --mangle --output ${build}/${out}

	@echo DONE!

site/elm.js : src
	elm make --optimize --output=${source}/${out} ${in}

clean :
	rm -f ${source}/${out}
	rm -rf build

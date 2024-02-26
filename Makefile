in := src/Tonally.elm
out := elm.js
outMin := elm.min.js

source := site
build := build

uglifyOpts := pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe

build: src site clean
	rm -rf ${build}
	mkdir -p ${build}
	cp -a ${source}/* ${build}

	find "${build}" -type f -name "*.js" | xargs -I{} uglifyjs {} --compress --mangle --output {}
	cleancss -O1 all:on -O2 all:on --batch "${build}/*.css" --batch-suffix ''
	find "${build}" -type f -name "*.html" | xargs -I{} html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true --output {} {}

	elm make --optimize --output=${build}/${out} ${in}
	uglifyjs ${build}/${out} --compress "${uglifyOpts}" | uglifyjs --mangle --output ${build}/${out}

	@echo DONE!

compile : ${out}
	uglifyjs ${source}/${out} --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output ${source}/${outMin}
	@echo "Initial size: $$(cat ${source}/${out} | wc -c) bytes  (${source}/${out})"
	@echo "Minified size:$$(cat ${source}/${outMin} | wc -c) bytes  (${source}/${outMin})"
	@echo "Gzipped size: $$(cat ${source}/${outMin} | gzip -c | wc -c) bytes"

dev-compile : src/*.elm
	elm make --optimize --output=${source}/${out} ${in}


clean:
	rm -f ${source}/${out} ${source}/${outMin}
	rm -rf build

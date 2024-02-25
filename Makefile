in := src/Tonally.elm
out := elm.js
outMin := elm.min.js

${outMin}: ${out}
	uglifyjs ${out} --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output ${outMin}
	@echo "Initial size: $$(cat ${out} | wc -c) bytes  (${out})"
	@echo "Minified size:$$(cat ${outMin} | wc -c) bytes  (${outMin})"
	@echo "Gzipped size: $$(cat ${outMin} | gzip -c | wc -c) bytes"

${out} : ${in}
	elm make --optimize --output=${out} ${in}

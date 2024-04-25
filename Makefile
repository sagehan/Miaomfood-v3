#-------------------------------------------
# Variables
#-------------------------------------------
.DEFAULT_GOAL	:= init
export PATH		:= ${PATH}:${src_dir}/node_modules/.bin
SHELL			:= env "PATH=${PATH}" /bin/bash
FINDER 			:= 
BUN 			:= $(shell which bun)
BUNX 			:= $(shell which bunx)
MINIFIER		:= $(BUNX) uglifyjs
CSS_TRANSPILER	:= $(BUNX) --bun lightningcss
root_dir 		:= $(dir $(realpath $(lastword ${MAKEFILE_LIST})))
src_dir			:= ${root_dir}/miaomfood
lib_dir 		:= ${src_dir}/lib
build_dir		:= ${src_dir}/build
css_src			!= 
mjs_src 		:= $(wildcard ${lib_dir}/*.js)
comunica_config	:= ./comunica.config.json

ifneq (,${MAKE_RESTARTS})
$(info make has run ${MAKE_RESTARTS} times)
endif

#-------------------------------------------
# Targets
#-------------------------------------------
hel%:
	${verbose} printf "%s\n" \
		"Miaomfood app demo (WIP) build guide." \
		"Copyright (c) 2023-2024 Sage Han <zongshian@outlook.com>" \
		"" \
		"Usage: [V=1] $(MAKE) [target]..." \
		"" \
		"Core targets:" \
		"  init          Clear and rebuild. default target" \
		"  all           Run init deps, run, and app targets in that order" \
		"  init-deps     Delete node_modules directory and rebuild node_modules" \
		"  list-deps     List dependencies recursively on stdout" \
		"  deps          Fetch dependencies, run this task whenever you chang dependencies" \
		"  dev           Run devolopement" \
		"  app           Compile the project" \
		"  help          Display this help and exit"

all: init bun deps app run app
.PHONY: all

init: 
	@[ -d node_modules ] || echo "removing node_modules dir ...." \
		&& rm -rf node_modules ;
	$(MAKE) deps
	$(MAKE) dev
.PHONY: init

dev: ; @# TODO
.PHONY: dev

buil%: # TODO $(CSS_TRANSPILER) --minify --targets --output-dir ${OUTPUT_DIR}
	$(BUN) build ${src_dir}/app.js --outdir ${src_dir}/build
	cp ${src_dir}/service-worker.js ${src_dir}/assets/service-worker.js

dep%: .tmp/.deps.sentinel

run:
	export comunica_config=${comunica_config}
	$(BUNX) comunica-sparql-file-http -c ${comunica_context}
.PHONY: run

app: ; @# TODO
.PHONY: app

clea%: ; @# TODO
	rm ${src_dir}/assets/service-worker.js
	rm -r ${src_dir}/build/

#-------------------------------------------
# Rules
#-------------------------------------------
${build_dir}/page.min.css: ${css_src}
	$(CSS_TRANSPILER) --bundle ${src_dir}/page.css -o $@

.tmp/.deps.sentinel: package.json
	mkdir -p $(@D)
	$(BUNX) i
	touch $@

# SRC = $(wildcard src/*.js)
# LIB = $(SRC:src/%.js=lib/%.js)
# lib: $(LIB)
# lib/%.js: src/%.js babel.config.json
#   mkdir -p $(@D)
#   babel $< -o $@

#-------------------------------------------
# Configuration
#-------------------------------------------
# define PACKAGE_JSON
# { "dependencies": {
#     "gsap": "^3.12.5",
#     "htmx.org": "^1.9.12",
#     "lenis": "^1.0.44",
#     "nanostores": "^0.10.3"
#   },
#   "devDependencies": {
#     "@comunica/query-sparql-file": "^3.0.3",
#     "lightningcss-cli": "^1.24.1",
#     "prettier": "3.2.5",
#     "typescript": "^5.4.5",
#     "uglify-js": "^3.17.4"
#   }
# }
# endef

define comunica_context
{
	"sources": [ "./miaomfood/miaomfood.n3" ],
	"baseIRI": "http://schema.org/"
}
endef

# ifeq (${OS},Windows_NT)
# 	INSTALL =  powershell -c "irm bun.sh/install.ps1 | iex"
# else
# 	INSTALL =  curl -fsSL https://bun.sh/install | bash
# endif

FINDER = $(shell \
	which ag ack rg fd find | grep -m1 bin | awk -F '/' '{print $$(NF)}' | \
	xargs -I {} sh -c '<<< $$(finder-friends) grep -e "$$1"' sh {} )

define finder-friends
ag -g .css$$
ack -g .css$$
rg -g '.css$$' --files
fd -e css
find . -type f -name \*.css 
endef

#-------------------------------------------
# Some trivival settings for your saneness
#-------------------------------------------
#.RECIPEPREFIX = >
.ONESHELL:
.DELETE_ON_ERROR:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

V ?= 0
verbose_0 = @
verbose_2 = set -x;
verbose = ${verbose_${V}}
ifeq (${V},3)
SHELL := ${SHELL} -x
endif
gen_verbose_0 = @echo " GEN   " $@;
gen_verbose_2 = set -x;
gen_verbose = ${gen_verbose_${V}}
gen_verbose_esc_0 = @echo " GEN   " $$@;
gen_verbose_esc_2 = set -x;
gen_verbose_esc = ${gen_verbose_esc_${V}}

#-------------------------------------------
# Copyright (C) 2024 Sage Han.
# See https://factorcode.org/license.txt 
# for BSD license.
#-------------------------------------------

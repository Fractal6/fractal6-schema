.ONESHELL:
SHELL := /bin/bash
dgraphDirectives := $(shell echo "id search hasInverse" | tr " " "|")

.PHONY: gen_dgraph_in/type.graphql
default: schema
schema: gqlgen gqlgen2 gen_dgraph_in/type.graphql
all: dgraph schema # Contains gen_dgraph_in/type.graphql

#
# Generate Schemas
#

gqlgen:
	# Generate Gqlgen compatible GraphQL files with custom Query and Mutation.
	cp -v graphql/dgraph.graphql gen/
	cp -v graphql/directives.graphql gen/
	cp -v graphql/query.graphql gen/
	./gqlast.py graphql/type.graphql > gen/type.graphql

gqlgen2:
	# Generate Gqlgen compatible GraphQL files with dgraph generated Query and Mutation.
	./gqlast.py <(cat graphql/directives.graphql graphql/type.graphql gen_dgraph_out/schema.graphql) > gen2/schema.graphql

gen_dgraph_in/type.graphql:
	# Generate Dgraph input GraphQL.
	./gqlast.py --dgraph graphql/type.graphql > $@
	@sed -Ei "s/#.*$$//g; s/^directive .*$$//g; s/@($(dgraphDirectives))/§\1/Ig; s/@[[:alnum:]_]+\([^\)]+\)//g; s/@[[:alnum:]_]+//g; s/§(id|search|hasinverse)/@\1/Ig;" $@

dgraph: gen_dgraph_in/type.graphql
	# Populate dgraph
	cd ../database
	make update
	make fetch_schema 
	cd -
	cp ../database/schema.graphql gen_dgraph_out/schema.graphql


#
# Build Parser
#
	
_parser:
	python3 -m tatsu gram/graphql.ebnf -o gram/graphql.py
	# help: gram/graphql.py --help
	# list rule: gram/graphql.py -l
	# parse file rule: gram/graphql.py type.graphql document

_gram:
	mkdir -p gram/
	wget https://raw.githubusercontent.com/antlr/grammars-v4/master/graphql/GraphQL.g4 -O gram/graphql.g
	python3 -m tatsu.g2e graphql.g > gram/graphql.ebnf
	# /!\ Warning:
	#	 Manual modification here to get this work with gqlast.py

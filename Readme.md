# Fractale Schema

This repo contains the core schema of the project and the binary [gqlast.py](gqlast.py) that parses and generates GraphQL files from source schema to feed the libraries in use such as `gqlgen`, `elm-graphql` and `dgraph`.


### Input schema

User defined schemas are located into the directory `graphql/`:
* [graphql/fractal6.graphql](graphql/fractal6.graphql): Defines the main data structures of Fractal6, such as the graph structures of organisations the tensions etc.
* [graphql/errors.graphql](graphql/errors.graphql) : Defines structured errors for client interpretation.
* [graphql/directives.graphql](graphql/directives.graphql): [used by gqlgen only] Defines the custom directives implemented in the Business Logic Layer.

### GraphQL applications

The [graphql/](graphql/) directory contains the schema source for all other schemas which are used to generated valid GraphQL scheme for the following applications:

* **dgraph** (almost native GraphQL support):
    * remove custom directives and comments.
    * types that implements interface cant redefined fields/edges -> Only the interface field are kept because there are supposed to be more flexible.
* **gqlgen** and **elm-graphql** (GraphQL support): dgraph schema is used to provide gqlgen and elm-graphql with custom rational:
    * types that implement interfaces need to inherit the fields of the mother interface (not needed for dgraph).
    * change `interface` to `type`  to simplify gqlgen implementation.
    * input directives (`@alter_*` and `@patch_*` directives) are moved to the input type generated by dgraph
    * dgraph type arguments are copied into the original type if they don't exist.
    * manage duplicated types definition (since dgraph generated schema redefined types)


### Output directories
The generator output files in the following directories:

* `gen/`: Schema used by fractal6.go (glqgen) and fractal6-ui.elm (elm-graphql) with custom schema from dgraph introspection.
* `gen_dgraph_in/`: the schema use to alter the dgraph database.
* `gen_dgraph_out/`: the schema generated by dgraph, with automatic queries, mutations and inputs generated.

Other directories:
* `gram/`: The grammar file needed to build the GraphQL parser (see `make parser`). 
* `graphql/`: User defined schemas.

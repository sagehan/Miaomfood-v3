! Copyright (C) 2024 Sage Han.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel ;
IN: miaomfood

TUPLE: address
    { addressLocality initial: "乌鲁木齐" }
    { streetAddress   initial: "高新街桂林路东四巷锦林二巷8号1楼" }
;
TUPLE: eatery
    { name initial: "喵姆餐厅" }
    { description initial: "好多好多的芝士和肉\s给你认真生活的力量" }
    { logo initial: "/assets/logo.svg" }
    { telephone initial: "+8618123456789" }
    { openingHours initial: "Tu––Su\s11:00––22:00" }
;

USE: urls 
: query-url ( query -- url )
    URL" http://localhost:3000/sparql" swap
        "query" set-query-param ;

USING: http http.client ;
: json-request ( url -- request )
    <get-request> "application/json" "accept" set-header ;

USING: http.client io.encodings.utf8 io.encodings.string json ;
: sparql-query ( query -- results )
    query-url json-request http-request nip utf8 decode json> ;

USE: classes.tuple
: <eatery> ( -- eatery )
    "PREFIX : <http://schema.org/>
    CONSTRUCT { ?s ?p ?o } WHERE {
        [ :mainEntity ?s ]. ?s :name \"喵姆餐厅\"@zh; ?p ?o. }"
    sparql-query ;  ! TODO: figure out how to get compact JSON-LD from SPARQL endpoint ;
                    ! https://github.com/comunica/comunica/discussions/894#discussioncomment-3869502
                    ! https://github.com/comunica/comunica/blob/9daec7da03e159726559720acd0221881533d179/packages/actor-sparql-parse-algebra/components/Actor/SparqlParse/Algebra.jsonld
                    ! https://github.com/comunica/comunica/blob/2a27e571b7180fcdb6bef6f27ee0f12afb8766d6/packages/actor-sparql-parse-algebra/components/ActorSparqlParseAlgebra.jsonld

USING: http.server.dispatchers http.server.static html.templates.chloe
    html.forms furnace.boilerplate furnace.actions ;

TUPLE: main-dispatcher < dispatcher ;

: <layout-boilerplate> ( responder -- responder' )
    <boilerplate> { main-dispatcher "page" } >>template ;

: <main-page> ( -- action )
    <page-action> { main-dispatcher "app" } >>template ;

: <banner> ( -- action )
    <page-action>
        [ 
            T{ eatery } from-object
            "address" [ T{ address } from-object ] nest-form
        ] >>init
        { main-dispatcher "banner" } >>template ;

: <campaign> ( -- action )
    <page-action> { main-dispatcher "campaign" } >>template ;

: <menu> ( -- action )
    <page-action> { main-dispatcher "menu" } >>template ;

: <cart> ( -- action )
    <page-action> { main-dispatcher "cart" } >>template ;

: <main-dispatcher> ( -- responder )
    main-dispatcher new-dispatcher
        "vocab:miaomfood/assets/" <static>  "assets"   add-responder
        <main-page> <layout-boilerplate>    ""         add-responder
        <cart>                              "cart"     add-responder
        <menu>                              "menu"     add-responder
        <banner>                            "banner"   add-responder
        <campaign>                          "campaign" add-responder
;

USING: namespaces http.server io.sockets.secure.debug io.servers ;
: run-test-webapp ( -- )
    t development? set-global
    <main-dispatcher> main-responder set-global
    <http-server>
        <test-secure-config> >>secure-config
        8431 >>secure
        8081 >>insecure
    start-server drop ;

MAIN: run-test-webapp
! Copyright (C) 2024 Sage Han.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel io.servers ;
IN: miaomfood

USING:
    http.server.dispatchers
    http.server.static
    html.templates.chloe
    furnace.boilerplate
    furnace.actions
 ;

TUPLE: main-dispatcher < dispatcher ;

: <layout-boilerplate> ( responder -- responder' )
    <boilerplate> { main-dispatcher "page" } >>template ;

: <main-page> ( -- responder )
    <page-action> { main-dispatcher "app" } >>template ;

: <banner> ( -- responder )
    <page-action> { main-dispatcher "banner" } >>template ;

: <campaign> ( -- responder )
    <page-action> { main-dispatcher "campaign" } >>template ;

: <cart> ( -- responder )
    <page-action> { main-dispatcher "cart" } >>template ;

: <main-dispatcher> ( -- responder )
    main-dispatcher new-dispatcher
        "vocab:miaomfood/assets/" <static>  "assets"   add-responder
        <main-page> <layout-boilerplate>    ""         add-responder
        <cart>                              "cart"     add-responder
        <banner>                            "banner"   add-responder
        <campaign>                          "campaign" add-responder
;

USING:
    io.sockets.secure.debug
    io.servers
    http.server
    namespaces
 ;

: run-test-webapp ( -- )
    t development? set-global
    <main-dispatcher> main-responder set-global
    <http-server>
        <test-secure-config> >>secure-config
        8431 >>secure
        8081 >>insecure
    start-server drop 
;

MAIN: run-test-webapp
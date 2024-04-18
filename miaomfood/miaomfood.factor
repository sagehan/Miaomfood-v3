! Copyright (C) 2024 Sage Han.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel io.servers ;
IN: miaomfood

USING:
    http.server.dispatchers
    http.server.static
    html.templates.chloe
    html.forms
    furnace.boilerplate
    furnace.actions
 ;

TUPLE: main-dispatcher < dispatcher ;
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

: <layout-boilerplate> ( responder -- responder' )
    <boilerplate> { main-dispatcher "page" } >>template ;

: <main-page> ( -- action )
    <page-action> { main-dispatcher "app" } >>template ;

: <banner> ( -- action )
    <page-action>
        [ 
            T{ eatery } from-object
            "address" [
                T{ address } from-object
            ] nest-form
        ]  >>init
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
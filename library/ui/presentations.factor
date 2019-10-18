! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-presentations
USING: arrays gadgets gadgets-borders gadgets-labels
gadgets-layouts gadgets-outliner gadgets-panes hashtables io
kernel sequences strings styles ;

! Character styles

: apply-style ( style gadget key quot -- style gadget )
    >r pick hash r> when* ; inline

: apply-foreground-style ( style gadget -- style gadget )
    foreground [ over set-label-color ] apply-style ;

: apply-background-style ( style gadget -- style gadget )
    background [ <solid> over set-gadget-interior ] apply-style ;

: specified-font ( style -- font )
    [ font swap hash [ "monospace" ] unless* ] keep
    [ font-style swap hash [ plain ] unless* ] keep
    font-size swap hash [ 12 ] unless* 3array ;

: apply-font-style ( style gadget -- style gadget )
    over specified-font over set-label-font ;

: apply-command-style ( style gadget -- style gadget )
    presented [ <command-button> ] apply-style ;

: <presentation> ( style text -- gadget )
    <label>
    apply-foreground-style
    apply-background-style
    apply-font-style
    apply-command-style
    nip ;

! Paragraph styles

: apply-wrap-style ( style pane -- style pane )
    wrap-margin [
        2dup <paragraph> swap set-pane-prototype
        <paragraph> over set-pane-current
    ] apply-style ;

: apply-border-width-style ( style gadget -- style gadget )
    border-width [ <border> ] apply-style ;

: apply-border-color-style ( style gadget -- style gadget )
    border-color [
        <solid> over set-gadget-boundary
    ] apply-style ;

: apply-page-color-style ( style gadget -- style gadget )
    page-color [
        <solid> over set-gadget-interior
    ] apply-style ;

: apply-outliner-style ( style gadget -- style gadget )
    outline [ <outliner> ] apply-style ;

: <styled-paragraph> ( style pane -- gadget )
    apply-wrap-style
    apply-border-width-style
    apply-border-color-style
    apply-page-color-style
    apply-command-style
    apply-outliner-style
    nip ;

: <nested-pane> ( quot style -- gadget )
    #! Create a pane, call the quotation to fill it out.
    >r <pane> dup r> swap <styled-paragraph>
    >r swap with-pane r> ; inline

M: pane with-nested-stream ( quot style stream -- )
    >r <nested-pane> r> write-gadget ;

! Stream utilities
M: pack stream-close ( stream -- ) drop ;

M: paragraph stream-close ( stream -- ) drop ;

: gadget-write ( string gadget -- )
    over empty? [ 2drop ] [ >r <label> r> add-gadget ] if ;

M: pack stream-write ( string stream -- ) gadget-write ;

: gadget-bl ( style stream -- )
    >r " " <presentation> <word-break-gadget> r> add-gadget ;

M: paragraph stream-write ( string stream -- )
    swap " " split
    [ over gadget-write ] [ H{ } over gadget-bl ] interleave
    drop ;

: gadget-write1 ( char gadget -- )
    >r ch>string r> stream-write ;

M: pack stream-write1 ( char stream -- ) gadget-write1 ;

M: paragraph stream-write1 ( char stream -- )
    over CHAR: \s =
    [ H{ } swap gadget-bl drop ] [ gadget-write1 ] if ;

: gadget-format ( string style stream -- )
    pick empty? pick hash-empty? and
    [ 3drop ] [ >r swap <presentation> r> add-gadget ] if ;

M: pack stream-format ( string style stream -- )
    gadget-format ;

M: paragraph stream-format ( string style stream -- )
    presented pick hash [
        gadget-format
    ] [
        rot " " split
        [ pick pick gadget-format ]
        [ 2dup gadget-bl ] interleave
        2drop
    ] if ;

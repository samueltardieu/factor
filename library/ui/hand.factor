! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event
sdl-video ;

DEFER: pick-up

: pick-up-list ( point list -- gadget )
    dup [
        2dup car pick-up dup [
            2nip
        ] [
            drop cdr pick-up-list
        ] ifte
    ] [
        2drop f
    ] ifte ;

: pick-up* ( point gadget -- gadget/t )
    #! The logic is thus. If the point is definately outside the
    #! box, return f. Otherwise, see if the point is contained
    #! in any subgadget. If not, see if it is contained in the
    #! box delegate.
    2dup inside? [
        2dup [ translate ] keep
        gadget-children pick-up-list dup [
            2nip
        ] [
            3drop t
        ] ifte
    ] [
        2drop f
    ] ifte ;

: pick-up ( point gadget -- gadget )
    #! pick-up* returns t to mean 'this gadget', avoiding the
    #! exposed facade issue.
    tuck pick-up* dup t = [ drop ] [ nip ] ifte ;

DEFER: world

! The hand is a special gadget that holds mouse position and
! mouse button click state. The hand's parent is the world, but
! it is special in that the world does not list it as part of
! its contents.
TUPLE: hand click-pos clicked buttons gadget delegate ;

C: hand ( world -- hand )
    0 0 0 0 <rectangle> <gadget>
    over set-hand-delegate
    [ set-gadget-parent ] 2keep
    [ set-hand-gadget ] keep ;

: button/ ( n hand -- )
    dup hand-gadget over set-hand-clicked
    dup shape-pos over set-hand-click-pos
    [ hand-buttons unique ] keep set-hand-buttons ;

: button\ ( n hand -- )
    [ hand-buttons remove ] keep set-hand-buttons ;

: fire-leave ( hand -- )
    dup hand-gadget [ swap shape-pos swap screen-pos - ] keep
    mouse-leave ;

: fire-enter ( oldpos hand -- )
    hand-gadget [ screen-pos - ] keep
    mouse-enter ;

: gadget-at-hand ( hand -- gadget )
    dup gadget-children [ car ] [ world get pick-up ] ?ifte ;

: update-hand-gadget ( hand -- )
    #! The hand gadget is the gadget under the hand right now.
    dup gadget-at-hand [ swap set-hand-gadget ] keep ;

: move-hand ( x y hand -- )
    dup shape-pos >r
    [ move-gadget ] keep
    dup fire-leave
    dup update-hand-gadget
    [ motion ] swap handle-gesture
    r> swap fire-enter ;

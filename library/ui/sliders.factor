! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-scrolling
USING: arrays gadgets gadgets-buttons gadgets-layouts
gadgets-theme generic kernel lists math namespaces sequences
styles threads vectors ;

! An elevator has a thumb that may be moved up and down.
TUPLE: elevator ;

: find-elevator [ elevator? ] find-parent ;

! A slider scrolls a viewport.
TUPLE: slider elevator thumb value max page ;

: find-slider [ slider? ] find-parent ;

: slider-scale ( slider -- n )
    #! A scaling factor such that if x is a slider co-ordinate,
    #! x*n is the screen position of the thumb, and conversely
    #! for x/n. The '1 max' calls avoid division by zero.
    dup slider-elevator rect-dim over gadget-orientation v. 1 max
    swap slider-max 1 max / ;

: slider>screen slider-scale * ;

: screen>slider slider-scale / ;

: fix-slider-value ( n slider -- n )
    dup slider-max swap slider-page - min 0 max >fixnum ;

: fix-slider ( slider -- )
    #! Call after changing slots, to relayout and do invariants:
    #! - max <= page
    #! - 0 <= value <= max-page
    dup slider-elevator relayout-1
    dup slider-max over slider-page max over set-slider-max
    dup slider-value over fix-slider-value swap set-slider-value ;

SYMBOL: slider-changed

: set-slider-value* ( value slider -- )
    [ set-slider-value ] keep [ fix-slider ] keep
    [ slider-changed ] swap handle-gesture drop ;

: elevator-drag ( elevator -- )
    [ find-slider ] keep drag-loc over gadget-orientation v.
    over screen>slider swap set-slider-value* ;

: thumb-actions ( thumb -- )
    dup [ drop ] [ button-up ] set-action
    dup [ drop ] [ button-down ] set-action
    [ find-elevator elevator-drag ] [ drag ] set-action ;

: <thumb> ( vector -- thumb )
    <gadget> [ set-gadget-orientation ] keep
    t over set-gadget-root?
    dup thumb-theme
    dup thumb-actions ;

: slide-by ( amount gadget -- )
    #! The gadget can be any child of a slider.
    find-slider [ slider-value + ] keep set-slider-value* ;

: slide-by-page ( -1/1 gadget -- )
    [ slider-page * ] keep slide-by ;

: elevator-click ( elevator -- )
    dup hand get relative >r find-slider r>
    over gadget-orientation v.
    over screen>slider over slider-value - sgn
    swap slide-by-page ;

: elevator-actions ( elevator -- )
    [ elevator-click ] [ button-down ] set-action ;

C: elevator ( vector -- elevator )
    dup delegate>gadget [ set-gadget-orientation ] keep
    dup elevator-theme dup elevator-actions ;

: (layout-thumb) ( slider n -- n )
    over gadget-orientation n*v swap slider-thumb ;

: thumb-loc ( slider -- loc )
    dup slider-value swap slider>screen ;

: layout-thumb-loc ( slider -- )
    dup thumb-loc (layout-thumb) set-rect-loc ;

: thumb-dim ( slider -- h )
    dup slider-page swap slider>screen ;

: layout-thumb-dim ( slider -- )
    dup dup thumb-dim (layout-thumb)
    >r >r dup rect-dim r> rot gadget-orientation set-axis r>
    set-gadget-dim ;

: layout-thumb ( slider -- )
    dup layout-thumb-loc layout-thumb-dim ;

M: elevator layout* ( elevator -- )
    find-slider layout-thumb ;

: slide-by-line ( -1/1 slider -- ) >r 32 * r> slide-by ;

: slider-vertical? gadget-orientation { 0 1 0 } = ;

: <slide-button> ( orientation polygon amount -- )
    >r { 0.5 0.5 0.5 1.0 } swap <polygon-gadget> r>
    [ swap slide-by-line ] curry <repeat-button>
    [ set-gadget-orientation ] keep ;

: <up-button> ( slider orientation -- button )
    swap slider-vertical? arrow-up arrow-left ? -1
    <slide-button> ;

: add-up { 1 1 1 } over gadget-orientation v- first2 frame-add ;

: <down-button> ( slider orientation -- button )
    swap slider-vertical? arrow-down arrow-right ? 1
    <slide-button> ;

: add-down { 1 1 1 } over gadget-orientation v+ first2 frame-add ;

: add-elevator 2dup set-slider-elevator @center frame-add ;

: add-thumb 2dup slider-elevator add-gadget set-slider-thumb ;

: slider-opposite ( slider -- vector )
    gadget-orientation { 1 1 0 } swap v- ;

C: slider ( vector -- slider )
    dup delegate>frame
    [ set-gadget-orientation ] keep
    0 over set-slider-value
    0 over set-slider-page
    0 over set-slider-max
    dup slider-opposite
    dup <elevator> pick add-elevator
    2dup <up-button> pick add-up
    2dup <down-button> pick add-down
    <thumb> over add-thumb ;

: <x-slider> ( -- slider ) { 1 0 0 } <slider> ;

: <y-slider> ( -- slider ) { 0 1 0 } <slider> ;

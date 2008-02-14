USING: alien alien.syntax combinators kernel parser sequences
system words namespaces hashtables init math arrays assocs 
sequences.lib continuations ;
<< {
    { [ windows? ] [ "opengl.gl.windows" ] }
    { [ macosx? ]  [ "opengl.gl.macosx" ] }
    { [ unix? ] [ "opengl.gl.unix" ] }
    { [ t ] [ "Unknown OpenGL platform" throw ] }
} cond use+ >>
IN: opengl.gl.extensions

SYMBOL: +gl-function-number-counter+
SYMBOL: +gl-function-pointers+

: reset-gl-function-number-counter ( -- )
    0 +gl-function-number-counter+ set-global ;
: reset-gl-function-pointers ( -- )
    100 <hashtable> +gl-function-pointers+ set-global ;
    
[ reset-gl-function-pointers ] "opengl.gl init hook" add-init-hook
reset-gl-function-pointers
reset-gl-function-number-counter

: gl-function-number ( -- n )
    +gl-function-number-counter+ get-global
    dup 1+ +gl-function-number-counter+ set-global ;

: gl-function-pointer ( names n -- funptr )
    gl-function-context 2array dup +gl-function-pointers+ get-global at
    [ 2nip ] [
        >r [ gl-function-address ] attempt-each 
        dup [ "OpenGL function not available" throw ] unless
        dup r>
        +gl-function-pointers+ get-global set-at
    ] if* ;

: GL-FUNCTION:
    gl-function-calling-convention
    scan
    scan dup
    scan drop "}" parse-tokens swap add*
    gl-function-number
    [ gl-function-pointer ] 2curry swap
    ";" parse-tokens [ "()" subseq? not ] subset
    define-indirect
    ; parsing

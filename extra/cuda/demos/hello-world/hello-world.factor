! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
byte-arrays cuda cuda.contexts cuda.devices cuda.ffi
cuda.libraries cuda.memory cuda.syntax destructors io
io.encodings.string io.encodings.utf8 kernel locals math
math.parser namespaces prettyprint sequences strings ;
IN: cuda.demos.hello-world

CUDA-LIBRARY: hello cuda64 "vocab:cuda/demos/hello-world/hello.ptx"

CUDA-FUNCTION: helloWorld ( char* string-ptr )

: cuda-hello-world ( -- )
    init-cuda [
        [
            context-device number>string
            "CUDA device " ": " surround write
            "Hello World!" [ - ] B{ } map-index-as host>device &cuda-free

            [ { 2 1 } { 6 1 1 } <grid> helloWorld ]
            [ 12 device>host >string print ] bi
        ] with-destructors
    ] with-each-cuda-device ;

MAIN: cuda-hello-world

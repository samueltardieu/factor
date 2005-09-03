! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: hashtables errors kernel lists namespaces strings
sequences ;

SYMBOL: vocabularies

: word ( -- word ) \ word global hash ;
: set-word ( word -- ) \ word global set-hash ;

: vocabs ( -- list )
    #! Push a list of vocabularies.
    vocabularies get hash-keys string-sort ;

: vocab ( name -- vocab )
    #! Get a vocabulary.
    vocabularies get hash ;

: words ( vocab -- list )
    #! Push a list of all words in a vocabulary.
    #! Filter empty slots.
    vocab dup [ hash-values [ ] subset word-sort ] when ;

: all-words ( -- list )
    vocabs [ words ] map concat ;

: each-word ( quot -- )
    #! Apply a quotation to each word in the image.
    all-words swap each ; inline

: word-subset ( pred -- list | pred: word -- ? )
    #! A list of words matching the predicate.
    all-words swap subset ; inline

: word-subset-with ( obj pred -- list | pred: obj word -- ? )
    all-words swap subset-with ; inline

: recrossref ( -- )
    #! Update word cross referencing information.
    {{ }} clone crossref global set-hash
    [ add-crossref ] each-word ;

: lookup ( name vocab -- word ) vocab ?hash ;

: search ( name vocabs -- word )
    [ lookup ] map-with [ ] find nip ;

: reveal ( word -- )
    #! Add a new word to its vocabulary.
    vocabularies get [
        dup word-name over word-vocabulary nest set-hash
    ] bind ;

: check-create ( name vocab -- )
    string? [ "Vocabulary name is not a string" throw ] unless
    string? [ "Word name is not a string" throw ] unless ;

: create ( name vocab -- word )
    #! Create a new word in a vocabulary. If the vocabulary
    #! already contains the word, the existing instance is
    #! returned.
    2dup check-create 2dup lookup dup
    [ 2nip ] [ drop <word> dup reveal ] ifte ;

: constructor-word ( string vocab -- word )
    >r "<" swap ">" append3 r> create ;

: forget ( word -- )
    #! Remove a word definition.
    dup uncrossref
    dup word-name swap word-vocabulary vocab remove-hash ;

: interned? ( word -- ? )
    #! Test if the word is a member of its vocabulary.
    dup word-name over word-vocabulary lookup eq? ;

: init-search-path ( -- )
    "scratchpad" "in" set
    [
        "compiler" "errors" "generic" "hashtables"
        "help" "inference" "inspector" "interpreter" "io"
        "jedit" "kernel" "listener" "lists" "math" "matrices"
        "memory" "namespaces" "parser" "prettyprint" "queues"
        "scratchpad" "sequences" "shells" "strings" "styles"
        "syntax" "test" "threads" "vectors" "words"
    ] "use" set ;

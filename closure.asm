.def: print_args_closure 0
    end
.end

.def: print_args 1
    arg 0 1
    izero 0
    end
.end

.def: main 0
    ; get the vector with command line operands
    arg 0 1

    ; call function that returns the closure
    frame 1
    param 0 1
    call print_args 2

    ; create frame for our closure and
    ; call it
    clframe 0
    ;clcall 2 0

    izero 0
    end
.end
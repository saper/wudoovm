; This script's purpose is to stress register-reference syntax in
; integer related instructions.

.function: foo
    istore 1 16
    istore 16 1

    print 1
    print @1
    print 16
    print @16

    end
.end

.function: main
    frame 0 17
    call foo
    izero 0
    end
.end

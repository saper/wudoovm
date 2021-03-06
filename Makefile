CXXFLAGS=-std=c++11 -Wall -pedantic -Wfatal-errors -g -I./include
CXXOPTIMIZATIONFLAGS=
COPTIMIZATIONFLAGS=

VIUA_CPU_INSTR_FILES_CPP=src/cpu/instr/general.cpp src/cpu/instr/registers.cpp src/cpu/instr/calls.cpp src/cpu/instr/linking.cpp src/cpu/instr/tcmechanism.cpp src/cpu/instr/closure.cpp src/cpu/instr/int.cpp src/cpu/instr/float.cpp src/cpu/instr/byte.cpp src/cpu/instr/str.cpp src/cpu/instr/bool.cpp src/cpu/instr/cast.cpp src/cpu/instr/vector.cpp
VIUA_CPU_INSTR_FILES_O=build/cpu/instr/general.o build/cpu/instr/registers.o build/cpu/instr/calls.o build/cpu/instr/linking.o build/cpu/instr/tcmechanism.o build/cpu/instr/closure.o build/cpu/instr/int.o build/cpu/instr/float.o build/cpu/instr/byte.o build/cpu/instr/str.o build/cpu/instr/bool.o build/cpu/instr/cast.o build/cpu/instr/vector.o

PREFIX=/usr
BIN_PATH=${PREFIX}/bin
LIB_PATH=${PREFIX}/lib/viua
H_PATH=/usr/include/viua

LIBDL=-ldl

.SUFFIXES: .cpp .h .o

.PHONY: all remake clean clean-support clean-test-compiles install test version devellibs


############################################################
# BASICS
all: build/bin/vm/asm build/bin/vm/cpu build/bin/vm/vdb build/bin/vm/dis build/bin/opcodes.bin devellibs

remake: clean all


############################################################
# CLEANING
clean: clean-support
	rm -f ./build/lib/*.o
	rm -f ./build/cpu/instr/*.o
	rm -f ./build/cpu/*.o
	rm -f ./build/cg/assembler/*.o
	rm -f ./build/cg/disassembler/*.o
	rm -f ./build/cg/bytecode/*.o
	rm -f ./build/*.o
	rm -f ./bin/vm/*

clean-support:
	rm -f ./build/support/*.o

clean-test-compiles:
	rm -f ./tests/compiled/*.bin
	rm -f ./tests/compiled/*.asm
	rm -f ./tests/compiled/*.wlib


############################################################
# DOCUMENTATION
doc/viua_virtual_machine.pdf: doc/viua_virtual_machine.lyx
	lyx --export-to pdf doc/viua_virtual_machine.pdf --force-overwrite main doc/viua_virtual_machine.lyx


############################################################
# INSTALLATION AND UNINSTALLATION
bininstall: build/bin/vm/asm build/bin/vm/cpu build/bin/vm/vdb build/bin/vm/dis
	mkdir -p ${BIN_PATH}
	cp ./build/bin/vm/asm ${BIN_PATH}/viua-asm
	chmod 755 ${BIN_PATH}/viua-asm
	cp ./build/bin/vm/cpu ${BIN_PATH}/viua-cpu
	chmod 755 ${BIN_PATH}/viua-cpu
	cp ./build/bin/vm/vdb ${BIN_PATH}/viua-db
	chmod 755 ${BIN_PATH}/viua-db
	cp ./build/bin/vm/dis ${BIN_PATH}/viua-dis
	chmod 755 ${BIN_PATH}/viua-dis

libinstall: stdlib
	mkdir -p ${LIB_PATH}/std/extern
	mkdir -p ${LIB_PATH}/std/native
	mkdir -p ${LIB_PATH}/core
	cp ./build/stdlib/lib/*.so ${LIB_PATH}/std/extern

devellibs:
	${CXX} -std=c++11 -fPIC -c -I./include -o ./build/platform/exception.o src/types/exception.cpp
	${CXX} -std=c++11 -fPIC -c -I./include -o ./build/platform/vector.o src/types/vector.cpp
	${CXX} -std=c++11 -fPIC -c -I./include -o ./build/platform/registerset.o src/cpu/registerset.cpp
	${CXX} -std=c++11 -fPIC -c -I./include -o ./build/platform/support_string.o src/support/string.cpp

installdevel: devellibs
	mkdir -p ${LIB_PATH}/platform
	cp ./build/platform/*.o ${LIB_PATH}/platform

install: bininstall installdevel
	mkdir -p ${H_PATH}
	cp -R ./include/viua/. ${H_PATH}/

uninstall:
	rm -rf ${H_PATH}
	rm -rf ${LIB_PATH}
	rm -rf ${BIN_PATH}/viua-*


############################################################
# TESTING
test: build/bin/vm/asm build/bin/vm/cpu build/bin/vm/dis devellibs
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -fPIC -shared -o World.so ./sample/asm/external/World.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -fPIC -shared -o math.so ./sample/asm/external/math.cpp ./build/platform/registerset.o ./build/platform/exception.o
	python3 ./tests/tests.py --verbose --catch --failfast


############################################################
# VERSION UPDATE
version:
	./scripts/update_commit_info.sh
	touch src/front/asm.cpp
	touch src/front/dis.cpp
	touch src/front/cpu.cpp
	touch src/front/wdb.cpp


############################################################
# VIRTUAL MACHINE CODE
build/bin/vm/cpu: src/front/cpu.cpp build/cpu/cpu.o build/cpu/dispatch.o build/cpu/registserset.o build/loader.o build/printutils.o build/support/pointer.o build/support/string.o ${VIUA_CPU_INSTR_FILES_O} build/types/vector.o build/types/function.o build/types/closure.o build/types/string.o build/types/exception.o
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -o $@ $^ $(LIBDL)

build/bin/vm/vdb: src/front/wdb.cpp build/lib/linenoise.o build/cpu/cpu.o build/cpu/dispatch.o build/cpu/registserset.o build/loader.o build/cg/disassembler/disassembler.o build/printutils.o build/support/pointer.o build/support/string.o ${VIUA_CPU_INSTR_FILES_O} build/types/vector.o build/types/function.o build/types/closure.o build/types/string.o build/types/exception.o
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -o $@ $^ $(LIBDL)

build/bin/vm/asm: src/front/asm.cpp build/program.o build/programinstructions.o build/cg/assembler/operands.o build/cg/assembler/ce.o build/cg/assembler/verify.o build/cg/bytecode/instructions.o build/loader.o build/support/string.o
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -o $@ $^

build/bin/vm/dis: src/front/dis.cpp build/loader.o build/cg/disassembler/disassembler.o build/support/pointer.o build/support/string.o
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -o $@ $^


############################################################
# OBJECTS COMMON FOR DEBUGGER AND CPU COMPILATION
build/cpu/dispatch.o: src/cpu/dispatch.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/cpu.o: src/cpu/cpu.cpp include/viua/cpu/cpu.h include/viua/bytecode/opcodes.h include/viua/cpu/frame.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/registserset.o: src/cpu/registerset.cpp include/viua/cpu/registerset.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


############################################################
# STANDARD LIBRARY
stdlib:
	echo "OK"


############################################################
# OPCODE LISTER PROGRAM
build/bin/opcodes.bin: src/bytecode/opcd.cpp include/viua/bytecode/opcodes.h include/viua/bytecode/maps.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -o $@ $<


############################################################
# CODE GENERATION
build/cg/disassembler/disassembler.o: src/cg/disassembler/disassembler.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


############################################################
# TYPE MODULES
build/types/vector.o: src/types/vector.cpp include/viua/types/vector.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/types/closure.o: src/types/closure.cpp include/viua/types/closure.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/types/function.o: src/types/function.cpp include/viua/types/function.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/types/string.o: src/types/string.cpp include/viua/types/string.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/types/exception.o: src/types/exception.cpp include/viua/types/exception.h
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


############################################################
# CPU INSTRUCTIONS
build/cpu/instr/general.o: src/cpu/instr/general.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/registers.o: src/cpu/instr/registers.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/calls.o: src/cpu/instr/calls.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/linking.o: src/cpu/instr/linking.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/tcmechanism.o: src/cpu/instr/tcmechanism.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/closure.o: src/cpu/instr/closure.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/int.o: src/cpu/instr/int.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/float.o: src/cpu/instr/float.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/byte.o: src/cpu/instr/byte.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/str.o: src/cpu/instr/str.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/bool.o: src/cpu/instr/bool.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/cast.o: src/cpu/instr/cast.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cpu/instr/vector.o: src/cpu/instr/vector.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


############################################################
# UTILITY MODULES
build/printutils.o: src/printutils.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/support/string.o: src/support/string.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/support/pointer.o: src/support/pointer.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


############################################################
# CODE AND BYTECODE GENERATION
build/program.o: src/program.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/programinstructions.o: src/programinstructions.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


build/cg/assembler/operands.o: src/cg/assembler/operands.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cg/assembler/ce.o: src/cg/assembler/codeextract.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<

build/cg/assembler/verify.o: src/cg/assembler/verify.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


build/cg/bytecode/instructions.o: src/cg/bytecode/instructions.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


############################################################
# MISC MODULES
build/loader.o: src/loader.cpp
	${CXX} ${CXXFLAGS} ${CXXOPTIMIZATIONFLAGS} -c -o $@ $<


############################################################
# DEPENDENCY LIBRARIES
build/lib/linenoise.o: lib/linenoise/linenoise.c lib/linenoise/linenoise.h
	${CC} ${CFLAGS} ${COPTIMIZATIONFLAGS} -c -o $@ $<

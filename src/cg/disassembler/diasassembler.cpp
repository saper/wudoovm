#include "../../bytecode/opcodes.h"
#include "../../bytecode/maps.h"
#include "../../support/pointer.h"
#include "disassembler.h"
using namespace std;


tuple<string, unsigned> disassembler::instruction(byte* ptr) {
    byte* bptr = ptr;

    OPCODE op = OPCODE(*bptr);
    string opname = OP_NAMES.at(op);

    ++bptr; // instruction byte is not needed anymore

    ostringstream oss;
    oss << opname;
    if (in(OP_VARIABLE_LENGTH, op)) {
        bptr += string(bptr).size();
        ++bptr; // for null character terminating the C-style string not included in std::string
        bptr += (OP_SIZES.at(opname)-1); // -1 because OP_SIZES add one for instruction-storing byte
    } else {
        bptr += (OP_SIZES.at(opname)-1); // -1 because OP_SIZES add one for instruction-storing byte
    }

    unsigned increase = (bptr-ptr);

    switch (op) {
        case IZERO:
        case PRINT:
        case ECHO:
        case NOT:
            ++ptr;

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            break;
        case ISTORE:
        case ITOF:
        case FTOI:
        case STOI:
        case STOF:
            ++ptr;

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            break;
        case IADD:
        case ISUB:
        case IMUL:
        case IDIV:
        case IINC:
        case IDEC:
        case ILT:
        case ILTE:
        case IGT:
        case IGTE:
        case IEQ:
        case FADD:
        case FSUB:
        case FMUL:
        case FDIV:
        case FLT:
        case FLTE:
        case FGT:
        case FGTE:
        case FEQ:
            ++ptr;

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            break;
        case BRANCH:
            ++ptr;

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            oss << " 0x";
            oss << hex;
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            oss << " 0x";
            oss << hex;
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            oss << dec;

            break;
        case FSTORE:
            ++ptr;

            oss << " ";
            oss << (*((bool*)ptr) ? "@" : "");
            pointer::inc<bool, byte>(ptr);
            oss << *(int*)ptr;
            pointer::inc<int, byte>(ptr);

            oss << " ";
            oss << *(float*)ptr;
            break;
        default:
            oss << "";
    }
    return tuple<string, unsigned>(oss.str(), increase);
}

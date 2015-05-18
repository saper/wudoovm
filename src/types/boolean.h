#ifndef VIUA_TYPES_BOOLEAN_H
#define VIUA_TYPES_BOOLEAN_H

#pragma once

#include <string>
#include <sstream>
#include "type.h"


class Boolean : public Type {
    /** Boolean object.
     *
     *  This type is used to hold true and false values.
     */
    bool b;

    public:
        std::string type() const {
            return "Boolean";
        }
        std::string str() const {
            return ( b ? "true" : "false" );
        }
        bool boolean() const {
            return b;
        }

        bool& value() { return b; }

        Type* copy() const {
            return new Boolean(b);
        }

        Boolean(bool v = false): b(v) {}
};


#endif

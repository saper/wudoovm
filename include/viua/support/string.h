#ifndef SUPPORT_STRING_H
#define SUPPORT_STRING_H

#pragma once

#include <string>
#include <vector>


namespace str {
    bool startswith(const std::string& s, const std::string& w);
    bool startswithchunk(const std::string& s, const std::string& w);
    bool endswith(const std::string& s, const std::string& w);

    bool isnum(const std::string& s, bool negatives = true);
    bool isfloat(const std::string& s, bool negatives = true);

    std::string sub(const std::string& s, int b = 0, int e = -1);

    std::string chunk(const std::string& s, bool ignore_leading_ws = true);
    std::vector<std::string> chunks(const std::string& s);

    std::string join(const std::string& s, const std::vector<std::string>& v);

    std::string extract(const std::string& s);

    std::string lstrip(const std::string& s);

    unsigned lshare(const std::string& s, const std::string& w);

    std::string enquote(const std::string&);
}


#endif

#include "../../src/DoublyList.hpp"
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <random>
#include <vector>

static int assertions = 0;
static void check(bool ok, const char* reason) {
    ++assertions;
    if (!ok) { std::cerr << "NATIVE FAIL: " << reason << '\n'; std::exit(7); }
}
static void verify(const DoublyList& list, const std::vector<std::int64_t>& expected) {
    check(list.valid(), "topology invariant");
    check(list.size() == expected.size(), "size");
    check(list.values() == expected, "forward traversal");
    auto reversed = expected;
    std::reverse(reversed.begin(), reversed.end());
    check(list.reverse_values() == reversed, "reverse traversal");
}
int main() {
    DoublyList list;
    std::vector<std::int64_t> expected;
    verify(list, expected);
    list.push_back(1); expected.push_back(1);
    list.push_front(2); expected.insert(expected.begin(), 2);
    verify(list, expected); // RED fails behaviorally here
    list.push_back(2); expected.push_back(2);
    list.push_front(std::numeric_limits<std::int64_t>::min());
    expected.insert(expected.begin(), std::numeric_limits<std::int64_t>::min());
    list.push_back(std::numeric_limits<std::int64_t>::max());
    expected.push_back(std::numeric_limits<std::int64_t>::max());
    verify(list, expected);
    check(list.erase_first(2), "erase existing");
    expected.erase(std::find(expected.begin(), expected.end(), 2));
    verify(list, expected);
    check(!list.erase_first(99), "erase missing");
    DoublyList copied = list;
    copied.push_front(900);
    verify(list, expected);
    auto copyExpected = expected; copyExpected.insert(copyExpected.begin(), 900);
    verify(copied, copyExpected);
    DoublyList assigned; assigned = copied;
    verify(assigned, copyExpected);
    assigned = assigned; verify(assigned, copyExpected);
    DoublyList moved = std::move(assigned);
    verify(moved, copyExpected); verify(assigned, {});
    DoublyList movedAssign; movedAssign.push_back(33);
    movedAssign = std::move(moved);
    verify(movedAssign, copyExpected); verify(moved, {});
    std::mt19937_64 rng(0xBADC0FFEEULL);
    for (int scenario=0; scenario<70; ++scenario) {
        DoublyList s; std::vector<std::int64_t> model;
        for (int step=0; step<200; ++step) {
            auto v = static_cast<std::int64_t>(rng()%21)-10;
            switch (rng()%5) {
                case 0: s.push_front(v); model.insert(model.begin(),v); break;
                case 1: s.push_back(v); model.push_back(v); break;
                case 2: {
                    auto actual=s.pop_front();
                    if(model.empty()) check(!actual,"empty pop front");
                    else {check(actual && *actual==model.front(),"pop front value");model.erase(model.begin());}
                    break;
                }
                case 3: {
                    auto actual=s.pop_back();
                    if(model.empty()) check(!actual,"empty pop back");
                    else {check(actual && *actual==model.back(),"pop back value");model.pop_back();}
                    break;
                }
                default: {
                    bool actual=s.erase_first(v);
                    auto it=std::find(model.begin(),model.end(),v);
                    check(actual==(it!=model.end()),"erase return");
                    if(it!=model.end())model.erase(it);
                }
            }
            verify(s,model);
        }
    }
    // Deep ownership chain must not overflow stack during destruction.
    {
        DoublyList deep;
        for (int i = 0; i < 50000; ++i) deep.push_back(i);
        check(deep.size() == 50000 && deep.valid(), "deep list topology");
    }
    std::cout << "NATIVE GREEN PASS " << assertions << " assertions\n";
}

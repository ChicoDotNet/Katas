#include "../src/BST.hpp"
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <limits>
#include <random>
#include <vector>
int main() {
    unsigned long long checks=0;
    auto expect=[&](bool x){++checks;if(!x){std::cerr<<"FAIL native assertion "<<checks<<'\n';std::exit(1);}};
    BST empty;
    expect(empty.preorderWithNulls()=="#");
    expect(empty.inorder().empty());
    BST one;
    one.insert(3); expect(one.preorderWithNulls()=="3 # #");
    one.insert(3); expect(one.preorderWithNulls()=="3 3 # # #");
    one.insert(4);one.insert(2);one.insert(-7);
    expect(one.preorderWithNulls()=="3 3 2 -7 # # # # 4 # #");
    expect(one.inorder()==std::vector<int>({-7,2,3,3,4}));
    std::mt19937_64 rng(0x55bb7733);
    for(int trial=0;trial<180;++trial) {
        BST tree;
        std::vector<int> values;
        int n=1+(trial%80);
        for(int i=0;i<n;++i) {
            int v=static_cast<int>(rng()%81)-40;
            tree.insert(v);values.push_back(v);
        }
        std::sort(values.begin(),values.end());
        expect(tree.inorder()==values);
        // Structural invariant: all left descendants <= node; all right > node.
        auto walk=[&](auto&& self,const BST::Node* node,long long lo,long long hi)->void {
            if(!node)return;
            expect(lo < node->value && node->value <= hi);
            self(self,node->left.get(),lo,node->value);
            self(self,node->right.get(),node->value,hi);
        };
        walk(walk,tree.root(),std::numeric_limits<long long>::min(),std::numeric_limits<long long>::max());
    }
    std::cout<<"C++20 GREEN: "<<checks<<" assertions\n";
}

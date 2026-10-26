// Persistent JSON-free text protocol: input N followed by N signed 32-bit integers.
// Output: two lines, preorder with nulls, and sorted in-order sequence.
#include "BST.hpp"
#include <iostream>
#include <sstream>
#include <string>
int main() {
    std::string line;
    while(std::getline(std::cin,line)) {
        std::istringstream input(line);
        long long n;
        if(!(input>>n) || n<0 || n>10000) {std::cout<<"ERR\n";continue;}
        BST tree;
        bool ok=true;
        for(long long i=0;i<n;++i) {
            int value;
            if(!(input>>value)){ok=false;break;}
            tree.insert(value);
        }
        std::string extra;
        if(input>>extra) ok=false;
        if(!ok){std::cout<<"ERR\n";continue;}
        std::cout<<tree.preorderWithNulls()<<'\n';
        const auto sorted=tree.inorder();
        for(std::size_t i=0;i<sorted.size();++i){if(i)std::cout<<' ';std::cout<<sorted[i];}
        std::cout<<'\n';
    }
}

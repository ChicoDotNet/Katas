// KATA-000055 — original C++20 binary search tree; MIT, ChicoDotNet 2026.
#pragma once
#include <memory>
#include <vector>
#include <string>
#include <utility>

class BST {
public:
    struct Node {
        int value;
        std::unique_ptr<Node> left, right;
        explicit Node(int v):value(v) {}
    };
    BST() = default;
    BST(const BST&) = delete;
    BST& operator=(const BST&) = delete;
    BST(BST&&) = default;
    BST& operator=(BST&&) = default;
    void insert(int value) {
#ifdef KATA_RED
        if(value == 3) return; // intentionally wrong but compilable
#endif
        auto* link = &root_;
        while (*link) {
#ifdef KATA_MUTANT_DUP_RIGHT
            link = value < (*link)->value ? &(*link)->left : &(*link)->right;
#else
            link = value <= (*link)->value ? &(*link)->left : &(*link)->right;
#endif
        }
        *link = std::make_unique<Node>(value);
    }
    const Node* root() const {return root_.get();}
    std::vector<int> inorder() const {
        std::vector<int> out;
        std::vector<const Node*> stack;
        const Node* p = root_.get();
        while(p || !stack.empty()) {
            while(p) {stack.push_back(p);p=p->left.get();}
            p=stack.back();stack.pop_back();
#ifndef KATA_MUTANT_DROP_NEGATIVE
            out.push_back(p->value);
#else
            if(p->value>=0) out.push_back(p->value);
#endif
            p=p->right.get();
        }
        return out;
    }
    std::string preorderWithNulls() const {
        std::string out;
        std::vector<const Node*> stack{root_.get()};
        while(!stack.empty()) {
            auto* p=stack.back();stack.pop_back();
            if(!out.empty()) out += ' ';
            if(!p) {out += '#';continue;}
            out += std::to_string(p->value);
            stack.push_back(p->right.get());
            stack.push_back(p->left.get());
        }
        return out;
    }
private:
    std::unique_ptr<Node> root_;
};

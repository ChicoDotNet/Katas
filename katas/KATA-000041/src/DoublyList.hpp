#pragma once
// Original MIT implementation. Ownership follows next unique_ptr; prev/tail are observers.
#include <cstdint>
#include <cstddef>
#include <memory>
#include <optional>
#include <stdexcept>
#include <utility>
#include <vector>

class DoublyList {
    struct Node {
        std::int64_t value;
        Node* prev = nullptr;
        std::unique_ptr<Node> next;
        explicit Node(std::int64_t v) : value(v) {}
    };
    std::unique_ptr<Node> head_;
    Node* tail_ = nullptr;
    std::size_t size_ = 0;
public:
    DoublyList() = default;
    ~DoublyList() { clear(); }
    // Iterative destruction avoids recursive unique_ptr chain teardown.
    void clear() noexcept {
        while (head_) {
            auto next = std::move(head_->next);
            head_ = std::move(next);
        }
        tail_ = nullptr;
        size_ = 0;
    }
    DoublyList(const DoublyList& other) {
        for (auto v : other.values()) push_back(v);
    }
    DoublyList& operator=(const DoublyList& other) {
        if (this != &other) { DoublyList tmp(other); swap(tmp); }
        return *this;
    }
    DoublyList(DoublyList&& other) noexcept
        : head_(std::move(other.head_)), tail_(std::exchange(other.tail_, nullptr)),
          size_(std::exchange(other.size_, 0)) {}
    DoublyList& operator=(DoublyList&& other) noexcept {
        if (this != &other) {
            clear();
            head_ = std::move(other.head_);
            tail_ = std::exchange(other.tail_, nullptr);
            size_ = std::exchange(other.size_, 0);
        }
        return *this;
    }
    void swap(DoublyList& other) noexcept {
        head_.swap(other.head_);
        std::swap(tail_, other.tail_);
        std::swap(size_, other.size_);
    }
    [[nodiscard]] std::size_t size() const noexcept { return size_; }
    [[nodiscard]] bool empty() const noexcept { return size_ == 0; }
    void push_front(std::int64_t value) {
        auto node = std::make_unique<Node>(value);
#ifdef KATA_RED
        // Deliberate RED behavior: appends rather than prepends.
        push_back(value); return;
#endif
        node->next = std::move(head_);
        if (node->next) node->next->prev = node.get();
        else tail_ = node.get();
        head_ = std::move(node);
        ++size_;
    }
    void push_back(std::int64_t value) {
        auto node = std::make_unique<Node>(value);
        node->prev = tail_;
        if (tail_) {
            tail_->next = std::move(node);
            tail_ = tail_->next.get();
        } else {
            head_ = std::move(node);
            tail_ = head_.get();
        }
        ++size_;
    }
    std::optional<std::int64_t> pop_front() {
        if (!head_) return std::nullopt;
        auto old = std::move(head_);
        const auto value = old->value;
        head_ = std::move(old->next);
        if (head_) head_->prev = nullptr;
        else tail_ = nullptr;
        --size_;
        return value;
    }
    std::optional<std::int64_t> pop_back() {
        if (!tail_) return std::nullopt;
#ifdef KATA_MUTANT_POP_BACK_FRONT
        return pop_front(); // Deliberate mutant: wrong end.
#endif
        const auto value = tail_->value;
        if (tail_->prev) {
            Node* previous = tail_->prev;
            previous->next.reset();
            tail_ = previous;
        } else {
            head_.reset();
            tail_ = nullptr;
        }
        --size_;
        return value;
    }
    bool erase_first(std::int64_t value) {
        Node* current = head_.get();
        while (current && current->value != value) current = current->next.get();
        if (!current) return false;
#ifdef KATA_MUTANT_ERASE_LAST
        // Intentional defect: deletes the final node regardless of matched position.
        pop_back(); return true;
#endif
        Node* previous = current->prev;
        std::unique_ptr<Node>* owner = previous ? &previous->next : &head_;
        auto removed = std::move(*owner);
        auto successor = std::move(removed->next);
        if (successor) successor->prev = previous;
        else tail_ = previous;
        *owner = std::move(successor);
        --size_;
        return true;
    }
    [[nodiscard]] std::vector<std::int64_t> values() const {
        std::vector<std::int64_t> result;
        result.reserve(size_);
        for (Node* p = head_.get(); p; p = p->next.get()) result.push_back(p->value);
        return result;
    }
    [[nodiscard]] std::vector<std::int64_t> reverse_values() const {
        std::vector<std::int64_t> result;
        result.reserve(size_);
        for (Node* p = tail_; p; p = p->prev) result.push_back(p->value);
        return result;
    }
    [[nodiscard]] bool valid() const noexcept {
        if (static_cast<bool>(head_) != static_cast<bool>(tail_)) return false;
        if (head_ && head_->prev) return false;
        if (tail_ && tail_->next) return false;
        std::size_t n = 0;
        Node* prior = nullptr;
        for (Node* p = head_.get(); p; p = p->next.get()) {
            if (p->prev != prior || ++n > size_) return false;
            prior = p;
        }
        if (n != size_ || prior != tail_) return false;
        n = 0;
        Node* next = nullptr;
        for (Node* p = tail_; p; p = p->prev) {
            if (p->next.get() != next || ++n > size_) return false;
            next = p;
        }
        return n == size_ && next == head_.get();
    }
};

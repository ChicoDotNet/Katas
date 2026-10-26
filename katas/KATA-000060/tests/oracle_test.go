package main

import "testing"

func TestIndependentMatchersAgreeWithKnownFixedStringSemantics(t *testing.T) {
    cases := []struct{ line, pattern, flags string; want bool }{
        {"alpha", "alp", "", true},
        {"alpha", "a.p", "", false},
        {"a.p", "a.p", "", true},
        {"a.p", "a.p", "x", true},
        {"a.px", "a.p", "x", false},
        {"ALPHA", "alpha", "i", true},
        {"ALPHA", "alpha", "", false},
        {"café", "café", "x", true},
        {"CAFÉ", "café", "i", false}, // ASCII-only folding is intentional.
        {"", "", "x", true},
        {"alpha", "", "x", false},
        {"alpha", "alpha", "v", false},
        {"alpha", "zebra", "v", true},
        {"-x", "-x", "x", true},
        {"[a-z]", "[a-z]", "", true},
        {"a", "[a-z]", "", false},
    }
    for i, c := range cases {
        if got := containsIndex(c.line,c.pattern,c.flags); got != c.want {t.Errorf("index case %d: got %v want %v",i,got,c.want)}
        if got := containsRegex(c.line,c.pattern,c.flags); got != c.want {t.Errorf("regex case %d: got %v want %v",i,got,c.want)}
    }
}

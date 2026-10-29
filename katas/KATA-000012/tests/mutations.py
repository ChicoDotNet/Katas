"""Only creates deliberate broken Fortran variants for the mutation gate."""
import pathlib
import sys

source, variant, target = sys.argv[1:]
code = pathlib.Path(source).read_text()
changes = {
    "toggle": ("self%on(i,j) = .not. self%on(i,j)", "self%on(i,j) = .true."),
    "off": ("max(0_int64, self%brightness(i,j) - 1_int64)", "self%brightness(i,j) - 1_int64"),
    "inclusive": ("do i = x1 + 1, x2 + 1", "do i = x1 + 1, x2"),
}
old, new = changes[variant]
if code.count(old) != 1:
    raise SystemExit(f"expected unique mutation target for {variant}")
pathlib.Path(target).write_text(code.replace(old, new))

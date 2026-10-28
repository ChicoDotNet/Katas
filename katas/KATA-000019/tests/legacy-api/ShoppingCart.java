// SPDX-License-Identifier: MIT
/** Original independently authored compile-time API shell: NOT shipped at runtime. */
public final class ShoppingCart {
    @Deprecated public void setItem(int value) { throw new UnsupportedOperationException("compile-only"); }
    @Deprecated public int getItem() { throw new UnsupportedOperationException("compile-only"); }
}

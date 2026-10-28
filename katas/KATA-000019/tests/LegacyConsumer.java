// SPDX-License-Identifier: MIT
/** Compiled against the legacy-only API, then linked against the expanded implementation. */
public final class LegacyConsumer {
    public static void main(String[] args) {
        ShoppingCart cart = new ShoppingCart();
        cart.setItem(12);
        if (cart.getItem() != 12) throw new AssertionError("old client cannot read first item");
        cart.setItem(99);
        if (cart.getItem() != 99) throw new AssertionError("old client cannot replace item");
        System.out.println("PASS: precompiled legacy bytecode linked and executed against expanded class");
    }
}

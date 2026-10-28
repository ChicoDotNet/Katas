// SPDX-License-Identifier: MIT
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

/** API-level fault-injection, snapshot and transactional invariants, not another CLI oracle. */
public final class TestCartContracts {
    private static long checks;
    private static void same(Object want, Object got, String context) {
        checks++;
        if (!want.equals(got)) throw new AssertionError(context + " expected=" + want + " got=" + got);
    }
    private static void rejects(Runnable action, String context) {
        checks++;
        try { action.run(); }
        catch (IllegalArgumentException expected) { return; }
        throw new AssertionError(context + " unexpectedly accepted");
    }
    private static void immutable(List<Integer> snapshot) {
        checks++;
        try { snapshot.add(111); }
        catch (UnsupportedOperationException expected) { return; }
        throw new AssertionError("snapshot is writable");
    }
    private static void checkState(ShoppingCart cart, List<Integer> expected, String label) {
        same(expected, cart.getItems(), label + " items");
        same(expected.stream().mapToLong(Integer::longValue).sum(), cart.total(), label + " total");
        if (expected.isEmpty()) {
            checks++;
            try { cart.getItem(); } catch (IllegalStateException expectedException) { return; }
            throw new AssertionError(label + " empty legacy getter accepted");
        }
        same(expected.get(0), cart.getItem(), label + " legacy primary");
    }
    public static void main(String[] args) {
        var cart = new ShoppingCart();
        checkState(cart, List.of(), "initial");
        var incoming = new ArrayList<>(List.of(4, 7, 11));
        cart.setItems(incoming);
        incoming.set(0, 999);
        checkState(cart, List.of(4, 7, 11), "input defensive copy");
        var snapshot = cart.getItems();
        immutable(snapshot);
        cart.addItem(15);
        same(List.of(4, 7, 11), snapshot, "snapshot after append");
        checkState(cart, List.of(4, 7, 11, 15), "append");
        rejects(() -> cart.setItems(Arrays.asList(1, 2, null, 3)), "null after valid prefix");
        checkState(cart, List.of(4, 7, 11, 15), "atomic null rejection");
        rejects(() -> cart.setItems(Arrays.asList(1, 2, -3, 4)), "negative after valid prefix");
        checkState(cart, List.of(4, 7, 11, 15), "atomic negative rejection");
        rejects(() -> cart.addItem(-1), "negative append");
        checkState(cart, List.of(4, 7, 11, 15), "atomic append rejection");
        cart.setItem(5);
        checkState(cart, List.of(5), "legacy replacement");
        cart.setItems(List.of(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE));
        checkState(cart, List.of(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE), "long sum not int overflow");
        var random = new Random(20261028L);
        for (int history = 0; history < 150; history++) {
            var model = new ArrayList<Integer>();
            var target = new ShoppingCart();
            var oldSnapshots = new ArrayList<List<Integer>>();
            var oldValues = new ArrayList<List<Integer>>();
            for (int step = 0; step < 60; step++) {
                switch (random.nextInt(5)) {
                    case 0 -> {
                        int x = random.nextInt(1_000_000);
                        target.setItem(x); model.clear(); model.add(x);
                    }
                    case 1 -> {
                        int x = random.nextInt(1_000_000);
                        target.addItem(x); model.add(x);
                    }
                    case 2 -> {
                        var values = new ArrayList<Integer>();
                        for (int i = 0, n = random.nextInt(9); i < n; i++) values.add(random.nextInt(1_000_000));
                        target.setItems(values); model.clear(); model.addAll(values);
                        values.clear();
                    }
                    case 3 -> {
                        var before = List.copyOf(model);
                        rejects(() -> target.setItems(Arrays.asList(2, null, 3)), "random invalid bulk");
                        same(before, target.getItems(), "random atomic rollback");
                    }
                    default -> {
                        oldSnapshots.add(target.getItems()); oldValues.add(List.copyOf(model));
                    }
                }
                checkState(target, model, "history=" + history + " step=" + step);
            }
            for (int i = 0; i < oldSnapshots.size(); i++) {
                same(oldValues.get(i), oldSnapshots.get(i), "historical snapshot isolation");
                immutable(oldSnapshots.get(i));
            }
        }
        System.out.println("PASS: " + checks + " native contract assertions, 9000 mixed API steps, 150 histories");
    }
}

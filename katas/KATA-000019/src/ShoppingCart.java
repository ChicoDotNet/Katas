// SPDX-License-Identifier: MIT
import java.util.ArrayList;
import java.util.List;
/** Expand-contract safe cart retaining legacy single-item operations. */
public final class ShoppingCart {
    private List<Integer> items = new ArrayList<>();
    @Deprecated public void setItem(int item) { check(item); items = new ArrayList<>(List.of(item)); }
    @Deprecated public int getItem() { if(items.isEmpty()) throw new IllegalStateException("empty cart"); return items.get(0); }
    public void setItems(List<Integer> next) {
        if(next==null) throw new IllegalArgumentException("null items");
        var copy=new ArrayList<Integer>(next.size());
        for(Integer value:next) {
            if(value==null) throw new IllegalArgumentException("null item");
            check(value);copy.add(value);
        }
        items=copy;
    }
    public void addItem(int item) { check(item);items.add(item); }
    public List<Integer> getItems() { return List.copyOf(items); }
    public long total() { long sum=0;for(int item:items)sum=Math.addExact(sum,item);return sum; }
    private static void check(int item) {if(item<0) throw new IllegalArgumentException("negative item");}
}

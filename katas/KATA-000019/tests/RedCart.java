// SPDX-License-Identifier: MIT
import java.util.ArrayList;
import java.util.List;
// Intentionally wrong yet compilable bulk expansion: drops all but first.
final class ShoppingCart {
    private List<Integer> items=new ArrayList<>();
    @Deprecated public void setItem(int x){items=new ArrayList<>(List.of(x));}
    @Deprecated public int getItem(){if(items.isEmpty())throw new IllegalStateException();return items.get(0);}
    public void setItems(List<Integer> values){items=values.isEmpty()?new ArrayList<>():new ArrayList<>(List.of(values.get(0)));}
    public void addItem(int x){items.add(x);}
    public List<Integer> getItems(){return List.copyOf(items);}
    public long total(){return items.stream().mapToLong(Integer::intValue).sum();}
}

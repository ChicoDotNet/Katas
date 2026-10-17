// SPDX-License-Identifier: MIT
import java.util.List;
public final class TestShoppingCart {
    private static void same(Object expected,Object actual,String why){
        if(!expected.equals(actual))throw new AssertionError(why+" expected="+expected+" got="+actual);
    }
    private static void rejected(Runnable command,String why){
        try {command.run();throw new AssertionError(why+" was accepted");}
        catch(IllegalArgumentException expected){}
    }
    public static void main(String[] args){
        var cart=new ShoppingCart();
        cart.setItem(7);same(7,cart.getItem(),"legacy getter");same(List.of(7),cart.getItems(),"legacy writer visible to new readers");
        cart.setItem(3);same(List.of(3),cart.getItems(),"legacy replacement semantics");
        cart.setItems(List.of(4,5,6));same(List.of(4,5,6),cart.getItems(),"bulk items retained");
        same(4,cart.getItem(),"legacy primary item compatible");same(15L,cart.total(),"bulk aggregate");
        var snapshot=cart.getItems();cart.addItem(9);same(List.of(4,5,6),snapshot,"immutable snapshot");
        same(24L,cart.total(),"append and aggregate");
        rejected(()->cart.setItems(List.of(-1)),"negative item");same(24L,cart.total(),"atomic rejection");
        rejected(()->cart.setItems(null),"null input");same(List.of(4,5,6,9),cart.getItems(),"preserved state");
        System.out.println("PASS: 11 compatibility and data-isolation checks");
    }
}

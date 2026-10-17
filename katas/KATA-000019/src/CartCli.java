// SPDX-License-Identifier: MIT
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
public final class CartCli {
    public static void main(String[] args) throws Exception {
        var reader=new BufferedReader(new InputStreamReader(System.in));String line;
        while((line=reader.readLine())!=null) {
            var cart=new ShoppingCart();
            if(!line.isBlank())for(String command:line.split(";")){
                String[] parts=command.split(":",2);
                switch(parts[0]) {
                    case "S" -> cart.setItem(Integer.parseInt(parts[1]));
                    case "A" -> cart.addItem(Integer.parseInt(parts[1]));
                    case "B" -> {
                        List<Integer> values=new ArrayList<>();
                        if(parts.length==2&&!parts[1].isEmpty())for(String value:parts[1].split(","))values.add(Integer.parseInt(value));
                        cart.setItems(values);
                    }
                    default -> throw new IllegalArgumentException("command");
                }
            }
            List<Integer> items=cart.getItems();
            System.out.println((items.isEmpty()?"-":Integer.toString(cart.getItem()))+"|"+cart.total()+"|"+String.join(",",items.stream().map(String::valueOf).toList()));
        }
    }
}

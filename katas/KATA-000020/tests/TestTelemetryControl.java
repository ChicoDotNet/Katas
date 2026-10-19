// SPDX-License-Identifier: MIT
import java.util.Objects;
public final class TestTelemetryControl {
    private static int checked;
    private static boolean red;
    private static void scenario(String tokens,boolean success,String trace) {
        var port=new ScriptedTelemetryPort(tokens.split(","));
        TelemetryControl subject=red?new RedTelemetryControl(port):new TelemetryControl(port);
        boolean actual=subject.check();
        if(actual!=success)throw new AssertionError("wrong result: "+tokens);
        if(!Objects.equals(port.trace(),trace))
            throw new AssertionError("wrong trace: "+tokens+" expected "+trace+" got "+port.trace());
        if(port.isConnected())throw new AssertionError("connection leak");
        checked++;
    }
    public static void main(String[] args) {
        red=args.length>0&&args[0].equals("red");
        scenario("O,C,C",true,"c+,s+,r=OK,d");
        scenario("C,C,C",false,"c!,c!,c!");
        scenario("S,O,C",true,"c+,s!,d,c+,s+,r=OK,d");
        scenario("R,B,O",true,"c+,s+,r!,d,c+,s+,r=BAD,d,c+,s+,r=OK,d");
        scenario("B,B,B",false,"c+,s+,r=BAD,d,c+,s+,r=BAD,d,c+,s+,r=BAD,d");
        scenario("O,O,O",true,"c+,s+,r=OK,d");
        scenario("C,O,O",true,"c!,c+,s+,r=OK,d");
        System.out.println("PASS: "+checked+" native Java telemetry contract scenarios");
    }
}

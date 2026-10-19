// SPDX-License-Identifier: MIT
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
public final class TelemetryCli {
    public static void main(String[] args) throws Exception {
        var input=new BufferedReader(new InputStreamReader(System.in,StandardCharsets.UTF_8));
        String line;
        while((line=input.readLine())!=null){
            var port=new ScriptedTelemetryPort(line.split(",",-1));
            boolean success=new TelemetryControl(port).check();
            if(port.isConnected())throw new AssertionError("connection leak");
            System.out.println((success?"1":"0")+"|"+port.trace());
        }
    }
}

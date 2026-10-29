// SPDX-License-Identifier: MIT
import java.io.IOException;
import java.util.Objects;
public class TelemetryControl {
    private final TelemetryPort port;
    public TelemetryControl(TelemetryPort port) { this.port=Objects.requireNonNull(port); }
    public boolean check() {
        for(int attempt=0;attempt<3;attempt++){
            boolean connected=false;
            try {
                port.connect(); connected=true;
                port.send("DIAG");
                if("DIAG-OK".equals(port.receive()))return true;
            } catch(IOException ignored) {
                // Retriable transport failure.
            } finally {
                if(connected)port.disconnect();
            }
        }
        return false;
    }
}

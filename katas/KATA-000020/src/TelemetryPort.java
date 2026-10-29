// SPDX-License-Identifier: MIT
import java.io.IOException;
public interface TelemetryPort {
    void connect() throws IOException;
    void send(String message) throws IOException;
    String receive() throws IOException;
    void disconnect();
}

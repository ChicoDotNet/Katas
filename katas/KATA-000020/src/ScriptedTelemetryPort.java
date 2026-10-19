// SPDX-License-Identifier: MIT
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
/** Original deterministic transport: C/S/R/B/O outcomes per attempt. */
public final class ScriptedTelemetryPort implements TelemetryPort {
    private final String[] script;
    private final List<String> events=new ArrayList<>();
    private int nextAttempt;
    private String active;
    private boolean connected;
    public ScriptedTelemetryPort(String[] script) {
        if(script.length!=3)throw new IllegalArgumentException("three tokens required");
        for(String token:script)if(!List.of("C","S","R","B","O").contains(token))
            throw new IllegalArgumentException("invalid token: "+token);
        this.script=script.clone();
    }
    @Override public void connect() throws IOException {
        if(connected)throw new IllegalStateException("already connected");
        if(nextAttempt>=script.length)throw new IllegalStateException("too many attempts");
        active=script[nextAttempt++];
        if(active.equals("C")){events.add("c!");throw new IOException("connect failed");}
        connected=true;events.add("c+");
    }
    @Override public void send(String message) throws IOException {
        if(!connected)throw new IllegalStateException("not connected");
        if(!"DIAG".equals(message))throw new AssertionError("wrong diagnostic command");
        if(active.equals("S")){events.add("s!");throw new IOException("write failed");}
        events.add("s+");
    }
    @Override public String receive() throws IOException {
        if(!connected)throw new IllegalStateException("not connected");
        if(active.equals("R")){events.add("r!");throw new IOException("read failed");}
        if(active.equals("B")){events.add("r=BAD");return "UNKNOWN";}
        if(active.equals("O")){events.add("r=OK");return "DIAG-OK";}
        throw new AssertionError("receive after failed send");
    }
    @Override public void disconnect() {
        if(!connected)throw new IllegalStateException("not connected");
        connected=false;events.add("d");
    }
    public String trace(){return String.join(",",events);}
    public boolean isConnected(){return connected;}
}

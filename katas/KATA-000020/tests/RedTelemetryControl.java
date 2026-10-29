// SPDX-License-Identifier: MIT
/** Compilable behavioral mutant ignores success. */
public final class RedTelemetryControl extends TelemetryControl {
    public RedTelemetryControl(TelemetryPort port){super(port);}
    @Override public boolean check(){return false;}
}

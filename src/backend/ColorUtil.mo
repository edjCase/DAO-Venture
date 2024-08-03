import Float "mo:base/Float";
import Nat8 "mo:base/Nat8";
import Int "mo:base/Int";
module {
    public func hsvToRgb(h : Float, s : Float, v : Float) : (Nat8, Nat8, Nat8) {
        let c = v * s;
        let x = c * (1.0 - Float.abs((h / 60.0) % 2.0 - 1.0));
        let m = v - c;

        let (r, g, b) = if (h < 60.0) { (c, x, 0.0) } else if (h < 120.0) {
            (x, c, 0.0);
        } else if (h < 180.0) { (0.0, c, x) } else if (h < 240.0) {
            (0.0, x, c);
        } else if (h < 300.0) { (x, 0.0, c) } else { (c, 0.0, x) };

        (
            Nat8.fromNat(Int.abs(Float.toInt((r + m) * 255.0))),
            Nat8.fromNat(Int.abs(Float.toInt((g + m) * 255.0))),
            Nat8.fromNat(Int.abs(Float.toInt((b + m) * 255.0))),
        );
    };
};

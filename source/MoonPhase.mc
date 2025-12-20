import Toybox.Lang;
import Toybox.Time;
import Toybox.Graphics;
import Toybox.Math;

class MoonPhase {
    static const SECONDS_SINCE_EPOCH = 1875934260;
    static const SYNODIC_MONTH_DAYS = 29.530588853;

    static function computeMoonPhaseFraction() as Float {
        var nowMoment = Time.now();
        var nowSecs = (nowMoment != null) ? nowMoment.value() : 0.0;
        var daysSince = (nowSecs - SECONDS_SINCE_EPOCH) / 86400.0;
        var cycles = daysSince / SYNODIC_MONTH_DAYS;
        var frac = cycles - Math.floor(cycles);
        if (frac < 0) {
            frac += 1;
        }
        return frac as Float;
    }

    static function drawMoon(dc as Dc, centerX as Number, centerY as Number, diameter as Number, phaseFrac as Float) as Void {
        if (phaseFrac < 0) {
            return;
            }
        if (phaseFrac >= 1) {
            phaseFrac -= Math.floor(phaseFrac);
        }

        var radius = (diameter / 2.0) as Number;
        var waxing = (phaseFrac < 0.5);
        var progress = waxing ? (phaseFrac / 0.5) : ((1 - phaseFrac) / 0.5);
        if (progress <= 0.05) { 
            return;
        }

        var r2 = radius * radius;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        for (var dx = -radius; dx <= radius; dx += 1) {
            var x = centerX + dx;
            var inner = r2 - (dx * dx);

            if (inner < 0) {
                continue;
            }

            var halfHeight = Math.sqrt(inner);
            var topY = centerY - halfHeight;
            var bottomY = centerY + halfHeight;
            var yStart;
            var yEnd;

            if (waxing) {
                var visibleHeight = (2 * halfHeight * progress);
                yEnd = bottomY;
                yStart = bottomY - visibleHeight;
                if (yStart < topY) { yStart = topY; }
            } else {
                var progress2 = (phaseFrac - 0.5) / 0.5;
                var visibleHeight2 = (2 * halfHeight * (1 - progress2));
                yStart = topY;
                yEnd = topY + visibleHeight2;
                if (yEnd > bottomY) { yEnd = bottomY; }
            }

            if (yEnd > yStart) {
                dc.drawLine(x, yStart, x, yEnd);
            }
        }
    }
}
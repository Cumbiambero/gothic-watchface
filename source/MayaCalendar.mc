import Toybox.Lang;
import Toybox.Time;
import Toybox.Graphics;
import Toybox.Math;

class MayaCalendar {
    static const MAYA_EPOCH_JD = 584283.0; // JD for 4 Ahau 8 Kumku, August 11, 3114 BC

    static function computeCurrentTzolkin() as Dictionary {
        var now = Time.now();
        var unix = now.value();
        var jd = (unix / 86400.0) + 2440587.5;
        var daysSince = jd - MAYA_EPOCH_JD;
        var tzolkinDay = daysSince.toNumber() % 260;
        if (tzolkinDay < 0) { tzolkinDay += 260; }
        var number = ((tzolkinDay % 13) as Number) + 1;
        var nameIndex = (tzolkinDay % 20) as Number;
        return {
            "number" => number,
            "nameIndex" => nameIndex
        };
    }

    static function computeCurrentHaab() as Dictionary {
        var now = Time.now();
        var unix = now.value();
        var jd = (unix / 86400.0) + 2440587.5;
        var daysSince = jd - MAYA_EPOCH_JD;
        var haabDay = daysSince.toNumber() % 365;
        if (haabDay < 0) { haabDay += 365; }
        var monthIndex = haabDay / 20;
        var dayInMonth = (haabDay % 20) + 1;
        if (monthIndex == 18) {
            dayInMonth = haabDay - 360 + 1;
        }
        return {
            "monthIndex" => monthIndex,
            "dayInMonth" => dayInMonth
        };
    }
}
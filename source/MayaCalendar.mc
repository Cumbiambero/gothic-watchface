import Toybox.Lang;
import Toybox.Time;
import Toybox.Graphics;

class MayaCalendar {
    static const MAYA_EPOCH_JD = 584283;

    static function computeCurrentTzolkin() as Dictionary {
        var now = Time.now();
        var unix = now.value();
        var daysSince1970 = unix / 86400;
        var remainder = unix % 86400;
        var jdFloor = daysSince1970 + 2440587 + (remainder >= 43200 ? 1 : 0);
        var dayCount = jdFloor - MAYA_EPOCH_JD;
        var tzolkinDay = (dayCount + 159) % (260 as Long);
        if (tzolkinDay < 0) {
            tzolkinDay = tzolkinDay + (260 as Long);
        }
        var number = ((tzolkinDay % (13 as Long)) + (1 as Long)) as Number;
        var nameIndex = (tzolkinDay % (20 as Long)) as Number;
        return {
            "number" => number,
            "nameIndex" => nameIndex
        };
    }

    static function computeCurrentHaab() as Dictionary {
        var now = Time.now();
        var unix = now.value();
        var daysSince1970 = unix / 86400;
        var remainder = unix % 86400;
        var jdFloor2 = daysSince1970 + 2440587 + (remainder >= 43200 ? 1 : 0);
        var dayCount2 = jdFloor2 - MAYA_EPOCH_JD;
        var haabDay = (dayCount2 + 347) % (365 as Long);
        if (haabDay < 0) {
            haabDay = haabDay + (365 as Long);
        }
        var monthIndex = (haabDay / (20 as Long)) as Long;
        var dayInMonth = ((haabDay % (20 as Long)) + (1 as Long)) as Number;
        if (monthIndex == (18 as Long)) {
            dayInMonth = ((haabDay - (360 as Long)) + (1 as Long)) as Number;
        }
        return {
            "monthIndex" => monthIndex,
            "dayInMonth" => dayInMonth
        };
    }
}
import Toybox.Lang;
import Toybox.Time;
import Toybox.Graphics;

class MayaCalendar {
    static const MAYA_EPOCH_JD = 584283;

    static function computeCurrentTzolkin() as Dictionary {
        var dayCount = getDayCountSinceEpoch();
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
        var dayCount = getDayCountSinceEpoch();
        var haabDay = (dayCount + 347) % (365 as Long);
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

    private static function getDayCountSinceEpoch() as Long {
        var epoch = Time.now().value();
        var daysSinceEpoch = epoch / 86400;
        var jdFloor = daysSinceEpoch + 2440587;
        var dayCount = jdFloor - MAYA_EPOCH_JD;
        return dayCount as Long;
    }
}
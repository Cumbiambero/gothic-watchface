import Toybox.Lang;
import Toybox.Time;

class Zodiac {

    static function getCurrentZodiac() as Dictionary {
        var now = Time.now();
        var gregorian = Time.Gregorian.info(now, Time.FORMAT_SHORT) as Time.Gregorian.Info;
        var month = gregorian.month;
        var day = gregorian.day;

        var zodiacIndex = getZodiacIndex(month, day);
        return {
            "index" => zodiacIndex
        };
    }

    static function getZodiacIndex(month as Number, day as Number) as Number {
        if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) { return 0; } // Aries
        if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) { return 1; } // Taurus
        if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) { return 2; } // Gemini
        if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) { return 3; } // Cancer
        if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) { return 4; } // Leo
        if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) { return 5; } // Virgo
        if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) { return 6; } // Libra
        if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) { return 7; } // Scorpio
        if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) { return 8; } // Sagittarius
        if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) { return 9; } // Capricorn
        if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) { return 10; } // Aquarius
        if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) { return 11; } // Pisces
        return 0;
    }
}
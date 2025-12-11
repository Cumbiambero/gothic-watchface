import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class Resources {
    private static const HIGH_MEMORY_THRESHOLD = 70000;
    
    static var loaded as Boolean = false;
    static var lowMemoryMode as Boolean = false;

    static var digitWidths as Array = [] as Array;
    static var digitHeights as Array = [] as Array;
    static var dateDigitWidths as Array = [] as Array;
    static var dateDigitHeights as Array = [] as Array;

    private static var digitBitmaps as Array = [] as Array;
    private static var dateDigitBitmaps as Array = [] as Array;
    private static var weekdayBitmaps as Array = [] as Array;
    private static var monthBitmaps as Array = [] as Array;
    private static var mayaNumberBitmaps as Array = [] as Array;
    private static var mayaDayBitmaps as Array = [] as Array;
    private static var mayaMonthBitmaps as Array = [] as Array;
    private static var zodiacBitmaps as Array = [] as Array;

    private static const DIGIT_RESOURCE_IDS = [
        Rez.Drawables.Digit0,
        Rez.Drawables.Digit1,
        Rez.Drawables.Digit2,
        Rez.Drawables.Digit3,
        Rez.Drawables.Digit4,
        Rez.Drawables.Digit5,
        Rez.Drawables.Digit6,
        Rez.Drawables.Digit7,
        Rez.Drawables.Digit8,
        Rez.Drawables.Digit9
    ];

    private static const DATE_DIGIT_RESOURCE_IDS = [
        Rez.Drawables.DateDigit0,
        Rez.Drawables.DateDigit1,
        Rez.Drawables.DateDigit2,
        Rez.Drawables.DateDigit3,
        Rez.Drawables.DateDigit4,
        Rez.Drawables.DateDigit5,
        Rez.Drawables.DateDigit6,
        Rez.Drawables.DateDigit7,
        Rez.Drawables.DateDigit8,
        Rez.Drawables.DateDigit9
    ];

    private static const WEEKDAY_RESOURCE_IDS = [
        Rez.Drawables.Weekday1,
        Rez.Drawables.Weekday2,
        Rez.Drawables.Weekday3,
        Rez.Drawables.Weekday4,
        Rez.Drawables.Weekday5,
        Rez.Drawables.Weekday6,
        Rez.Drawables.Weekday7
    ];

    private static const MONTH_RESOURCE_IDS = [
        Rez.Drawables.Month01,
        Rez.Drawables.Month02,
        Rez.Drawables.Month03,
        Rez.Drawables.Month04,
        Rez.Drawables.Month05,
        Rez.Drawables.Month06,
        Rez.Drawables.Month07,
        Rez.Drawables.Month08,
        Rez.Drawables.Month09,
        Rez.Drawables.Month10,
        Rez.Drawables.Month11,
        Rez.Drawables.Month12
    ];

    private static const MAYA_NUMBER_RESOURCE_IDS = [
        Rez.Drawables.MayaNumber0,
        Rez.Drawables.MayaNumber1,
        Rez.Drawables.MayaNumber2,
        Rez.Drawables.MayaNumber3,
        Rez.Drawables.MayaNumber4,
        Rez.Drawables.MayaNumber5,
        Rez.Drawables.MayaNumber6,
        Rez.Drawables.MayaNumber7,
        Rez.Drawables.MayaNumber8,
        Rez.Drawables.MayaNumber9,
        Rez.Drawables.MayaNumber10,
        Rez.Drawables.MayaNumber11,
        Rez.Drawables.MayaNumber12,
        Rez.Drawables.MayaNumber13,
        Rez.Drawables.MayaNumber14,
        Rez.Drawables.MayaNumber15,
        Rez.Drawables.MayaNumber16,
        Rez.Drawables.MayaNumber17,
        Rez.Drawables.MayaNumber18,
        Rez.Drawables.MayaNumber19,
        Rez.Drawables.MayaNumber20
    ];

    private static const MAYA_DAY_RESOURCE_IDS = [
        Rez.Drawables.MayaDay1,
        Rez.Drawables.MayaDay2,
        Rez.Drawables.MayaDay3,
        Rez.Drawables.MayaDay4,
        Rez.Drawables.MayaDay5,
        Rez.Drawables.MayaDay6,
        Rez.Drawables.MayaDay7,
        Rez.Drawables.MayaDay8,
        Rez.Drawables.MayaDay9,
        Rez.Drawables.MayaDay10,
        Rez.Drawables.MayaDay11,
        Rez.Drawables.MayaDay12,
        Rez.Drawables.MayaDay13,
        Rez.Drawables.MayaDay14,
        Rez.Drawables.MayaDay15,
        Rez.Drawables.MayaDay16,
        Rez.Drawables.MayaDay17,
        Rez.Drawables.MayaDay18,
        Rez.Drawables.MayaDay19,
        Rez.Drawables.MayaDay20
    ];

    private static const MAYA_MONTH_RESOURCE_IDS = [
        Rez.Drawables.MayaMonth1,
        Rez.Drawables.MayaMonth2,
        Rez.Drawables.MayaMonth3,
        Rez.Drawables.MayaMonth4,
        Rez.Drawables.MayaMonth5,
        Rez.Drawables.MayaMonth6,
        Rez.Drawables.MayaMonth7,
        Rez.Drawables.MayaMonth8,
        Rez.Drawables.MayaMonth9,
        Rez.Drawables.MayaMonth10,
        Rez.Drawables.MayaMonth11,
        Rez.Drawables.MayaMonth12,
        Rez.Drawables.MayaMonth13,
        Rez.Drawables.MayaMonth14,
        Rez.Drawables.MayaMonth15,
        Rez.Drawables.MayaMonth16,
        Rez.Drawables.MayaMonth17,
        Rez.Drawables.MayaMonth18,
        Rez.Drawables.MayaMonth19
    ];

    private static const ZODIAC_RESOURCE_IDS = [
        Rez.Drawables.Zodiac0,
        Rez.Drawables.Zodiac1,
        Rez.Drawables.Zodiac2,
        Rez.Drawables.Zodiac3,
        Rez.Drawables.Zodiac4,
        Rez.Drawables.Zodiac5,
        Rez.Drawables.Zodiac6,
        Rez.Drawables.Zodiac7,
        Rez.Drawables.Zodiac8,
        Rez.Drawables.Zodiac9,
        Rez.Drawables.Zodiac10,
        Rez.Drawables.Zodiac11
    ];

    static function ensureLoaded() as Void {
        if (loaded) {
            return;
        }

        var deviceSettings = System.getDeviceSettings();
        var screenArea = deviceSettings.screenWidth * deviceSettings.screenHeight;
        lowMemoryMode = (screenArea < HIGH_MEMORY_THRESHOLD);

        if (lowMemoryMode) {
            initializeDimensionArrays();
        } else {
            loadAllBitmaps();
        }

        loaded = true;
    }

    // Initialize dimension arrays without loading bitmaps
    private static function initializeDimensionArrays() as Void {
        for (var i = 0; i < DIGIT_RESOURCE_IDS.size(); i++) {
            digitWidths.add(0);
            digitHeights.add(0);
        }
        for (var i = 0; i < DATE_DIGIT_RESOURCE_IDS.size(); i++) {
            dateDigitWidths.add(0);
            dateDigitHeights.add(0);
        }
    }

    private static function loadAllBitmaps() as Void {
        for (var i = 0; i < DIGIT_RESOURCE_IDS.size(); i++) {
            var bmp = WatchUi.loadResource(DIGIT_RESOURCE_IDS[i]) as WatchUi.BitmapResource;
            digitBitmaps.add(bmp);
            digitWidths.add(bmp.getWidth());
            digitHeights.add(bmp.getHeight());
        }

        for (var i = 0; i < DATE_DIGIT_RESOURCE_IDS.size(); i++) {
            var bmp = WatchUi.loadResource(DATE_DIGIT_RESOURCE_IDS[i]) as WatchUi.BitmapResource;
            dateDigitBitmaps.add(bmp);
            dateDigitWidths.add(bmp.getWidth());
            dateDigitHeights.add(bmp.getHeight());
        }

        for (var i = 0; i < WEEKDAY_RESOURCE_IDS.size(); i++) {
            weekdayBitmaps.add(WatchUi.loadResource(WEEKDAY_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }

        for (var i = 0; i < MONTH_RESOURCE_IDS.size(); i++) {
            monthBitmaps.add(WatchUi.loadResource(MONTH_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }

        for (var i = 0; i < MAYA_NUMBER_RESOURCE_IDS.size(); i++) {
            mayaNumberBitmaps.add(WatchUi.loadResource(MAYA_NUMBER_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }

        for (var i = 0; i < MAYA_DAY_RESOURCE_IDS.size(); i++) {
            mayaDayBitmaps.add(WatchUi.loadResource(MAYA_DAY_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }

        for (var i = 0; i < MAYA_MONTH_RESOURCE_IDS.size(); i++) {
            mayaMonthBitmaps.add(WatchUi.loadResource(MAYA_MONTH_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }

        for (var i = 0; i < ZODIAC_RESOURCE_IDS.size(); i++) {
            zodiacBitmaps.add(WatchUi.loadResource(ZODIAC_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }
    }

    static function getDigitBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            var bmp = WatchUi.loadResource(DIGIT_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
            if (digitWidths[index] == 0) {
                digitWidths[index] = bmp.getWidth();
                digitHeights[index] = bmp.getHeight();
            }
            return bmp;
        }
        return digitBitmaps[index] as WatchUi.BitmapResource;
    }

    static function getDateDigitBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            var bmp = WatchUi.loadResource(DATE_DIGIT_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
            if (dateDigitWidths[index] == 0) {
                dateDigitWidths[index] = bmp.getWidth();
                dateDigitHeights[index] = bmp.getHeight();
            }
            return bmp;
        }
        return dateDigitBitmaps[index] as WatchUi.BitmapResource;
    }

    static function getWeekdayBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            return WatchUi.loadResource(WEEKDAY_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
        }
        return weekdayBitmaps[index] as WatchUi.BitmapResource;
    }

    static function getMonthBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            return WatchUi.loadResource(MONTH_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
        }
        return monthBitmaps[index] as WatchUi.BitmapResource;
    }

    static function getMayaNumberBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            return WatchUi.loadResource(MAYA_NUMBER_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
        }
        return mayaNumberBitmaps[index] as WatchUi.BitmapResource;
    }

    static function getMayaDayBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            return WatchUi.loadResource(MAYA_DAY_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
        }
        return mayaDayBitmaps[index] as WatchUi.BitmapResource;
    }

    static function getMayaMonthBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            return WatchUi.loadResource(MAYA_MONTH_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
        }
        return mayaMonthBitmaps[index] as WatchUi.BitmapResource;
    }

    static function getZodiacBitmap(index as Number) as WatchUi.BitmapResource {
        if (lowMemoryMode) {
            return WatchUi.loadResource(ZODIAC_RESOURCE_IDS[index]) as WatchUi.BitmapResource;
        }
        return zodiacBitmaps[index] as WatchUi.BitmapResource;
    }
}

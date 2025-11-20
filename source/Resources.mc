import Toybox.Lang;
import Toybox.WatchUi;

class Resources {
    static var loaded as Boolean = false;

    static var digitBitmaps as Array = [] as Array;
    static var digitWidths as Array = [] as Array;
    static var digitHeights as Array = [] as Array;

    static var weekdayBitmaps as Array = [] as Array;
    static var dateDigitBitmaps as Array = [] as Array;
    static var dateDigitWidths as Array = [] as Array;
    static var dateDigitHeights as Array = [] as Array;
    static var monthBitmaps as Array = [] as Array;

    static var mayaNumberBitmaps as Array = [] as Array;
    static var mayaDayBitmaps as Array = [] as Array;
    static var mayaMonthBitmaps as Array = [] as Array;

    static var zodiacBitmaps as Array = [] as Array;

    static function ensureLoaded(weekdayIds as Array, dateDigitIds as Array, monthIds as Array) as Void {
        if (loaded) {
            return;
        }

        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit0) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit1) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit2) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit3) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit4) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit5) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit6) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit7) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit8) as WatchUi.BitmapResource);
        digitBitmaps.add(WatchUi.loadResource(Rez.Drawables.Digit9) as WatchUi.BitmapResource);

        for (var i = 0; i < digitBitmaps.size(); ++i) {
            var bmp = digitBitmaps[i];
            digitWidths.add(bmp.getWidth());
            digitHeights.add(bmp.getHeight());
        }

        for (var i = 0; i < weekdayIds.size(); ++i) {
            weekdayBitmaps.add(WatchUi.loadResource(weekdayIds[i]) as WatchUi.BitmapResource);
        }

        for (var i = 0; i < dateDigitIds.size(); ++i) {
            var dateBmp = WatchUi.loadResource(dateDigitIds[i]) as WatchUi.BitmapResource;
            dateDigitBitmaps.add(dateBmp);
            dateDigitWidths.add(dateBmp.getWidth());
            dateDigitHeights.add(dateBmp.getHeight());
        }

        for (var i = 0; i < monthIds.size(); ++i) {
            monthBitmaps.add(WatchUi.loadResource(monthIds[i]) as WatchUi.BitmapResource);
        }

        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber0) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber1) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber2) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber3) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber4) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber5) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber6) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber7) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber8) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber9) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber10) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber11) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber12) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber13) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber14) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber15) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber16) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber17) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber18) as WatchUi.BitmapResource);
        mayaNumberBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaNumber19) as WatchUi.BitmapResource);

        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay1) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay2) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay3) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay4) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay5) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay6) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay7) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay8) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay9) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay10) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay11) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay12) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay13) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay14) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay15) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay16) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay17) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay18) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay19) as WatchUi.BitmapResource);
        mayaDayBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaDay20) as WatchUi.BitmapResource);

        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth1) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth2) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth3) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth4) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth5) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth6) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth7) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth8) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth9) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth10) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth11) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth12) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth13) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth14) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth15) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth16) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth17) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth18) as WatchUi.BitmapResource);
        mayaMonthBitmaps.add(WatchUi.loadResource(Rez.Drawables.MayaMonth19) as WatchUi.BitmapResource);

        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac0) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac1) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac2) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac3) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac4) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac5) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac6) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac7) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac8) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac9) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac10) as WatchUi.BitmapResource);
        zodiacBitmaps.add(WatchUi.loadResource(Rez.Drawables.Zodiac11) as WatchUi.BitmapResource);

        loaded = true;
    }
}

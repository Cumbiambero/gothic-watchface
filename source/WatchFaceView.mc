import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class WatchFaceView extends WatchUi.WatchFace {

    private const DIGIT_SPACING = -12;
    private const LINE_SPACING = -40;
    private const MINUTES_VERTICAL_OFFSET = 32;
    private const TIME_BLOCK_SHIFT = 7;
    private const DATE_MARGIN = 16;
    private const DATE_GAP = -10;
    private const DATE_VERTICAL_OFFSET = 12;
    private const DATE_DIGIT_SPACING = -10;
    private const WEEKDAY_RESOURCE_IDS = [
        Rez.Drawables.Weekday1,
        Rez.Drawables.Weekday2,
        Rez.Drawables.Weekday3,
        Rez.Drawables.Weekday4,
        Rez.Drawables.Weekday5,
        Rez.Drawables.Weekday6,
        Rez.Drawables.Weekday7
    ];
    private const MONTH_RESOURCE_IDS = [
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
    private const DATE_DIGIT_RESOURCE_IDS = [
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
   
    private var digitBitmaps as Array<WatchUi.BitmapResource>;
    private var digitWidths as Array<Number>;
    private var digitHeights as Array<Number>;
    private var digitLookup as Dictionary;
    private var weekdayBitmaps as Array<WatchUi.BitmapResource>;
    private var dateDigitBitmaps as Array<WatchUi.BitmapResource>;
    private var dateDigitWidths as Array<Number>;
    private var dateDigitHeights as Array<Number>;
    private var monthBitmaps as Array<WatchUi.BitmapResource>;
    private var cachedHourValue as Number;
    private var cachedMinuteValue as Number;
    private var cachedHoursString as String;
    private var cachedMinutesString as String;
    private var cachedHoursWidth as Number;
    private var cachedHoursHeight as Number;
    private var cachedMinutesWidth as Number;
    private var cachedMinutesHeight as Number;
    private var cachedDayValue as Number;
    private var cachedDayString as String;
    private var cachedDayWidth as Number;
    private var cachedDayHeight as Number;
    private var cachedWeekdayIndex as Number;
    private var cachedMonthIndex as Number;

    function initialize() {
        WatchFace.initialize();

        digitBitmaps = [] as Array<WatchUi.BitmapResource>;
        digitWidths = [] as Array<Number>;
        digitHeights = [] as Array<Number>;
        weekdayBitmaps = [] as Array<WatchUi.BitmapResource>;
        dateDigitBitmaps = [] as Array<WatchUi.BitmapResource>;
        dateDigitWidths = [] as Array<Number>;
        dateDigitHeights = [] as Array<Number>;
        monthBitmaps = [] as Array<WatchUi.BitmapResource>;
        cachedHourValue = -1;
        cachedMinuteValue = -1;
        cachedHoursString = "";
        cachedMinutesString = "";
        cachedHoursWidth = 0;
        cachedHoursHeight = 0;
        cachedMinutesWidth = 0;
        cachedMinutesHeight = 0;
        cachedDayValue = -1;
        cachedDayString = "";
        cachedDayWidth = 0;
        cachedDayHeight = 0;
        cachedWeekdayIndex = -1;
        cachedMonthIndex = -1;

        digitLookup = {
            "0" => 0,
            "1" => 1,
            "2" => 2,
            "3" => 3,
            "4" => 4,
            "5" => 5,
            "6" => 6,
            "7" => 7,
            "8" => 8,
            "9" => 9
        };
    }

    function onLayout(dc as Dc) as Void {
        digitBitmaps = [] as Array<WatchUi.BitmapResource>;
        digitWidths = [] as Array<Number>;
        digitHeights = [] as Array<Number>;
        weekdayBitmaps = [] as Array<WatchUi.BitmapResource>;
        dateDigitBitmaps = [] as Array<WatchUi.BitmapResource>;
        dateDigitWidths = [] as Array<Number>;
        dateDigitHeights = [] as Array<Number>;
        monthBitmaps = [] as Array<WatchUi.BitmapResource>;

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

        for (var i = 0; i < WEEKDAY_RESOURCE_IDS.size(); ++i) {
            weekdayBitmaps.add(WatchUi.loadResource(WEEKDAY_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }

        for (var i = 0; i < DATE_DIGIT_RESOURCE_IDS.size(); ++i) {
            var dateBmp = WatchUi.loadResource(DATE_DIGIT_RESOURCE_IDS[i]) as WatchUi.BitmapResource;
            dateDigitBitmaps.add(dateBmp);
            dateDigitWidths.add(dateBmp.getWidth());
            dateDigitHeights.add(dateBmp.getHeight());
        }

        for (var i = 0; i < MONTH_RESOURCE_IDS.size(); ++i) {
            monthBitmaps.add(WatchUi.loadResource(MONTH_RESOURCE_IDS[i]) as WatchUi.BitmapResource);
        }
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var clockTime = System.getClockTime();

        var hourChanged = (clockTime.hour != cachedHourValue);
        if (hourChanged) {
            cachedHourValue = clockTime.hour;
            cachedHoursString = cachedHourValue.format("%02d");
            var hoursMetrics = getLineMetrics(cachedHoursString);
            cachedHoursWidth = hoursMetrics["width"];
            cachedHoursHeight = hoursMetrics["height"];
        }

        var minuteChanged = (clockTime.min != cachedMinuteValue);
        if (minuteChanged) {
            cachedMinuteValue = clockTime.min;
            cachedMinutesString = cachedMinuteValue.format("%02d");
            var minutesMetrics = getLineMetrics(cachedMinutesString);
            cachedMinutesWidth = minutesMetrics["width"];
            cachedMinutesHeight = minutesMetrics["height"];
        }

        var needsDateUpdate = minuteChanged || cachedDayValue == -1 || cachedWeekdayIndex == -1 || cachedMonthIndex == -1;
        if (needsDateUpdate) {
            var infoShort = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT) as Time.Gregorian.Info;

            var weekdayIndex = getNumberValue(infoShort.day_of_week, 1) - 1;
            if (weekdayIndex < 0 || weekdayIndex >= weekdayBitmaps.size()) {
                weekdayIndex = 0;
            }
            cachedWeekdayIndex = weekdayIndex;

            var monthIndex = getNumberValue(infoShort.month, 1) - 1;
            if (monthIndex < 0 || monthIndex >= monthBitmaps.size()) {
                monthIndex = 0;
            }
            cachedMonthIndex = monthIndex;

            var dayNumber = getNumberValue(infoShort.day, 1);
            if (dayNumber < 1) {
                dayNumber = 1;
            } else if (dayNumber > 31) {
                dayNumber = 31;
            }

            if (dayNumber != cachedDayValue) {
                cachedDayValue = dayNumber;
                cachedDayString = dayNumber.format("%d");
                var dayMetrics = getDateDigitLineMetrics(cachedDayString);
                cachedDayWidth = dayMetrics["width"];
                cachedDayHeight = dayMetrics["height"];
            }
        }

        var hasDateBitmaps = weekdayBitmaps.size() > 0 && dateDigitBitmaps.size() == DATE_DIGIT_RESOURCE_IDS.size() && monthBitmaps.size() > 0 && cachedDayString != "" && cachedWeekdayIndex >= 0 && cachedMonthIndex >= 0;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    var totalHeight = cachedHoursHeight + cachedMinutesHeight + LINE_SPACING + MINUTES_VERTICAL_OFFSET;
    var startY = (height - totalHeight) / 2 - 15 + TIME_BLOCK_SHIFT;

        drawDigitLine(dc, cachedHoursString, startY, cachedHoursWidth, cachedHoursHeight);
        drawDigitLine(dc, cachedMinutesString, startY + cachedHoursHeight + LINE_SPACING + MINUTES_VERTICAL_OFFSET, cachedMinutesWidth, cachedMinutesHeight);

        if (hasDateBitmaps) {
            var weekdayBitmap = weekdayBitmaps[cachedWeekdayIndex];
            var monthBitmap = monthBitmaps[cachedMonthIndex];
            var monthWidth = monthBitmap.getWidth();

            var dateRight = dc.getWidth() - DATE_MARGIN;

            var symbolHeight = weekdayBitmap.getHeight();
            var symbolWidth = weekdayBitmap.getWidth();
            var dayHeight = cachedDayHeight;

            var maxWidth = symbolWidth;
            if (cachedDayWidth > maxWidth) {
                maxWidth = cachedDayWidth;
            }
            if (monthWidth > maxWidth) {
                maxWidth = monthWidth;
            }

            var dateLeft = dateRight - maxWidth;
            var dateCenter = dateLeft + maxWidth / 2.0;

            var symbolLeft = dateCenter - symbolWidth / 2.0;
            var dayLeft = dateCenter - cachedDayWidth / 2.0;
            var monthLeft = dateCenter - monthWidth / 2.0;

            var dayCenterY = (height / 2.0) + DATE_VERTICAL_OFFSET;
            var dayTop = dayCenterY - (dayHeight / 2.0);

            var symbolTop = dayTop - DATE_GAP - symbolHeight;
            var monthTop = dayTop + dayHeight + DATE_GAP + 3;

            dc.drawBitmap(symbolLeft, symbolTop, weekdayBitmap);
            drawDateDigitLine(dc, cachedDayString, dayLeft, dayTop, cachedDayWidth, cachedDayHeight);
            dc.drawBitmap(monthLeft, monthTop, monthBitmap);
        }
    }

    function getNumberValue(value as Lang.Object?, fallback as Number) as Number {
        if (value instanceof Number) {
            return value as Number;
        }

        if (value instanceof String) {
            var parsed = (value as String).toNumber();
            if (parsed != null) {
                return parsed as Number;
            }
        }

        return fallback;
    }

    function onHide() as Void { 
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

    function getLineMetrics(text as String) as Dictionary {
        var totalWidth = 0;
        var maxHeight = 0;
        var length = text.length();

        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup[digitChar];
            var w = digitWidths[idx];
            var h = digitHeights[idx];

            totalWidth += w;
            if (i < length - 1) {
                totalWidth += DIGIT_SPACING;
            }

            if (h > maxHeight) {
                maxHeight = h;
            }
        }

        return {
            "width" => totalWidth,
            "height" => maxHeight
        } as Dictionary;
    }

    function drawDigitLine(dc as Dc, text as String, top, lineWidth as Number, lineHeight as Number) as Void {
        var startX = (dc.getWidth() - lineWidth) / 2;
        var length = text.length();

        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup[digitChar];
            var bmp = digitBitmaps[idx];
            var bmpHeight = digitHeights[idx];
            var drawY = top + (lineHeight - bmpHeight) / 2;

            dc.drawBitmap(startX, drawY, bmp);

            startX += digitWidths[idx];
            if (i < length - 1) {
                startX += DIGIT_SPACING;
            }
        }
    }

    function getDateDigitLineMetrics(text as String) as Dictionary {
        var totalWidth = 0;
        var maxHeight = 0;
        var length = text.length();

        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup.get(digitChar);
            if (idx == null) {
                continue;
            }

            var indexNumber = idx as Number;
            var w = dateDigitWidths[indexNumber];
            var h = dateDigitHeights[indexNumber];

            totalWidth += w;
            if (i < length - 1) {
                totalWidth += DATE_DIGIT_SPACING;
            }

            if (h > maxHeight) {
                maxHeight = h;
            }
        }

        return {
            "width" => totalWidth,
            "height" => maxHeight
        } as Dictionary;
    }

    function drawDateDigitLine(dc as Dc, text as String, leftX, top, lineWidth as Number, lineHeight as Number) as Void {
        var startX = leftX;
        var length = text.length();

        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup.get(digitChar);
            if (idx == null) {
                continue;
            }


            var indexNumber = idx as Number;
            var bmp = dateDigitBitmaps[indexNumber];
            var bmpHeight = dateDigitHeights[indexNumber];
            var drawY = top + (lineHeight - bmpHeight) / 2;

            dc.drawBitmap(startX, drawY, bmp);

            startX += dateDigitWidths[indexNumber];
            if (i < length - 1) {
                startX += DATE_DIGIT_SPACING;
            }
        }
    }
}

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Math;

class WatchFaceView extends WatchUi.WatchFace {

    private const DIGIT_SPACING = -12;
    private const LINE_SPACING = -40;
    private const MINUTES_VERTICAL_OFFSET = 32;
    private const TIME_BLOCK_SHIFT = 7;
    private const DATE_MARGIN = 16;
    private const DATE_GAP = -10;
    private const DATE_VERTICAL_OFFSET = 12;
    private const DATE_DIGIT_SPACING = -10;
    private const MOON_BASE_DIAMETER = 50.0;
    private const MOON_MIN_DIAMETER_RATIO = 0.48;
    private const LEFT_COLUMN_GAP = 70;
    private const MOON_TO_MAYA_GAP = 55;
    
    private var digitSpacing as Number = 0;
    private var lineSpacing as Number = 0;
    private var minutesVerticalOffset as Number = 0;
    private var timeBlockShift as Number = 0;
    private var dateMargin as Number = 0;
    private var dateGap as Number = 0;
    private var dateVerticalOffset as Number = 0;
    private var dateDigitSpacing as Number = 0;
    private var layoutScale as Number = 1;
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
    private var cachedMinutesWidth as Number;
    private var stableHoursWidth as Number;
    private var cachedDayValue as Number;
    private var cachedDayString as String;
    private var cachedDayWidth as Number;
    private var cachedDayHeight as Number;
    private var cachedWeekdayIndex as Number;
    private var cachedMonthIndex as Number;
    private var cachedMoonPhaseFrac as Number;
    private var cachedTzolkin as Dictionary = {} as Dictionary;
    private var cachedHaab as Dictionary = {} as Dictionary;
    private var cachedZodiac as Dictionary = {} as Dictionary;
    private var mayaNumberBitmaps as Array<WatchUi.BitmapResource> = [] as Array<WatchUi.BitmapResource>;
    private var mayaDayBitmaps as Array<WatchUi.BitmapResource> = [] as Array<WatchUi.BitmapResource>;
    private var mayaMonthBitmaps as Array<WatchUi.BitmapResource> = [] as Array<WatchUi.BitmapResource>;
    private var zodiacBitmaps as Array<WatchUi.BitmapResource> = [] as Array<WatchUi.BitmapResource>;

    private function roundScaled(n) as Number {
        return (Math.floor(n + 0.5)) as Number;
    }
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
        cachedMoonPhaseFrac = -1;
        cachedHourValue = -1;
        cachedMinuteValue = -1;
        cachedHoursString = "";
        cachedMinutesString = "";
        cachedHoursWidth = 0;
        cachedMinutesWidth = 0;
        stableHoursWidth = 0;
        cachedDayValue = -1;
        cachedDayString = "";
        cachedDayWidth = 0;
        cachedDayHeight = 0;
        cachedWeekdayIndex = -1;
        cachedMonthIndex = -1;
        cachedMoonPhaseFrac = -1;
        
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
        var w = dc.getWidth();
        var h = dc.getHeight();
        var baseSize = 280.0; 
        layoutScale = (((w < h) ? w : h) / baseSize) as Number;
        if (layoutScale <= 0) { 
            layoutScale = 1;
        }

        digitSpacing = roundScaled(DIGIT_SPACING * layoutScale);
        lineSpacing = roundScaled(LINE_SPACING * layoutScale);
        minutesVerticalOffset = roundScaled(MINUTES_VERTICAL_OFFSET * layoutScale);
        timeBlockShift = roundScaled(TIME_BLOCK_SHIFT * layoutScale);
        var scaledMargin = DATE_MARGIN * layoutScale;
        dateMargin = roundScaled((scaledMargin < 12) ? 12 : scaledMargin);
        dateGap = roundScaled(DATE_GAP * layoutScale);
        dateVerticalOffset = roundScaled(DATE_VERTICAL_OFFSET * layoutScale);
        dateDigitSpacing = roundScaled(DATE_DIGIT_SPACING * layoutScale);
        Resources.ensureLoaded(WEEKDAY_RESOURCE_IDS, DATE_DIGIT_RESOURCE_IDS, MONTH_RESOURCE_IDS);
        digitBitmaps = Resources.digitBitmaps as Array<WatchUi.BitmapResource>;
        digitWidths = Resources.digitWidths as Array<Number>;
        digitHeights = Resources.digitHeights as Array<Number>;
        weekdayBitmaps = Resources.weekdayBitmaps as Array<WatchUi.BitmapResource>;
        dateDigitBitmaps = Resources.dateDigitBitmaps as Array<WatchUi.BitmapResource>;
        dateDigitWidths = Resources.dateDigitWidths as Array<Number>;
        dateDigitHeights = Resources.dateDigitHeights as Array<Number>;
        monthBitmaps = Resources.monthBitmaps as Array<WatchUi.BitmapResource>;
        mayaNumberBitmaps = Resources.mayaNumberBitmaps as Array<WatchUi.BitmapResource>;
        mayaDayBitmaps = Resources.mayaDayBitmaps as Array<WatchUi.BitmapResource>;
        mayaMonthBitmaps = Resources.mayaMonthBitmaps as Array<WatchUi.BitmapResource>;
        zodiacBitmaps = Resources.zodiacBitmaps as Array<WatchUi.BitmapResource>;

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
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        clearScreen(dc);

        var height = dc.getHeight();

        var hourChanged = updateTimeCache(System.getClockTime());
        var dayChanged = updateDateCache(hourChanged);
        updateAstronomicalData(dayChanged);

        var digitHeight = digitHeights[0];
        var totalHeight = digitHeight + digitHeight + lineSpacing + minutesVerticalOffset;
        var startY = roundScaled((height - totalHeight) / 2) - roundScaled(15 * layoutScale) + timeBlockShift;
        var hoursStartX = roundScaled((dc.getWidth() - stableHoursWidth) / 2);
        var lineRight = hoursStartX - roundScaled(LEFT_COLUMN_GAP * layoutScale);

        var columnMaxWidth = 0;
        var moonDiameter = 0;
        if (cachedMoonPhaseFrac >= 0) {
            var baseDiameter = MOON_BASE_DIAMETER * layoutScale;
            moonDiameter = roundScaled(baseDiameter);
            var minDiameter = roundScaled(MOON_BASE_DIAMETER * MOON_MIN_DIAMETER_RATIO);
            if (moonDiameter < minDiameter) { moonDiameter = minDiameter; }
            if (moonDiameter > columnMaxWidth) { columnMaxWidth = moonDiameter; }
        }

        if (cachedTzolkin.size() > 0) {
            var tzNumberBmp = mayaNumberBitmaps[cachedTzolkin["number"]];
            var tzNameBmp = mayaDayBitmaps[cachedTzolkin["nameIndex"]];
            var tzTotalW = tzNumberBmp.getWidth() + tzNameBmp.getWidth();
            if (tzTotalW > columnMaxWidth) { columnMaxWidth = tzTotalW; }

            var haabNumberBmp = mayaNumberBitmaps[cachedHaab["dayInMonth"]];
            var haabMonthBmp = mayaMonthBitmaps[cachedHaab["monthIndex"]];
            var haabTotalW = haabNumberBmp.getWidth() + haabMonthBmp.getWidth();
            if (haabTotalW > columnMaxWidth) { columnMaxWidth = haabTotalW; }
        }

        if (cachedZodiac.size() > 0) {
            var zodiacBitmap = zodiacBitmaps[cachedZodiac["index"]];
            if (zodiacBitmap.getWidth() > columnMaxWidth) { columnMaxWidth = zodiacBitmap.getWidth(); }
        }

        var columnLeftPosition = lineRight - columnMaxWidth;
        var anchorCenterX = columnLeftPosition + roundScaled(columnMaxWidth / 2.0);
        var centerY = roundScaled(height / 2.0) + dateVerticalOffset;

        if (cachedMoonPhaseFrac >= 0) {
            MoonPhase.drawMoon(dc, anchorCenterX, centerY - roundScaled(MOON_TO_MAYA_GAP * layoutScale), moonDiameter, cachedMoonPhaseFrac);
        }

        if (cachedTzolkin.size() > 0) {
            var tzolkinY = centerY - roundScaled(30 * layoutScale);
            var haabY = centerY;
            drawMaya(dc, anchorCenterX, tzolkinY, haabY);

            if (cachedZodiac.size() > 0) {
                var zodiacBitmap2 = zodiacBitmaps[cachedZodiac["index"]];
                var zX = anchorCenterX - roundScaled(zodiacBitmap2.getWidth() / 2.0);
                dc.drawBitmap(zX, centerY + roundScaled(30 * layoutScale), zodiacBitmap2);
            }
        }

        drawTimeElements(dc, startY, digitHeight);
        drawDateElements(dc, height);
    }

    function clearScreen(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
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
        invalidateAllCaches();
    }

    function onEnterSleep() as Void {
    }

    function invalidateAllCaches() as Void {
        cachedHourValue = -1;
        cachedMinuteValue = -1;
        cachedHoursString = "";
        cachedMinutesString = "";
        cachedDayValue = -1;
        cachedDayString = "";
        cachedWeekdayIndex = -1;
        cachedMonthIndex = -1;
        cachedMoonPhaseFrac = -1;
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
                totalWidth += digitSpacing;
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
        var startX = roundScaled((dc.getWidth() - lineWidth) / 2);
        drawBitmapDigits(dc, text, startX, top, lineHeight, digitBitmaps, digitWidths, digitHeights, digitSpacing);
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
                totalWidth += dateDigitSpacing;
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
        var startX = leftX as Number;
        drawBitmapDigits(dc, text, startX, top, lineHeight, dateDigitBitmaps, dateDigitWidths, dateDigitHeights, dateDigitSpacing);
    }

    function drawBitmapDigits(dc as Dc, text as String, startX as Number, top as Number, lineHeight as Number,
            bitmaps as Array<WatchUi.BitmapResource>, widths as Array<Number>, heights as Array<Number>, spacing as Number) as Void {
        var length = text.length();
        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup.get(digitChar);

            if (idx == null) {
                continue;
            }

            var indexNumber = idx as Number;
            var bmp = bitmaps[indexNumber];
            var bmpHeight = heights[indexNumber];
            var drawY = top + roundScaled((lineHeight - bmpHeight) / 2.0);
            dc.drawBitmap(startX, drawY, bmp);
            startX += widths[indexNumber];
            if (i < length - 1) {
                startX += spacing;
            }
        }
    }

    function drawMaya(dc as Dc, centerX as Number, tzolkinY as Number, haabY as Number) as Void {
        var numberBmp = mayaNumberBitmaps[cachedTzolkin["number"]];
        var nameBmp = mayaDayBitmaps[cachedTzolkin["nameIndex"]];
        var tzolkinTotalW = numberBmp.getWidth() + nameBmp.getWidth();
        var tzolkinLeft = centerX - roundScaled(tzolkinTotalW / 2.0);
        dc.drawBitmap(tzolkinLeft, tzolkinY, numberBmp);
        dc.drawBitmap(tzolkinLeft + numberBmp.getWidth(), tzolkinY, nameBmp);

        var haabNumberBmp = mayaNumberBitmaps[cachedHaab["dayInMonth"]];
        var haabMonthBmp = mayaMonthBitmaps[cachedHaab["monthIndex"]];
        var haabTotalW = haabNumberBmp.getWidth() + haabMonthBmp.getWidth();
        var haabLeft = centerX - roundScaled(haabTotalW / 2.0);
        dc.drawBitmap(haabLeft, haabY, haabNumberBmp);
        dc.drawBitmap(haabLeft + haabNumberBmp.getWidth(), haabY, haabMonthBmp);
    }

    private function updateTimeCache(clockTime as System.ClockTime) as Boolean {
        var hourChanged = (clockTime.hour != cachedHourValue);
        if (hourChanged) {
            cachedHourValue = clockTime.hour;
            var displayHour = cachedHourValue;
            var settings = System.getDeviceSettings();
            if (settings != null && !settings.is24Hour) {
                displayHour = displayHour % 12;
                if (displayHour == 0) {
                    displayHour = 12;
                }
            }
            cachedHoursString = displayHour.format("%02d");
            var hoursMetrics = getLineMetrics(cachedHoursString);
            cachedHoursWidth = hoursMetrics["width"];
        }

        var minuteChanged = (clockTime.min != cachedMinuteValue);
        if (minuteChanged) {
            cachedMinuteValue = clockTime.min;
            cachedMinutesString = cachedMinuteValue.format("%02d");
            var minutesMetrics = getLineMetrics(cachedMinutesString);
            cachedMinutesWidth = minutesMetrics["width"];
        }

        return hourChanged;
    }

    private function updateDateCache(hourChanged as Boolean) as Boolean {
        var needsDateUpdate = hourChanged || cachedDayValue == -1 || cachedWeekdayIndex == -1 || cachedMonthIndex == -1;
        var dayChanged = false;
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
            if (dayNumber < 1) { dayNumber = 1; } else if (dayNumber > 31) { dayNumber = 31; }

            if (dayNumber != cachedDayValue) {
                dayChanged = true;
                cachedDayValue = dayNumber;
                cachedDayString = dayNumber.format("%d");
                var dayMetrics = getDateDigitLineMetrics(cachedDayString);
                cachedDayWidth = dayMetrics["width"];
                cachedDayHeight = dayMetrics["height"];
            }
        }
        return dayChanged;
    }

    private function updateAstronomicalData(dayChanged as Boolean) as Void {
        if (dayChanged || cachedMoonPhaseFrac < 0) {
            cachedMoonPhaseFrac = MoonPhase.computeMoonPhaseFraction();
        }
        if (dayChanged || cachedTzolkin.size() == 0) {
            cachedTzolkin = MayaCalendar.computeCurrentTzolkin();
        }
        if (dayChanged || cachedHaab.size() == 0) {
            cachedHaab = MayaCalendar.computeCurrentHaab();
        }
        if (dayChanged || cachedZodiac.size() == 0) {
            cachedZodiac = Zodiac.getCurrentZodiac();
        }
    }

    private function drawTimeElements(dc as Dc, startY as Number, digitHeight as Number) as Void {
        drawDigitLine(dc, cachedHoursString, startY, cachedHoursWidth, digitHeight);
        drawDigitLine(dc, cachedMinutesString, startY + digitHeight + lineSpacing + minutesVerticalOffset, cachedMinutesWidth, digitHeight);
    }

    private function drawDateElements(dc as Dc, height as Number) as Void {
        var weekdayBitmap = weekdayBitmaps[cachedWeekdayIndex];
        var monthBitmap = monthBitmaps[cachedMonthIndex];
        var monthWidth = monthBitmap.getWidth();

        var dateRight = dc.getWidth() - dateMargin;

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
        var dateCenter = dateLeft + roundScaled(maxWidth / 2.0);

        var symbolLeft = dateCenter - roundScaled(symbolWidth / 2.0);
        var dayLeft = dateCenter - roundScaled(cachedDayWidth / 2.0);
        var monthLeft = dateCenter - roundScaled(monthWidth / 2.0);

        var dayCenterY = roundScaled(height / 2.0) + dateVerticalOffset;
        var dayTop = dayCenterY - roundScaled(dayHeight / 2.0);

        var symbolTop = dayTop - dateGap - symbolHeight;
        var monthTop = dayTop + dayHeight + dateGap + roundScaled(3 * layoutScale);

        dc.drawBitmap(symbolLeft as Number, symbolTop as Number, weekdayBitmap);
        drawDateDigitLine(dc, cachedDayString, dayLeft as Number, dayTop as Number, cachedDayWidth, cachedDayHeight);
        dc.drawBitmap(monthLeft as Number, monthTop as Number, monthBitmap);
    }
}

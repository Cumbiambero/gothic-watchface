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
    
    private var digitSpacing as Number = 0;
    private var lineSpacing as Number = 0;
    private var minutesVerticalOffset as Number = 0;
    private var timeBlockShift as Number = 0;
    private var dateMargin as Number = 0;
    private var dateGap as Number = 0;
    private var dateVerticalOffset as Number = 0;
    private var dateDigitSpacing as Number = 0;
    private var layoutScale as Number = 1;

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
    private var cachedMoonPhaseIndex as Number;
    private var moonPhaseBitmaps as Array<WatchUi.BitmapResource>;
    private var inSleep as Boolean = false;

    private const NEW_MOON_EPOCH = 947182440; // seconds since Unix epoch
    private const SYNODIC_MONTH_DAYS = 29.530588853; // mean synodic month length
    private const MOON_PHASE_RES_IDS = [
        Rez.Drawables.MoonPhase00,
        Rez.Drawables.MoonPhase01,
        Rez.Drawables.MoonPhase02,
        Rez.Drawables.MoonPhase03,
        Rez.Drawables.MoonPhase04,
        Rez.Drawables.MoonPhase05,
        Rez.Drawables.MoonPhase06,
        Rez.Drawables.MoonPhase07,
        Rez.Drawables.MoonPhase08,
        Rez.Drawables.MoonPhase09,
        Rez.Drawables.MoonPhase10,
        Rez.Drawables.MoonPhase11,
        Rez.Drawables.MoonPhase12,
        Rez.Drawables.MoonPhase13
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
        moonPhaseBitmaps = [] as Array<WatchUi.BitmapResource>;
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
        cachedMoonPhaseIndex = -1;
        
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
        digitBitmaps = [] as Array<WatchUi.BitmapResource>;
        digitWidths = [] as Array<Number>;
        digitHeights = [] as Array<Number>;
        weekdayBitmaps = [] as Array<WatchUi.BitmapResource>;
        dateDigitBitmaps = [] as Array<WatchUi.BitmapResource>;
        dateDigitWidths = [] as Array<Number>;
        dateDigitHeights = [] as Array<Number>;
        monthBitmaps = [] as Array<WatchUi.BitmapResource>;
        moonPhaseBitmaps = [] as Array<WatchUi.BitmapResource>;

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

        for (var i = 0; i < MOON_PHASE_RES_IDS.size(); ++i) {
            try {
                var bmp = WatchUi.loadResource(MOON_PHASE_RES_IDS[i]) as WatchUi.BitmapResource;
                moonPhaseBitmaps.add(bmp);
            } catch(e) {
            }
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

        var hasDateBitmaps = weekdayBitmaps.size() > 0 && dateDigitBitmaps.size() == DATE_DIGIT_RESOURCE_IDS.size() && monthBitmaps.size() > 0 && cachedDayString != "" && cachedWeekdayIndex >= 0 && cachedMonthIndex >= 0;

        if (dayChanged || cachedMoonPhaseIndex < 0) {
            cachedMoonPhaseIndex = getMoonPhaseIndex();
        }

        var hasMoonPhases = moonPhaseBitmaps.size() == MOON_PHASE_RES_IDS.size() && cachedMoonPhaseIndex >= 0 && cachedMoonPhaseIndex < moonPhaseBitmaps.size();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var totalHeight = cachedHoursHeight + cachedMinutesHeight + lineSpacing + minutesVerticalOffset;
        var startY = roundScaled((height - totalHeight) / 2) - roundScaled(15 * layoutScale) + timeBlockShift;

        if (hasMoonPhases && !inSleep) {
            var moonBmp = moonPhaseBitmaps[cachedMoonPhaseIndex];
            var margin = roundScaled(4);
            if (margin < 3) { margin = 3; }
            if (margin > 5) { margin = 5; }
            var moonX = margin as Number;
            var verticalBias = (dc.getWidth() != dc.getHeight()) ? roundScaled(8 * layoutScale) : 0;
            var moonY = (roundScaled((height - moonBmp.getHeight()) / 2) - verticalBias) as Number;
            dc.drawBitmap(moonX, moonY, moonBmp);
        }

        drawDigitLine(dc, cachedHoursString, startY, cachedHoursWidth, cachedHoursHeight);
        drawDigitLine(dc, cachedMinutesString, startY + cachedHoursHeight + lineSpacing + minutesVerticalOffset, cachedMinutesWidth,    cachedMinutesHeight);

        if (hasDateBitmaps) {
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
        inSleep = false;
        invalidateAllCaches();
    }

    function onEnterSleep() as Void {
        inSleep = true;
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
        cachedMoonPhaseIndex = -1;
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

    function getMoonPhaseIndex() as Number {
        var nowMoment = Time.now();
        var nowSecs = 0.0;
        
        if (nowMoment != null) {
            nowSecs = nowMoment.value();
        }

        var daysSince = (nowSecs - NEW_MOON_EPOCH) / 86400.0;
        var cycles = daysSince / SYNODIC_MONTH_DAYS;
        var fracCycles = cycles - Math.floor(cycles);

        if (fracCycles < 0) {
            fracCycles += 1;
        }

        var phaseCount = MOON_PHASE_RES_IDS.size();
        var rawSlotFloat = fracCycles * phaseCount;
        var rawSlot = 0;
        while (rawSlot + 1 <= rawSlotFloat && rawSlot + 1 < phaseCount) {
            rawSlot += 1;
        }
        if (rawSlot >= phaseCount) { rawSlot = 0; }
        return rawSlot;
    }
}

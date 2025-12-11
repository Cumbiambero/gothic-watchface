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
    private const DATE_MARGIN = 10;
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
    private var layoutScale as Float = 1.0;
    private var bitmapScale as Float = 1.0;
    private var digitLookup as Dictionary;
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

    private function roundScaled(n) as Number {
        return (Math.floor(n + 0.5)) as Number;
    }

    private var canScaleBitmaps as Boolean = false;
    private var scalingChecked as Boolean = false;

    private function checkScalingSupport(dc as Dc) as Void {
        if (!scalingChecked) {
            canScaleBitmaps = (dc has :drawScaledBitmap);
            scalingChecked = true;
            if (!canScaleBitmaps) {
                bitmapScale = 1.0;
            }
        }
    }

    private function drawScaledBitmap(dc as Dc, x as Number, y as Number, bmp as WatchUi.BitmapResource) as Void {
        if (!canScaleBitmaps || (bitmapScale >= 0.99 && bitmapScale <= 1.01)) {
            dc.drawBitmap(x, y, bmp);
        } else {
            var w = roundScaled(bmp.getWidth() * bitmapScale);
            var h = roundScaled(bmp.getHeight() * bitmapScale);
            dc.drawScaledBitmap(x, y, w, h, bmp);
        }
    }

    private function getScaledWidth(bmp as WatchUi.BitmapResource) as Number {
        return roundScaled(bmp.getWidth() * bitmapScale);
    }

    private function getScaledHeight(bmp as WatchUi.BitmapResource) as Number {
        return roundScaled(bmp.getHeight() * bitmapScale);
    }

    function initialize() {
        WatchFace.initialize();

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
        var screenSize = ((w < h) ? w : h) as Float;
        layoutScale = screenSize / baseSize;
        if (layoutScale <= 0.0) { 
            layoutScale = 1.0;
        }
        
        bitmapScale = layoutScale;
        digitSpacing = roundScaled(DIGIT_SPACING * layoutScale);
        lineSpacing = roundScaled(LINE_SPACING * layoutScale);
        minutesVerticalOffset = roundScaled(MINUTES_VERTICAL_OFFSET * layoutScale);
        timeBlockShift = roundScaled(TIME_BLOCK_SHIFT * layoutScale);
        var scaledMargin = DATE_MARGIN * layoutScale;
        dateMargin = roundScaled((scaledMargin < 12) ? 12 : scaledMargin);
        dateGap = roundScaled(DATE_GAP * layoutScale);
        dateVerticalOffset = roundScaled(DATE_VERTICAL_OFFSET * layoutScale);
        dateDigitSpacing = roundScaled(DATE_DIGIT_SPACING * layoutScale);
        Resources.ensureLoaded();
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        checkScalingSupport(dc);
        clearScreen(dc);

        var height = dc.getHeight();
        var hourChanged = updateTimeCache(System.getClockTime());
        var dayChanged = updateDateCache(hourChanged);
        updateAstronomicalData(dayChanged);

        var firstDigit = Resources.getDigitBitmap(0);
        var digitHeight = roundScaled(firstDigit.getHeight() * bitmapScale);
        var totalHeight = digitHeight + digitHeight + lineSpacing + minutesVerticalOffset;
        var verticalOffset = roundScaled(10 * layoutScale);
        var startY = roundScaled((height - totalHeight) / 2) - verticalOffset + timeBlockShift;
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
            var tzNumberBmp = Resources.getMayaNumberBitmap(cachedTzolkin["number"] as Number);
            var tzNameBmp = Resources.getMayaDayBitmap(cachedTzolkin["nameIndex"] as Number);
            var tzTotalW = getScaledWidth(tzNumberBmp) + getScaledWidth(tzNameBmp);
            if (tzTotalW > columnMaxWidth) { columnMaxWidth = tzTotalW; }

            var haabNumberBmp = Resources.getMayaNumberBitmap(cachedHaab["dayInMonth"] as Number);
            var haabMonthBmp = Resources.getMayaMonthBitmap(cachedHaab["monthIndex"] as Number);
            var haabTotalW = getScaledWidth(haabNumberBmp) + getScaledWidth(haabMonthBmp);
            if (haabTotalW > columnMaxWidth) { columnMaxWidth = haabTotalW; }
        }

        if (cachedZodiac.size() > 0) {
            var zodiacBitmap = Resources.getZodiacBitmap(cachedZodiac["index"] as Number);
            if (getScaledWidth(zodiacBitmap) > columnMaxWidth) { columnMaxWidth = getScaledWidth(zodiacBitmap); }
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
                var zodiacBitmap2 = Resources.getZodiacBitmap(cachedZodiac["index"] as Number);
                var zX = anchorCenterX - roundScaled(getScaledWidth(zodiacBitmap2) / 2.0);
                drawScaledBitmap(dc, zX, centerY + roundScaled(38 * layoutScale), zodiacBitmap2);
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
            var bmp = Resources.getDigitBitmap(idx as Number);
            var w = roundScaled(bmp.getWidth() * bitmapScale);
            var h = roundScaled(bmp.getHeight() * bitmapScale);

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
        drawTimeDigits(dc, text, startX, top as Number, lineHeight);
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
            var bmp = Resources.getDateDigitBitmap(indexNumber);
            var w = roundScaled(bmp.getWidth() * bitmapScale);
            var h = roundScaled(bmp.getHeight() * bitmapScale);

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
        drawDateDigits(dc, text, leftX as Number, top as Number, lineHeight);
    }

    function drawTimeDigits(dc as Dc, text as String, startX as Number, top as Number, lineHeight as Number) as Void {
        var length = text.length();
        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup.get(digitChar);
            if (idx == null) {
                continue;
            }
            var indexNumber = idx as Number;
            var bmp = Resources.getDigitBitmap(indexNumber);
            var bmpHeight = roundScaled(bmp.getHeight() * bitmapScale);
            var bmpWidth = roundScaled(bmp.getWidth() * bitmapScale);
            var drawY = top + roundScaled((lineHeight - bmpHeight) / 2.0);
            drawScaledBitmap(dc, startX, drawY, bmp);
            startX += bmpWidth;
            if (i < length - 1) {
                startX += digitSpacing;
            }
        }
    }

    function drawDateDigits(dc as Dc, text as String, startX as Number, top as Number, lineHeight as Number) as Void {
        var length = text.length();
        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup.get(digitChar);
            if (idx == null) {
                continue;
            }
            var indexNumber = idx as Number;
            var bmp = Resources.getDateDigitBitmap(indexNumber);
            var bmpHeight = roundScaled(bmp.getHeight() * bitmapScale);
            var bmpWidth = roundScaled(bmp.getWidth() * bitmapScale);
            var drawY = top + roundScaled((lineHeight - bmpHeight) / 2.0);
            drawScaledBitmap(dc, startX, drawY, bmp);
            startX += bmpWidth;
            if (i < length - 1) {
                startX += dateDigitSpacing;
            }
        }
    }

    function drawMaya(dc as Dc, centerX as Number, tzolkinY as Number, haabY as Number) as Void {
        var numberBmp = Resources.getMayaNumberBitmap(cachedTzolkin["number"] as Number);
        var nameBmp = Resources.getMayaDayBitmap(cachedTzolkin["nameIndex"] as Number);
        var tzolkinTotalW = getScaledWidth(numberBmp) + getScaledWidth(nameBmp);
        var tzolkinLeft = centerX - roundScaled(tzolkinTotalW / 2.0);
        drawScaledBitmap(dc, tzolkinLeft, tzolkinY, numberBmp);
        drawScaledBitmap(dc, tzolkinLeft + getScaledWidth(numberBmp), tzolkinY, nameBmp);

        var haabNumberBmp = Resources.getMayaNumberBitmap(cachedHaab["dayInMonth"] as Number);
        var haabMonthBmp = Resources.getMayaMonthBitmap(cachedHaab["monthIndex"] as Number);
        var haabTotalW = getScaledWidth(haabNumberBmp) + getScaledWidth(haabMonthBmp);
        var haabLeft = centerX - roundScaled(haabTotalW / 2.0);
        drawScaledBitmap(dc, haabLeft, haabY, haabNumberBmp);
        drawScaledBitmap(dc, haabLeft + getScaledWidth(haabNumberBmp), haabY, haabMonthBmp);
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
            if (weekdayIndex < 0 || weekdayIndex >= 7) {
                weekdayIndex = 0;
            }
            cachedWeekdayIndex = weekdayIndex;

            var monthIndex = getNumberValue(infoShort.month, 1) - 1;
            if (monthIndex < 0 || monthIndex >= 12) {
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
        var weekdayBitmap = Resources.getWeekdayBitmap(cachedWeekdayIndex);
        var monthBitmap = Resources.getMonthBitmap(cachedMonthIndex);
        var monthWidth = getScaledWidth(monthBitmap);

        var dateRight = dc.getWidth() - dateMargin;

        var symbolHeight = getScaledHeight(weekdayBitmap);
        var symbolWidth = getScaledWidth(weekdayBitmap);
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

        drawScaledBitmap(dc, symbolLeft as Number, symbolTop as Number, weekdayBitmap);
        drawDateDigitLine(dc, cachedDayString, dayLeft as Number, dayTop as Number, cachedDayWidth, cachedDayHeight);
        drawScaledBitmap(dc, monthLeft as Number, monthTop as Number, monthBitmap);
    }
}

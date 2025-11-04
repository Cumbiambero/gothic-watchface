import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WatchFaceView extends WatchUi.WatchFace {

    private const DIGIT_SPACING = -12;
    private const LINE_SPACING = -40;

    private var digitBitmaps as Array<WatchUi.BitmapResource>;
    private var digitWidths as Array<Number>;
    private var digitHeights as Array<Number>;
    private var digitLookup as Dictionary;

    function initialize() {
        WatchFace.initialize();

    digitBitmaps = [] as Array<WatchUi.BitmapResource>;
    digitWidths = [] as Array<Number>;
    digitHeights = [] as Array<Number>;

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

    // Load resources once the layout is available
    function onLayout(dc as Dc) as Void {
        digitBitmaps = [] as Array<WatchUi.BitmapResource>;
        digitWidths = [] as Array<Number>;
        digitHeights = [] as Array<Number>;

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
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;

        var hoursString = hours.format("%02d");
        var minutesString = minutes.format("%02d");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var hoursMetrics = getLineMetrics(hoursString);
        var minutesMetrics = getLineMetrics(minutesString);

    var totalHeight = hoursMetrics["height"] + minutesMetrics["height"] + LINE_SPACING;
    var startY = (height - totalHeight) / 2 - 15;

        drawDigitLine(dc, hoursString, startY, hoursMetrics);
        drawDigitLine(dc, minutesString, startY + hoursMetrics["height"] + LINE_SPACING, minutesMetrics);
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

    function drawDigitLine(dc as Dc, text as String, top as Number, metrics as Dictionary) as Void {
        var startX = (dc.getWidth() - metrics["width"]) / 2;
        var length = text.length();

        for (var i = 0; i < length; ++i) {
            var digitChar = text.substring(i, i + 1);
            var idx = digitLookup[digitChar];
            var bmp = digitBitmaps[idx];
            var bmpHeight = digitHeights[idx];
            var drawY = top + (metrics["height"] - bmpHeight) / 2;

            dc.drawBitmap(startX, drawY, bmp);

            startX += digitWidths[idx];
            if (i < length - 1) {
                startX += DIGIT_SPACING;
            }
        }
    }
}

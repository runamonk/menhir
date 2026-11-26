import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.WatchUi;

class MenhirView extends WatchUi.WatchFace {
    const IVORY = 0xF2E8D5;
    const DIM = 0x8A8478;

    var _sleeping = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var t = System.getClockTime();
        var hour = t.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var hh = hour.format("%02d");
        var mm = t.min.format("%02d");
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var date = info.day_of_week.toUpper() + " " + info.day.format("%d");

        // AMOLED always-on: small dim date over time, nudged around to spare the pixels
        if (_sleeping && System.getDeviceSettings().requiresBurnInProtection) {
            var dx = (t.min % 5 - 2) * 6;
            var dy = (t.min % 3 - 1) * 6;
            dc.setColor(Cfg.AOD_COLORS[Cfg.aod()], Graphics.COLOR_TRANSPARENT);
            var gap = (dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM) + dc.getFontHeight(Graphics.FONT_SMALL)) / 2;
            dc.drawText(w / 2 + dx, h / 2 - gap + dy, Graphics.FONT_SMALL, date, center);
            dc.drawText(w / 2 + dx, h / 2 + dy, Graphics.FONT_NUMBER_MEDIUM, hh + ":" + mm, center);
            return;
        }

        // Top field above the time
        drawField(dc, w / 2, h * 24 / 100, 0, date, Graphics.TEXT_JUSTIFY_CENTER, Graphics.FONT_SMALL);

        // Time on one line; drop a font size if THAI_HOT is too wide
        var time = hh + ":" + mm;
        var big = Graphics.FONT_NUMBER_THAI_HOT;
        if (dc.getTextWidthInPixels(time, big) > w * 88 / 100) {
            big = Graphics.FONT_NUMBER_HOT;
        }
        dc.setColor(IVORY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 44 / 100, big, time, center);

        // Divider rule, same width as the time
        var tw = dc.getTextWidthInPixels(time, big);
        dc.setColor(Cfg.color(5), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle((w - tw) / 2, h * 63 / 100, tw, 3);

        // Three bottom fields
        // Left and right hug the ends of the rule; middle centers in the gap between them
        // Shrink the whole row a size at a time until it fits the rule with some gap
        var lx = (w - tw) / 2;
        var rx = (w + tw) / 2;
        var fonts = [Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY];
        var font = Graphics.FONT_SMALL;
        var lw = 0;
        var rw = 0;
        for (var i = 0; i < fonts.size(); i++) {
            font = fonts[i];
            lw = fieldWidth(dc, 1, date, font);
            rw = fieldWidth(dc, 3, date, font);
            if (lw + fieldWidth(dc, 2, date, font) + rw + w * 8 / 100 <= tw) { break; }
        }
        var mx = (lx + lw + rx - rw) / 2;
        drawField(dc, lx, h * 71 / 100, 1, date, Graphics.TEXT_JUSTIFY_LEFT, font);
        drawField(dc, mx, h * 71 / 100, 2, date, Graphics.TEXT_JUSTIFY_CENTER, font);
        drawField(dc, rx, h * 71 / 100, 3, date, Graphics.TEXT_JUSTIFY_RIGHT, font);

        // Bottom field, with a step goal bar under it when it shows steps
        drawField(dc, w / 2, h * 83 / 100, 4, date, Graphics.TEXT_JUSTIFY_CENTER, Graphics.FONT_SMALL);
        if (Cfg.field(4) == 3) {
            var am = ActivityMonitor.getInfo();
            if (am.steps != null && am.stepGoal != null && am.stepGoal > 0 && Cfg.curvedBar()) {
                // Arc centered on 6 o'clock, 7 to 5 o'clock (240 to 300 deg), filling left to right
                var r = w / 2 - 6;
                var deg = am.steps * 60 / am.stepGoal;
                if (deg > 60) { deg = 60; }
                if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
                dc.setPenWidth(6);
                dc.setColor(DIM, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(w / 2, h / 2, r, Graphics.ARC_COUNTER_CLOCKWISE, 240, 300);
                if (deg > 0) {
                    dc.setColor(Cfg.color(6), Graphics.COLOR_TRANSPARENT);
                    dc.drawArc(w / 2, h / 2, r, Graphics.ARC_COUNTER_CLOCKWISE, 240, 240 + deg);
                }
                dc.setPenWidth(1);
            } else if (am.steps != null && am.stepGoal != null && am.stepGoal > 0) {
                var bw = w * 30 / 100;
                var bx = (w - bw) / 2;
                var by = h * 89 / 100;
                var fill = am.steps * bw / am.stepGoal;
                if (fill > bw) { fill = bw; }
                dc.setColor(DIM, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(bx, by, bw, 3);
                dc.setColor(Cfg.color(6), Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(bx, by, fill, 3);
            }
        }
    }

    // Slot value in its chosen color, with an icon in front if icons are on
    function drawField(dc, x, y, slot, date, justify, font) {
        var kind = Cfg.field(slot);
        var text = fieldText(kind, date);
        var color = Cfg.color(slot);
        var icon = Cfg.icons() ? iconFor(kind) : null;
        if (icon == null || text.equals("")) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, font, text, justify | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // Icon + gap + text, placed as one block by the justify
        var s = dc.getFontHeight(font) * 55 / 100;
        var gap = s / 3;
        var total = s + gap + dc.getTextWidthInPixels(text, font);
        var left = x;
        if (justify == Graphics.TEXT_JUSTIFY_CENTER) {
            left = x - total / 2;
        } else if (justify == Graphics.TEXT_JUSTIFY_RIGHT) {
            left = x - total;
        }
        Icons.draw(dc, icon, left + s / 2, y, s, color);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + s + gap, y, font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Width of a slot as drawField draws it (icon + gap + text)
    function fieldWidth(dc, slot, date, font) {
        var kind = Cfg.field(slot);
        var text = fieldText(kind, date);
        var fw = dc.getTextWidthInPixels(text, font);
        if (Cfg.icons() && iconFor(kind) != null && !text.equals("")) {
            var s = dc.getFontHeight(font) * 55 / 100;
            fw += s + s / 3;
        }
        return fw;
    }

    // Icon for a field, by its index in Cfg.FIELDS; none for None and Date
    function iconFor(kind) {
        if (kind == 2) { return :bolt; }
        if (kind == 3) { return :steps; }
        if (kind == 4) { return :heart; }
        if (kind == 5) { return :flame; }
        if (kind == 6) { return :pin; }
        if (kind == 7) { return :stairs; }
        if (kind == 8) { return :bell; }
        if (kind == 9) { return Icons.weather(); }
        return null;
    }

    // Text for a field, by its index in Cfg.FIELDS
    function fieldText(kind, date) {
        var am = ActivityMonitor.getInfo();
        var v = null;
        if (kind == 0) {
            return "";
        } else if (kind == 1) {
            return date;
        } else if (kind == 2) {
            return System.getSystemStats().battery.format("%d") + "%";
        } else if (kind == 3) {
            v = am.steps;
            return v == null ? "--" : commas(v);
        } else if (kind == 4) {
            v = Activity.getActivityInfo().currentHeartRate;
        } else if (kind == 5) {
            v = am.calories;
        } else if (kind == 6) {
            // distance is in cm
            if (am.distance == null) { return "--"; }
            if (System.getDeviceSettings().distanceUnits == System.UNIT_METRIC) {
                return (am.distance / 100000.0).format("%.1f") + "km";
            }
            return (am.distance / 160934.4).format("%.1f") + "mi";
        } else if (kind == 7) {
            v = am.floorsClimbed;
        } else if (kind == 8) {
            v = System.getDeviceSettings().notificationCount;
        } else if (kind == 9) {
            // Current temperature from the phone, which reports it in Celsius
            var wx = Weather.getCurrentConditions();
            if (wx == null || wx.temperature == null) { return "--"; }
            var temp = wx.temperature.toFloat();
            if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
                temp = temp * 9 / 5 + 32;
            }
            return temp.format("%.0f") + "°";
        }
        return v == null ? "--" : v.format("%d");
    }

    function onEnterSleep() {
        _sleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _sleeping = false;
        WatchUi.requestUpdate();
    }

    // 8742 -> "8,742"
    function commas(n) {
        var s = n.toString();
        var len = s.length();
        var out = "";
        for (var i = 0; i < len; i++) {
            if (i > 0 && (len - i) % 3 == 0) { out += ","; }
            out += s.substring(i, i + 1);
        }
        return out;
    }
}

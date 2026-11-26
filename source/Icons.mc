import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Weather;

// Small icons drawn from shapes, so they take whatever color the slot uses.
// Coordinates are in units of half the icon size, centered on (cx, cy).
module Icons {
    const SUN = [Weather.CONDITION_CLEAR, Weather.CONDITION_MOSTLY_CLEAR, Weather.CONDITION_FAIR];
    const PARTLY = [Weather.CONDITION_PARTLY_CLOUDY, Weather.CONDITION_PARTLY_CLEAR, Weather.CONDITION_THIN_CLOUDS];
    const RAIN = [Weather.CONDITION_RAIN, Weather.CONDITION_SCATTERED_SHOWERS, Weather.CONDITION_UNKNOWN_PRECIPITATION,
        Weather.CONDITION_LIGHT_RAIN, Weather.CONDITION_HEAVY_RAIN, Weather.CONDITION_LIGHT_SHOWERS, Weather.CONDITION_SHOWERS,
        Weather.CONDITION_HEAVY_SHOWERS, Weather.CONDITION_CHANCE_OF_SHOWERS, Weather.CONDITION_DRIZZLE,
        Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN, Weather.CONDITION_FREEZING_RAIN];
    const SNOW = [Weather.CONDITION_SNOW, Weather.CONDITION_WINTRY_MIX, Weather.CONDITION_HAIL, Weather.CONDITION_LIGHT_SNOW,
        Weather.CONDITION_HEAVY_SNOW, Weather.CONDITION_LIGHT_RAIN_SNOW, Weather.CONDITION_HEAVY_RAIN_SNOW, Weather.CONDITION_RAIN_SNOW,
        Weather.CONDITION_ICE, Weather.CONDITION_CHANCE_OF_SNOW, Weather.CONDITION_CHANCE_OF_RAIN_SNOW,
        Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW, Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW, Weather.CONDITION_FLURRIES,
        Weather.CONDITION_SLEET, Weather.CONDITION_ICE_SNOW];
    const STORM = [Weather.CONDITION_THUNDERSTORMS, Weather.CONDITION_SCATTERED_THUNDERSTORMS,
        Weather.CONDITION_CHANCE_OF_THUNDERSTORMS, Weather.CONDITION_TORNADO, Weather.CONDITION_SQUALL,
        Weather.CONDITION_HURRICANE, Weather.CONDITION_TROPICAL_STORM];
    const FOG = [Weather.CONDITION_FOG, Weather.CONDITION_HAZY, Weather.CONDITION_MIST, Weather.CONDITION_DUST,
        Weather.CONDITION_SMOKE, Weather.CONDITION_SAND, Weather.CONDITION_SANDSTORM, Weather.CONDITION_VOLCANIC_ASH,
        Weather.CONDITION_HAZE];

    const BOLT = [[0.2, -1], [-0.6, 0.15], [-0.05, 0.15], [-0.2, 1], [0.6, -0.15], [0.05, -0.15]];
    const SMALL_BOLT = [[0.08, 0.2], [-0.24, 0.66], [-0.02, 0.66], [-0.08, 1.0], [0.24, 0.54], [0.02, 0.54]];
    // Tall tongue on the right, small one on the left
    const FLAME = [[0.1, -1], [0.55, -0.35], [0.7, 0.3], [0.45, 0.85], [0, 1], [-0.45, 0.85], [-0.7, 0.3],
        [-0.55, -0.3], [-0.3, 0.0], [-0.15, -0.5]];
    const STAIRS = [[-1, 1], [-1, 0.5], [-0.33, 0.5], [-0.33, 0], [0.33, 0], [0.33, -0.5], [1, -0.5], [1, 1]];
    const RAYS = [[1, 0], [0.71, 0.71], [0, 1], [-0.71, 0.71], [-1, 0], [-0.71, -0.71], [0, -1], [0.71, -0.71]];

    // Icon for the current weather; moon instead of sun at night
    function weather() {
        var wx = Weather.getCurrentConditions();
        if (wx == null || wx.condition == null) { return :cloud; }
        var c = wx.condition;
        if (SUN.indexOf(c) >= 0) { return isNight(wx) ? :moon : :sun; }
        if (PARTLY.indexOf(c) >= 0) { return :partly; }
        if (RAIN.indexOf(c) >= 0) { return :rain; }
        if (SNOW.indexOf(c) >= 0) { return :snow; }
        if (STORM.indexOf(c) >= 0) { return :storm; }
        if (FOG.indexOf(c) >= 0) { return :fog; }
        return :cloud;
    }

    // Sunrise/sunset at the weather location; 6am-6pm if that's not known
    function isNight(wx) {
        var now = Time.now();
        var loc = wx.observationLocationPosition;
        if (loc != null) {
            var sr = Weather.getSunrise(loc, now);
            var ss = Weather.getSunset(loc, now);
            if (sr != null && ss != null) {
                return now.value() < sr.value() || now.value() > ss.value();
            }
        }
        var hr = System.getClockTime().hour;
        return hr < 6 || hr >= 18;
    }

    function draw(dc, icon, cx, cy, s, color) {
        var u = s / 2.0;
        var pen = s / 10;
        if (pen < 2) { pen = 2; }
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (icon == :bolt) {
            poly(dc, cx, cy, u, BOLT);
        } else if (icon == :steps) {
            dc.fillEllipse(cx - 0.4 * u, cy + 0.1 * u, 0.27 * u, 0.42 * u);
            dc.fillCircle(cx - 0.4 * u, cy + 0.8 * u, 0.2 * u);
            dc.fillEllipse(cx + 0.4 * u, cy - 0.4 * u, 0.27 * u, 0.42 * u);
            dc.fillCircle(cx + 0.4 * u, cy + 0.3 * u, 0.2 * u);
        } else if (icon == :heart) {
            dc.fillCircle(cx - 0.45 * u, cy - 0.3 * u, 0.5 * u);
            dc.fillCircle(cx + 0.45 * u, cy - 0.3 * u, 0.5 * u);
            poly(dc, cx, cy, u, [[-0.93, -0.1], [0.93, -0.1], [0, 0.95]]);
        } else if (icon == :flame) {
            poly(dc, cx, cy, u, FLAME);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy + 0.55 * u, 0.22 * u);
        } else if (icon == :pin) {
            dc.fillCircle(cx, cy - 0.35 * u, 0.55 * u);
            poly(dc, cx, cy, u, [[-0.48, -0.08], [0.48, -0.08], [0, 1]]);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy - 0.35 * u, 0.22 * u);
        } else if (icon == :stairs) {
            poly(dc, cx, cy, u, STAIRS);
        } else if (icon == :bell) {
            dc.fillCircle(cx, cy - 0.8 * u, 0.15 * u);
            dc.fillCircle(cx, cy - 0.15 * u, 0.6 * u);
            dc.fillRectangle(cx - 0.6 * u, cy - 0.15 * u, 1.2 * u, 0.7 * u);
            dc.fillRectangle(cx - 0.85 * u, cy + 0.45 * u, 1.7 * u, 0.2 * u);
            dc.fillCircle(cx, cy + 0.82 * u, 0.18 * u);
        } else if (icon == :sun) {
            dc.fillCircle(cx, cy, 0.45 * u);
            dc.setPenWidth(pen);
            for (var i = 0; i < RAYS.size(); i++) {
                var d = RAYS[i];
                dc.drawLine(cx + d[0] * 0.68 * u, cy + d[1] * 0.68 * u, cx + d[0] * 0.98 * u, cy + d[1] * 0.98 * u);
            }
            dc.setPenWidth(1);
        } else if (icon == :moon) {
            dc.fillCircle(cx, cy, 0.8 * u);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx + 0.4 * u, cy - 0.3 * u, 0.65 * u);
        } else if (icon == :partly) {
            // Sun peeking out, cloud in front with a black edge so they don't merge
            dc.fillCircle(cx - 0.4 * u, cy - 0.4 * u, 0.38 * u);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            cloud(dc, cx + 0.15 * u, cy + 0.25 * u, u, 0.12);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            cloud(dc, cx + 0.15 * u, cy + 0.25 * u, u, 0);
        } else if (icon == :rain) {
            cloud(dc, cx, cy - 0.35 * u, u, 0);
            dc.setPenWidth(pen);
            for (var x = -0.4; x < 0.5; x += 0.4) {
                dc.drawLine(cx + (x + 0.1) * u, cy + 0.4 * u, cx + (x - 0.1) * u, cy + 0.9 * u);
            }
            dc.setPenWidth(1);
        } else if (icon == :snow) {
            cloud(dc, cx, cy - 0.35 * u, u, 0);
            dc.fillCircle(cx - 0.45 * u, cy + 0.6 * u, 0.13 * u);
            dc.fillCircle(cx, cy + 0.85 * u, 0.13 * u);
            dc.fillCircle(cx + 0.45 * u, cy + 0.6 * u, 0.13 * u);
        } else if (icon == :storm) {
            cloud(dc, cx, cy - 0.35 * u, u, 0);
            poly(dc, cx, cy, u, SMALL_BOLT);
        } else if (icon == :fog) {
            for (var y = -0.5; y < 0.6; y += 0.5) {
                dc.fillRoundedRectangle(cx - 0.9 * u, cy + (y - 0.1) * u, 1.8 * u, 0.2 * u, 0.1 * u);
            }
        } else {
            cloud(dc, cx, cy, u, 0);
        }
    }

    // Three bumps on a flat base; g grows it (used for the black edge)
    function cloud(dc, cx, cy, u, g) {
        dc.fillCircle(cx - 0.45 * u, cy + 0.15 * u, (0.4 + g) * u);
        dc.fillCircle(cx + 0.1 * u, cy - 0.15 * u, (0.5 + g) * u);
        dc.fillCircle(cx + 0.5 * u, cy + 0.2 * u, (0.35 + g) * u);
        dc.fillRectangle(cx - 0.45 * u, cy + 0.15 * u, 0.95 * u, (0.4 + g) * u);
    }

    function poly(dc, cx, cy, u, pts) {
        var out = new [pts.size()];
        for (var i = 0; i < pts.size(); i++) {
            out[i] = [cx + pts[i][0] * u, cy + pts[i][1] * u];
        }
        dc.fillPolygon(out);
    }
}

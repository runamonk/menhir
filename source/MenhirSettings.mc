import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Slot settings live in Storage as "f0".."f4" (field) and "c0".."c4" (color index).
// Slots: 0 top, 1 left, 2 middle, 3 right, 4 bottom.
module Cfg {
    const SLOTS = ["Top", "Left", "Middle", "Right", "Bottom"];
    const FIELDS = ["None", "Date", "Battery", "Steps", "Heart rate", "Calories", "Distance", "Floors", "Notifications", "Weather"];
    const COLOR_NAMES = ["Ivory", "Dim", "Coral", "White", "Red", "Orange", "Yellow", "Green", "Blue", "Purple"];
    const COLORS = [0xF2E8D5, 0x8A8478, 0xFF6F5E, 0xFFFFFF, 0xFF3B30, 0xFF9500, 0xFFD60A, 0x34C759, 0x0A84FF, 0xBF5AF2];
    const DEF_FIELD = [1, 2, 4, 9, 3];
    const DEF_COLOR = [1, 0, 0, 0, 0];

    function field(i) {
        var v = Storage.getValue("f" + i);
        return v == null ? DEF_FIELD[i] : v;
    }

    // Step goal bar style, stored as "bar": 0 curved (default), 1 straight
    const BAR_NAMES = ["Curved", "Straight"];

    function curvedBar() {
        var v = Storage.getValue("bar");
        return v == null || v == 0;
    }

    // Field icons, stored as "icons": 0 on (default), 1 off
    const ONOFF = ["On", "Off"];

    function icons() {
        var v = Storage.getValue("icons");
        return v == null || v == 0;
    }

    function color(i) {
        var v = Storage.getValue("c" + i);
        return COLORS[v == null ? DEF_COLOR[i] : v];
    }
}

class MenhirSettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Watch Face"});
        for (var i = 0; i < Cfg.SLOTS.size(); i++) {
            var c = Storage.getValue("c" + i);
            addItem(new WatchUi.MenuItem(Cfg.SLOTS[i] + " field", Cfg.FIELDS[Cfg.field(i)], "f" + i, null));
            addItem(new WatchUi.MenuItem(Cfg.SLOTS[i] + " color", Cfg.COLOR_NAMES[c == null ? Cfg.DEF_COLOR[i] : c], "c" + i, null));
        }
        addItem(new WatchUi.MenuItem("Step bar", Cfg.BAR_NAMES[Cfg.curvedBar() ? 0 : 1], "bar", null));
        addItem(new WatchUi.MenuItem("Icons", Cfg.ONOFF[Cfg.icons() ? 0 : 1], "icons", null));
    }
}

// Selecting an item steps it to the next option
class MenhirSettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId() as String;
        if (id.equals("bar")) {
            var b = Cfg.curvedBar() ? 1 : 0;
            Storage.setValue("bar", b);
            item.setSubLabel(Cfg.BAR_NAMES[b]);
            return;
        }
        if (id.equals("icons")) {
            var n = Cfg.icons() ? 1 : 0;
            Storage.setValue("icons", n);
            item.setSubLabel(Cfg.ONOFF[n]);
            return;
        }
        var i = id.substring(1, 2).toNumber();
        var isField = id.substring(0, 1).equals("f");
        var names = isField ? Cfg.FIELDS : Cfg.COLOR_NAMES;
        var v = Storage.getValue(id);
        if (v == null) { v = isField ? Cfg.DEF_FIELD[i] : Cfg.DEF_COLOR[i]; }
        v = (v + 1) % names.size();
        Storage.setValue(id, v);
        item.setSubLabel(names[v]);
    }
}

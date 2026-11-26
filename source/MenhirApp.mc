import Toybox.Application;
import Toybox.WatchUi;

class MenhirApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new MenhirView()];
    }

    // On-watch settings (sideloaded faces get no phone settings)
    function getSettingsView() {
        return [new MenhirSettingsMenu(), new MenhirSettingsDelegate()];
    }
}

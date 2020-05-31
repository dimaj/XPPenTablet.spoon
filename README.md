XPPenTablet.Spoon
=================

This is a spoon (module) to a great piece of sotware called [hammerspoon](http://www.hammerspoon.org/)

The purpose for this spoon is to modify monitor mapping settings to the XP-Pen tablet devices without having to open up PenTabletSettings application, since PenTabletSettings appliation does not provide a way to configure monitor mapping based on a running application settings.

This is great when you want to scope your tablet's mapping to a single application window.

Sample Configuration
--------------------
Add the following block to your hammerspoon configuration file:
```
spoon.SpoonInstall:andUse("XPPenTablet", {
    config = {
        deviceName = "DEV_6298_3936",
        configLocation = "~/.PenTabletConfig/com.ugee.PenTabletSettings.plist"
    },
    hotkeys = {
        current_window = {{"shift", "alt"}, "w"}
    },
    start = true,
    repo = "https://github.com/dimaj/XPPenTablet.spoon"
})
```

This will install this spoon for you and map `Shift` + `Alt` + `W` keys to updating currently active window as mapping area of your tablet.

Configuration:

| Option Name | Description | Required? |
|-------------|-------------|-----------|
| config.deviceName  | Internal name of your drawing tablet. More informataion on how to get it can be found [here](https://github.com/dimaj/XPPenTablet.spoon/wiki/How-to-get-device-name) | yes |
| config.configLocation | Location where PenTabletSettings application looks for configuration data. Defaults to `~/.PenTabletConfig/com.ugee.PenTabletSettings.plis` | no |
| start | must be set to `true` to initalize this module | yes |


API Documentation
-----------------

| Method Name | Description | Parameters |
|-------------|-------------|------------|
| updateForActiveWindow()| Updates config based on currently active window ||
| updateConfigForApp(appName) | Updates config based on the main window of specified application | `appName` - Application name to bind table to. E.g. `Skitch` |

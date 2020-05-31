--- ==== XPPenTablet ====
---
--- Configure 'Monitor Mapping' settings for XP-Pen tablets without opening settings application
---
--- Use Case: You have multiple windows, where you want to draw/write on, but you want your tablet to
---           work only one of those windows. Instead of opening up the PenTabletSettings application
---           and manually changing all the values, this spoon is going to configure mapping area
---           based on currently active window or based on a window with a given name (e.g. 'Skitch')
---
--- Sample configuration:
--- ```
--- spoon.SpoonInstall:andUse("XPPenTablet", {
---     config = {
---         deviceName = "DEV_6298_3936",
---         configLocation = "~/.PenTabletConfig/com.ugee.PenTabletSettings.plist"
---     },
---     hotkeys = {
---         current_window = {{"shift", "alt"}, "w"}
---     },
---     start = true,
---     repo = "https://github.com/dimaj/XPPenTablet.spoon"
--- })
--- ```
--- If `XPPenTablet.configLocation` is not set, it will have a default value of `~/.PenTabletConfig/com.ugee.PenTabletSettings.plist`

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "XPPenTablet";
obj.version = "0.1";
obj.author = "Dmitry Jerusalimsky <djerusalimsky@gmail.com>";
obj.license = 'MIT - https://opensource.org/licenses/MIT'
obj.homepage = 'https://github.com/dimaj/XPPenTablet.spoon'


--- XPPenTablet.deviceName
--- Variable
--- Model number of your XP-Pen tablet
--- More information can be found here: https://github.com/dimaj/XPPenTablet.spoon/wiki/How-to-get-device-name
obj.deviceName = nil;

--- XPPenTablet.configLocation
--- Variable
--- Location where XP-Pen software keeps its configuration.
obj.configLocation = "~/.PenTabletConfig/com.ugee.PenTabletSettings.plist";

-- Internal variable: Key binding for updating config
obj.key_current_window = nil;

--- XPPenTablet.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new("XPPenTablet")

-- Internal variable: for config storage
obj.config = nil;

--//////////////////////////
--/// private methods ///---
--//////////////////////////
-- runs a shell script to restart pentablet driver
local function restartPenDriver()
    local result, response, code = hs.osascript.applescript(
        string.format([[
            do shell script "launchctl stop com.ugee.pentablet && launchctl start com.ugee.pentablet; "
        ]])
    );
    local message = result and "Config updated" or "Update failed"
    hs.notify.show("XPPenTablet", message, "");
end

-- updates configuration file based on frame information
local function updateConfigWithFrame(frame)
    local newValues =  {
        PortionHeight = frame._h;
        PortionWidth = frame._w;
        PortionOffsetX = frame._x;
        PortionOffsetY = frame._y;
    };

    for k, v in pairs(newValues) do obj.config[obj.deviceName][k] = v end

    hs.plist.write(obj.configLocation, obj.config);

    restartPenDriver();
end


--/////////////////////////
--/// public methods ///---
--/////////////////////////

--- XPPenTablet:start()
--- Method
--- Makes sure that all fields have been initialized and reads in configuration file
function obj:start()
    assert(self.deviceName, "'deviceName' must be provided");
    assert(self.configLocation, "'configLocation' must be provided");
    self.config = hs.plist.read(self.configLocation);
end

--- XPPenTablet:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for XPPenTablet
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * current_window - gets frame of currently active window and saves it to XP-Pen's config
function obj:bindHotkeys(mapping)
    self.logger.d("here")
   if mapping["current_window"] then
      if (self.key_current_window) then
         self.key_current_window:delete()
      end
      self.key_current_window = hs.hotkey.bindSpec(mapping["current_window"], self.updateForActiveWindow);
   end
end

--- XPPenTablet:updateForActiveWindow()
--- Method
--- Saves X, Y, W, H of currenlty active window into XP-Pen's settings file and restarts XP-Pen driver
function obj:updateForActiveWindow()
    local frame = hs.window.frontmostWindow():frame();
    updateConfigWithFrame(frame);
end


--- XPPenTablet:updateConfigForApp()
--- Method
--- Saves X, Y, W, H of sepcified application's main window into XP-Pen's settings file and restarts XP-Pen driver
---
--- Parameters:
---  * appName - Name of the application to get coordinates for
function obj:updateConfigForApp(appName)
    if not appName then
        self.logger.e("'appName' is a required parameter. exiting");
        return;
    end

    local app = hs.application(appName);
    if not app then
        self.logger.e("Could not find application '" .. appName .. "'");
        return;
    end

    local frame = hs.application.mainWindow(app):frame();
    updateConfigWithFrame(frame);
end


return obj;

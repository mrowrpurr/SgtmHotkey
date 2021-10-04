scriptName SgtmHotkey extends ReferenceAlias  

; Note: this will get out-of-sync if you use the console to `sgtm`
;       and you cannot get it back in sync until you load a save
float CurrentSGTM = 1.0

int LEFT_SHIFT  = 42
int RIGHT_SHIFT = 54
int LEFT_CTRL   = 29
int RIGHT_CTRL  = 157
int LEFT_ALT    = 56
int RIGHT_ALT   = 184

string property JSON_CONFIG_FILE = "Data\\SgtmHotkey\\Config.json" autoReadonly

; Primary configuration for SGTM Hotkey
int property Configuration auto
bool property IsReady auto

; When the mod is installed
event OnInit()
    Startup()
endEvent

; When the player loads a save game
event OnPlayerLoadGame()
    Startup()
endEvent

function Startup()
    CurrentSGTM = 1.0

    LoadConfigurationFromFileOrInitialize()

    ; Start listening!
    ListenForHotkeys()
endFunction

function LoadConfigurationFromFileOrInitialize()
    int configFromFile = JValue.readFromFile(JSON_CONFIG_FILE)
    if configFromFile
        Configuration = configFromFile
        JValue.retain(Configuration)
    else
        SetupConfiguration()
    endIf
    IsReady = true
endFunction

function SetupConfiguration()
    Configuration = JMap.object()
    JValue.retain(Configuration)
    int shortcuts = JMap.object()
    JMap.setObj(Configuration,  "Shortcuts", shortcuts)
    JMap.setStr(Configuration,  "ShowNotification", "false")
    JMap.setFlt(Configuration,  "MaxRangeValue",    10.0)
    JMap.setFlt(Configuration,  "MaxIntervalValue", 1.0)
    JMap.setObj(shortcuts,      "Normal",           JMap.object())
    JMap.setObj(shortcuts,      "Slow",             JMap.object())
    JMap.setObj(shortcuts,      "Fast",             JMap.object())
    JMap.setObj(shortcuts,      "SlowDown",         JMap.object())
    JMap.setObj(shortcuts,      "SpeedUp",          JMap.object())
    JMap.setFlt(NormalConfig,   "value", 1.0)
    JMap.setFlt(SlowConfig,     "value", 0.5)
    JMap.setFlt(FastConfig,     "value", 2.5)
    JMap.setFlt(SlowDownConfig, "value", 0.1)
    JMap.setFlt(SpeedUpConfig,  "value", 0.1)
    JMap.setStr(NormalConfig,   "type", "exact")
    JMap.setStr(SlowConfig,     "type", "exact")
    JMap.setStr(FastConfig,     "type", "exact")
    JMap.setStr(SlowDownConfig, "type", "reduce")
    JMap.setStr(SpeedUpConfig,  "type", "increase")
endFunction

bool property ShowNotification
    bool function get()
        return JMap.getStr(Configuration, "ShowNotification") == "true"
    endFunction
    function set(bool value)
        if value
            JMap.setStr(Configuration, "ShowNotification", "true")
        else
            JMap.setStr(Configuration, "ShowNotification", "false")
        endIf
    endFunction
endProperty

float property MaxRangeValue
    float function get()
        return JMap.getFlt(Configuration, "MaxRangeValue")
    endFunction
endProperty

float property MaxIntervalValue
    float function get()
        return JMap.getFlt(Configuration, "MaxIntervalValue")
    endFunction
endProperty

int property ShortcutConfigsMap
    int function get()
        return JMap.getObj(Configuration, "Shortcuts")
    endFunction
endProperty

int property NormalConfig
    int function get()
        return JMap.getObj(ShortcutConfigsMap, "Normal")
    endFunction
endProperty

int property SlowConfig
    int function get()
        return JMap.getObj(ShortcutConfigsMap, "Slow")
    endFunction
endProperty

int property FastConfig
    int function get()
        return JMap.getObj(ShortcutConfigsMap, "Fast")
    endFunction
endProperty

int property SlowDownConfig
    int function get()
        return JMap.getObj(ShortcutConfigsMap, "SlowDown")
    endFunction
endProperty

int property SpeedUpConfig
    int function get()
        return JMap.getObj(ShortcutConfigsMap, "SpeedUp")
    endFunction
endProperty

int function GetConfigForKey(int keyCode, bool shift, bool ctrl, bool alt)
    string[] configNames = JMap.allKeysPArray(ShortcutConfigsMap)
    int[] configs = Utility.CreateIntArray(configNames.Length)
    int i = 0
    while i < configNames.Length
        int config = JMap.getObj(ShortcutConfigsMap, configNames[i])
        if JMap.getInt(config, "key") == keyCode
            bool match = true
            if (shift && JMap.getStr(config, "shift") != "true") || (JMap.getStr(config, "shift") == "true" && ! shift)
                match = false
            endIf
            if (ctrl && JMap.getStr(config, "ctrl") != "true") || (JMap.getStr(config, "ctrl") == "true" && ! ctrl)
                match = false
            endIf
            if (alt && JMap.getStr(config, "alt") != "true") || (JMap.getStr(config, "alt") == "true" && ! alt)
                match = false
            endIf
            if match
                return config ; Matches the key code and all Shift/Ctrl/Alt requirements
            endIf
        endIf
        i += 1
    endWhile
    return 0
endFunction

int[] function GetAllRegisteredKeyCodes()
    int[] keyCodes
    string[] configNames = JMap.allKeysPArray(ShortcutConfigsMap)
    int i = 0
    while i < configNames.Length
        int config = JMap.getObj(ShortcutConfigsMap, configNames[i])
        int keyCode = JMap.getInt(config, "key")
        if keyCode
            if keyCodes
                if keyCodes.Find(keyCode) == -1
                    keyCodes = Utility.ResizeIntArray(keyCodes, keyCodes.Length + 1)
                    keyCodes[keyCodes.Length - 1] = keyCode
                endIf
            else
                keyCodes = new int[1]
                keyCodes[0] = keyCode
            endIf
        endIf
        i += 1
    endWhile
    return keyCodes
endFunction

; When a save game loads, re-register for all keys
function ListenForHotkeys()
    int[] keyCodes = GetAllRegisteredKeyCodes()
    int i = 0
    while i < keyCodes.Length
        RegisterForKey(keyCodes[i])
        i += 1
    endWhile
endFunction

; Stop listening for previous code, and listen for new code!
; For simplicity, we remove handlers and re-add them all.
function HotkeyUpdated()
    UnregisterForAllKeys()
    ListenForHotkeys()
endFunction

event OnKeyDown(int keyCode)
    bool isShiftPressed = Input.IsKeyPressed(LEFT_SHIFT) || Input.IsKeyPressed(RIGHT_SHIFT)
    bool isCtrlPressed  = Input.IsKeyPressed(LEFT_CTRL)  || Input.IsKeyPressed(RIGHT_CTRL)
    bool isAltPressed   = Input.IsKeyPressed(LEFT_ALT)   || Input.IsKeyPressed(RIGHT_ALT)

    if UI.IsTextInputEnabled() ; Someone is typing into a textbox
        return ; We don't want to process shortcuts when someone's typing in a textbox
    endIf

    int config = GetConfigForKey(keyCode, isShiftPressed, isCtrlPressed, isAltPressed)
    if config
        string type = JMap.getStr(config, "type")
        float value = JMap.getFlt(config, "value")

        if type == "exact"
            CurrentSGTM = value
        elseIf type == "reduce"
            CurrentSGTM = CurrentSGTM - value
            if CurrentSGTM < 0.0
                CurrentSGTM = 0.0
            endIf
        elseIf type == "increase"
            CurrentSGTM = CurrentSGTM + value
        endIf

        string[] valueParts = StringUtil.Split(CurrentSGTM, ".")
        string newValue = valueParts[0] + "." + StringUtil.Substring(valueParts[1], 0, 2) ; 2 decimal resolution

        if ShowNotification
            Debug.Notification("sgtm " + newValue)
        endIf
        ConsoleUtil.PrintMessage("sgtm " + newValue)
        ConsoleUtil.ExecuteCommand("sgtm " + newValue)
    endIf
endEvent

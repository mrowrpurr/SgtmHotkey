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

; Primary configuration for SGTM Hotkey
int property Configuration auto
bool property IsReady auto

; When the mod is installed
event OnInit()
    SetupConfiguration() ; Setup configuration data
endEvent

; When the player loads a save game
event OnPlayerLoadGame()
    CurrentSGTM = 1.0
    ; Load Configuration from file if it's available
    int configFromFile = JValue.readFromFile("Data\\SgtmHotkey\\Config.json")
    if configFromFile
        Configuration = configFromFile
    endIf
    ; Start listening!
    ListenForHotkeys()
endEvent

function SetupConfiguration()
    if Configuration
        return
    endIf

    Configuration = JMap.object()
    JValue.retain(Configuration)
    JMap.setFlt(Configuration,  "MaxRangeValue",    10.0)
    JMap.setFlt(Configuration,  "MaxIntervalValue", 1.0)
    JMap.setObj(Configuration,  "Normal",           JMap.object())
    JMap.setObj(Configuration,  "Slow",             JMap.object())
    JMap.setObj(Configuration,  "Fast",             JMap.object())
    JMap.setObj(Configuration,  "SlowDown",         JMap.object())
    JMap.setObj(Configuration,  "SpeedUp",          JMap.object())
    JMap.setObj(Configuration,  "ConfigByKeyCode",  JIntMap.object())
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
    IsReady = true
endFunction

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

int property NormalConfig
    int function get()
        return JMap.getObj(Configuration, "Normal")
    endFunction
endProperty

int property SlowConfig
    int function get()
        return JMap.getObj(Configuration, "Slow")
    endFunction
endProperty

int property FastConfig
    int function get()
        return JMap.getObj(Configuration, "Fast")
    endFunction
endProperty

int property SlowDownConfig
    int function get()
        return JMap.getObj(Configuration, "SlowDown")
    endFunction
endProperty

int property SpeedUpConfig
    int function get()
        return JMap.getObj(Configuration, "SpeedUp")
    endFunction
endProperty

int property ConfigByKeyMap
    int function get()
        return JMap.getObj(Configuration, "ConfigByKeyCode")
    endFunction
endProperty

; When a save game loads, re-register for all keys
function ListenForHotkeys()
    int[] keyCodes = JIntMap.allKeysPArray(ConfigByKeyMap)
    int i = 0
    while i < keyCodes.Length
        RegisterForKey(keyCodes[i])
        i += 1
    endWhile
endFunction

; Stop listening for previous code,and listen for new code!
function ListenToNewKeyCode(int oldKeyCode, int newKeyCode, int config)
    UnregisterForKey(oldKeyCode)
    JIntMap.removeKey(ConfigByKeyMap, oldKeyCode)
    JIntMap.setObj(ConfigByKeyMap, newKeyCode, config)
    RegisterForKey(newKeyCode)
endFunction

event OnKeyDown(int keyCode)
    if UI.IsTextInputEnabled() ; Someone is typing into a textbox
        return ; We don't want to process shortcuts when someone's typing in a textbox
    endIf

    int config = JIntMap.getObj(ConfigByKeyMap, keyCode)
    if config
        bool runCommand = true
        if JMap.getStr(config, "shift") == "true"
            if ! Input.IsKeyPressed(LEFT_SHIFT) && ! Input.IsKeyPressed(RIGHT_SHIFT)
                runCommand = false
            endIf
        endIf
        if runCommand && JMap.getStr(config, "ctrl") == "true"
            if ! Input.IsKeyPressed(LEFT_CTRL) && ! Input.IsKeyPressed(RIGHT_CTRL)
                runCommand = false
            endIf
        endIf
        if runCommand && JMap.getStr(config, "alt") == "true"
            if ! Input.IsKeyPressed(LEFT_ALT) && ! Input.IsKeyPressed(RIGHT_ALT)
                runCommand = false
            endIf
        endIf

        if runCommand
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
            ConsoleUtil.ExecuteCommand("sgtm " + CurrentSGTM)
        endIf
    endIf
endEvent

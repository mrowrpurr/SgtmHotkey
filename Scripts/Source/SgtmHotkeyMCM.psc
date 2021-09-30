scriptName SgtmHotkeyMCM extends SKI_ConfigBase

; Save Configuration
int oid_SaveConfig

; Normal
int oid_Normal_Slider
int oid_Normal_Keymap
int oid_Normal_Shift
int oid_Normal_Ctrl
int oid_Normal_Alt

; Slow
int oid_Slow_Slider
int oid_Slow_Keymap
int oid_Slow_Shift
int oid_Slow_Ctrl
int oid_Slow_Alt

; Fast
int oid_Fast_Slider
int oid_Fast_Keymap
int oid_Fast_Shift
int oid_Fast_Ctrl
int oid_Fast_Alt

; Slow Down
int oid_SlowDown_Slider
int oid_SlowDown_Keymap
int oid_SlowDown_Shift
int oid_SlowDown_Ctrl
int oid_SlowDown_Alt

; Speed Up
int oid_SpeedUp_Slider
int oid_SpeedUp_Keymap
int oid_SpeedUp_Shift
int oid_SpeedUp_Ctrl
int oid_SpeedUp_Alt

; Reference to SgtmHotkey
; to let it know about hotkey updates!
SgtmHotkey _sgtmHotkey
SgtmHotkey property HotkeyScript
    SgtmHotkey function get()
        if ! _sgtmHotkey
            SgtmHotkey script = GetAliasByName("PlayerRef") as SgtmHotkey
            while ! script.IsReady
                Utility.WaitMenuMode(0.1)
            endWhile
            _sgtmHotkey = script
        endIf
        return _sgtmHotkey
    endFunction
endProperty

event OnConfigInit()
    ModName = "SGTM Hotkey"
endEvent

event OnPageReset(string pageName)
    SetCursorFillMode(TOP_TO_BOTTOM)
    LeftColumn()
    SetCursorPosition(1)
    RightColumn()
endEvent

function LeftColumn()
    AddHeaderOption("Shortcut to switch to Normal game time")
    oid_Normal_Slider = AddSliderOption("SGTM Normal Time", JMap.getFlt(HotkeyScript.NormalConfig, "value"), "{1}")
    oid_Normal_Keymap = AddKeyMapOption("Shortcut to switch to Normal time", 0)
    oid_Normal_Shift = AddToggleOption("Shift", false)
    oid_Normal_Ctrl = AddToggleOption("Ctrl", false)
    oid_Normal_Alt = AddToggleOption("Alt", false)

    AddEmptyOption()
    AddHeaderOption("Shortcut to switch to Slow game time")
    oid_Slow_Slider = AddSliderOption("SGTM Slow Time", JMap.getFlt(HotkeyScript.SlowConfig, "value"), "{1}")
    oid_Slow_Keymap = AddKeyMapOption("Shortcut to switch to Slow time", 0)
    oid_Slow_Shift = AddToggleOption("Shift", false)
    oid_Slow_Ctrl = AddToggleOption("Ctrl", false)
    oid_Slow_Alt = AddToggleOption("Alt", false)

    AddEmptyOption()
    AddHeaderOption("Shortcut to switch to Fast game time")
    oid_Fast_Slider = AddSliderOption("SGTM Fast Time", JMap.getFlt(HotkeyScript.FastConfig, "value"), "{1}")
    oid_Fast_Keymap = AddKeyMapOption("Shortcut to switch to Fast time", 0)
    oid_Fast_Shift = AddToggleOption("Shift", false)
    oid_Fast_Ctrl = AddToggleOption("Ctrl", false)
    oid_Fast_Alt = AddToggleOption("Alt", false)
endFunction

function RightColumn()
    oid_SaveConfig = AddTextOption("Save As Default Configuration", "Save Config")
    AddEmptyOption()

    AddHeaderOption("Shortcut to Slow Down game time by interval")
    oid_SlowDown_Slider = AddSliderOption("Interval to SlowDown Down on key press", JMap.getFlt(HotkeyScript.SlowDownConfig, "value"), "{1}")
    oid_SlowDown_Keymap = AddKeyMapOption("Shortcut to Slow Down time by Interval", 0)
    oid_SlowDown_Shift = AddToggleOption("Shift", false)
    oid_SlowDown_Ctrl = AddToggleOption("Ctrl", false)
    oid_SlowDown_Alt = AddToggleOption("Alt", false)

    AddEmptyOption()
    AddHeaderOption("Shortcut to Speed Up game time by interval")
    oid_SpeedUp_Slider = AddSliderOption("Interval to Speed Up on key press", JMap.getFlt(HotkeyScript.SpeedUpConfig, "value"), "{1}")
    oid_SpeedUp_Keymap = AddKeyMapOption("Shortcut to Speed Up time by Interval", 0)
    oid_SpeedUp_Shift = AddToggleOption("Shift", false)
    oid_SpeedUp_Ctrl = AddToggleOption("Ctrl", false)
    oid_SpeedUp_Alt = AddToggleOption("Alt", false)
endFunction

; Key Map Changes
event OnOptionKeyMapChange(int optionId, int keyCode, string conflictControl, string conflictName)
    int config
    if optionId == oid_Normal_Keymap
        config = HotkeyScript.NormalConfig
    elseIf optionId == oid_Slow_Keymap
        config = HotkeyScript.SlowConfig
    elseIf optionId == oid_Fast_Keymap
        config = HotkeyScript.FastConfig
    elseIf optionId == oid_SlowDown_Keymap
        config = HotkeyScript.SlowDownConfig
    elseIf optionId == oid_SpeedUp_Keymap
        config = HotkeyScript.SpeedUpConfig
    endIf
    int currentKey = JMap.getInt(config, "key")
    JMap.setInt(config, "key", keyCode)
    HotkeyScript.ListenToNewKeyCode(currentKey, keyCode, config)
    SetKeyMapOptionValue(optionId, keyCode)
endEvent

; Document all options
event OnOptionHighlight(int optionId)
    ; TODO ~ Lots of options :)
endEvent

; Toggles (Shift + Ctrl + Alt)
event OnOptionSelect(int optionId)
    if optionId == oid_SaveConfig
        JValue.writeToFile(HotkeyScript.Configuration, "Data\\SgtmHotkey\\Config.json")
        SetTextOptionValue(oid_SaveConfig, "Saved to Default.json")
        return
    endIf

    int config
    string modifierKey = ""
    ; Normal
    if optionId == oid_Normal_Shift
        modifierKey = "shift"
        config = HotkeyScript.NormalConfig
    elseIf optionId == oid_Normal_Ctrl
        modifierKey = "ctrl"
        config = HotkeyScript.NormalConfig
    elseIf optionId == oid_Normal_Alt
        modifierKey = "alt"
        config = HotkeyScript.NormalConfig
    ; Slow
    elseIf optionId == oid_Slow_Shift
        modifierKey = "shift"
        config = HotkeyScript.SlowConfig
    elseIf optionId == oid_Slow_Ctrl
        modifierKey = "ctrl"
        config = HotkeyScript.SlowConfig
    elseIf optionId == oid_Slow_Alt
        modifierKey = "alt"
        config = HotkeyScript.SlowConfig
    ; Fast
    elseIf optionId == oid_Fast_Shift
        modifierKey = "shift"
        config = HotkeyScript.FastConfig
    elseIf optionId == oid_Fast_Ctrl
        modifierKey = "ctrl"
        config = HotkeyScript.FastConfig
    elseIf optionId == oid_Fast_Alt
        modifierKey = "alt"
        config = HotkeyScript.FastConfig
    ; SlowDown
    elseIf optionId == oid_SlowDown_Shift
        modifierKey = "shift"
        config = HotkeyScript.SlowDownConfig
    elseIf optionId == oid_SlowDown_Ctrl
        modifierKey = "ctrl"
        config = HotkeyScript.SlowDownConfig
    elseIf optionId == oid_SlowDown_Alt
        modifierKey = "alt"
        config = HotkeyScript.SlowDownConfig
    ; SpeedUp
    elseIf optionId == oid_SpeedUp_Shift
        modifierKey = "shift"
        config = HotkeyScript.SpeedUpConfig
    elseIf optionId == oid_SpeedUp_Ctrl
        modifierKey = "ctrl"
        config = HotkeyScript.SpeedUpConfig
    elseIf optionId == oid_SpeedUp_Alt
        modifierKey = "alt"
        config = HotkeyScript.SpeedUpConfig
    endIf
    bool isEnabled = JMap.getStr(config, modifierKey) == "true"
    if isEnabled
        ; Turn it off
        SetToggleOptionValue(optionId, false)
        JMap.removeKey(config, modifierKey)
    else
        ; Turn it on
        SetToggleOptionValue(optionId, true)
        JMap.setStr(config, modifierKey, "true")
    endIf
endEvent

; Slider dialog open
event OnOptionSliderOpen(int optionId)
    int config
    if optionId == oid_Normal_Slider
        SetupSlider(HotkeyScript.NormalConfig, HotkeyScript.MaxRangeValue)
    elseIf optionId == oid_Slow_Slider
        SetupSlider(HotkeyScript.SlowConfig, HotkeyScript.MaxRangeValue)
    elseIf optionId == oid_Fast_Slider
        SetupSlider(HotkeyScript.FastConfig, HotkeyScript.MaxRangeValue)
    elseIf optionId == oid_SlowDown_Slider
        SetupSlider(HotkeyScript.SlowDownConfig, HotkeyScript.MaxIntervalValue)
    elseIf optionId == oid_SpeedUp_Slider
        SetupSlider(HotkeyScript.SpeedUpConfig, HotkeyScript.MaxIntervalValue)
    endIf
endEvent

; Helper for setting up sliders
function SetupSlider(int config, float rangeEnd)
    SetSliderDialogStartValue(JMap.getFlt(config, "value"))
    SetSliderDialogRange(0.0, rangeEnd)
    SetSliderDialogInterval(0.1)
endFunction

; Slider option select
event OnOptionSliderAccept(int optionId, float value)
    int config
    if optionId == oid_Normal_Slider
        config = HotkeyScript.NormalConfig
    elseIf optionId == oid_Slow_Slider
        config = HotkeyScript.SlowConfig
    elseIf optionId == oid_Fast_Slider
        config = HotkeyScript.FastConfig
    elseIf optionId == oid_SlowDown_Slider
        config = HotkeyScript.SlowDownConfig
    elseIf optionId == oid_SpeedUp_Slider
        config = HotkeyScript.SpeedUpConfig
    endIf
    JMap.setFlt(config, "value", value)
    SetSliderOptionValue(optionId, value)
endEvent

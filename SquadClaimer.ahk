#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent
#SingleInstance, force

Toggle := 1

EnvGet, localappdata, localappdata
squadlog := % localappdata . "\SquadGame\Saved\Logs\SquadGame.log"

global NameVersion = "Squad Claimer v1.0.0"
global LastPos := 0

FileDelete, debug.log ; Delete the previous debug log

; Create the INI if it doesn't exist
if !FileExist("config.ini")
{
    IniWrite, Logi, config.ini, Settings, SquadName
    IniWrite, End, config.ini, Settings, ToggleKey
    IniWrite, ~, config.ini, Settings, ConsoleKey
    IniWrite, 100, config.ini, Settings, Interval
}

; Read from INI
IniRead, squadname, config.ini, Settings, SquadName, Logi
IniRead, hotkey, config.ini, Settings, ToggleKey, End
IniRead, consolekey, config.ini, Settings, ConsoleKey, ~
IniRead, timerinterval, config.ini, Settings, Interval, 100

SetTimer, ReadLog, %timerinterval%
Hotkey, %hotkey%, ToggleScript

; Set up System Tray and Icons
If FileExist("SquadClaimer1.ico")
{
    Menu, tray, Icon, SquadClaimer1.ico
}
Menu, Tray, Tip, % NameVersion
Menu, Tray, NoStandard
Menu, Tray, Click, 1
Menu, Tray, Add, % NameVersion, ShowGUI
Menu, Tray, Default, % NameVersion
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitApp

; Mouse movement detection for GUI Tooltip
OnMessage(0x200, "Help")

; GUI
Gui, Font, s12
Gui, Add, Text,, Squad Name
Gui, Add, Edit, vSquadName gUpdate w270, %squadname%
Gui, Add, Text,, Script Toggle Key
Gui, Add, Edit, vToggleKey gUpdate w150, %hotkey%
Gui, Add, Text,, Game Console Key
Gui, Add, Edit, vConsoleKey gUpdate w150, %consolekey%
Gui, Add, Text,, Script Refresh Interval `(ms)
Gui, Add, Edit, vInterval gUpdate w60, %timerinterval%
Gui, Add, Button, gToggleScript vStartStop, Stop
Gui, Show, w300, Squad Claimer - Running

Update:
Gui, Submit, NoHide
IniWrite, %SquadName%, config.ini, Settings, SquadName
IniWrite, %ToggleKey%, config.ini, Settings, ToggleKey
IniWrite, %ConsoleKey%, config.ini, Settings, ConsoleKey
IniWrite, %Interval%, config.ini, Settings, Interval
Hotkey, %hotkey%, ToggleScript
SetTimer, ReadLog, %Interval%
return

; Showing GUI and preventing icon reset when GUI is toggled
ShowGUI:
    Gui, Show
    If (Toggle) && FileExist("SquadClaimer1.ico")
    {
        hIcon := DllCall("LoadImage", uint, 0, str, A_ScriptDir "\SquadClaimer1.ico", uint, 1, int, 0, int, 0, uint, 0x10)  ; Type, Width, Height, Flags
        Gui +LastFound  ; Set the "last found window" for use in the next lines.
        SendMessage, 0x80, 0, hIcon  ; Set the window's small icon (0x80 is WM_SETICON).
        SendMessage, 0x80, 1, hIcon  ; Set the window's big icon to the same one.
    }
    Else If FileExist("SquadClaimer2.ico")
    {
        hIcon := DllCall("LoadImage", uint, 0, str, A_ScriptDir "\SquadClaimer2.ico", uint, 1, int, 0, int, 0, uint, 0x10)  ; Type, Width, Height, Flags
        Gui +LastFound  ; Set the "last found window" for use in the next lines.
        SendMessage, 0x80, 0, hIcon  ; Set the window's small icon (0x80 is WM_SETICON).
        SendMessage, 0x80, 1, hIcon  ; Set the window's big icon to the same one.
    }
    return

GuiClose:
    DllCall("DestroyIcon", "ptr", hIcon)
    Gui, Hide
    return

ExitApp:
    DllCall("DestroyIcon", "ptr", hIcon)
    ExitApp,
    return

; GUI Tooltip
Help(wParam, lParam, Msg) 
{
    Sleep, 1000
    MouseGetPos,,,, OutputVarControl
    IfEqual, OutputVarControl, Edit1
    {
        Help := "Enter the name of the squad you wish to create"
    }
    else IfEqual, OutputVarControl, Edit2
    {
        Help := "Enter the key to Start/Stop the script"
    }
    else IfEqual, OutputVarControl, Edit3
    {
        Help := "Enter the key to open the in-game console"
    }
    else IfEqual, OutputVarControl, Edit4
    {
        Help := "Enter the rate, in milliseconds, at which the script runs and makes checks"
    }
    else IfEqual, OutputVarControl, Button1
    {
        Help := "Start/Stop the script"
    }
    ToolTip % Help
}

ToggleScript:
    Toggle := !Toggle
    if (Toggle) {
        SetTimer, ReadLog, %Interval%
        GuiControl,, StartStop, Stop
        Gui, Show, , Squad Claimer - Running
        If FileExist("SquadClaimer1.ico")
        {
            Menu, tray, Icon, SquadClaimer1.ico
            hIcon := DllCall("LoadImage", uint, 0, str, A_ScriptDir "\SquadClaimer1.ico", uint, 1, int, 0, int, 0, uint, 0x10)  ; Type, Width, Height, Flags
            Gui +LastFound  ; Set the "last found window" for use in the next lines.
            SendMessage, 0x80, 0, hIcon  ; Set the window's small icon (0x80 is WM_SETICON).
            SendMessage, 0x80, 1, hIcon  ; Set the window's big icon to the same one.
        }
    } else {
        SetTimer, ReadLog, Off
        GuiControl,, StartStop, Start
        Gui, Show, , Squad Claimer - Stopped
        If FileExist("SquadClaimer2.ico")
        {
            Menu, tray, Icon, SquadClaimer2.ico
            hIcon := DllCall("LoadImage", uint, 0, str, A_ScriptDir "\SquadClaimer2.ico", uint, 1, int, 0, int, 0, uint, 0x10)  ; Type, Width, Height, Flags
            Gui +LastFound  ; Set the "last found window" for use in the next lines.
            SendMessage, 0x80, 0, hIcon  ; Set the window's small icon (0x80 is WM_SETICON).
            SendMessage, 0x80, 1, hIcon  ; Set the window's big icon to the same one.
        }
    }
return

ReadLog:
    Process, Exist, SquadGame.exe
    If ErrorLevel
    {
        file := squadlog ; Squad log file
        lines := Monitor(file)
        if (InStr(lines, "WORLD TRANSLATION BEGIN") && WinActive("ahk_exe SquadGame.exe"))
        {
            Send, {%ConsoleKey% down}
            Send, {%ConsoleKey% up}
            Send, createsquad %SquadName% 1
            Send, {Enter}
        }
    }
return

Monitor(file) ; Return all new non-empty lines of file
{
    newLines := ""
    FileObj := FileOpen(file, "r") ; Open the file for reading
    if !IsObject(FileObj)
        return ; Exit if the file couldn't be opened
    FileSize := FileObj.Length ; Get the current file size
    if (LastPos = 0) ; If LastPos is not set
        LastPos := FileSize ; set LastPos to the current file size
    else if (LastPos > FileSize) ; If the file size has decreased,
        LastPos := 0 ; reset LastPos to 0
    FileObj.Seek(LastPos) ; Move to the last read position
    while FileObj.Pos < FileSize ; While there's more data to read,
    {
        line := Trim(FileObj.ReadLine()) ; read a line and remove leading/trailing white space
        if (line != "") ; Ignore empty lines
        {
            newLines .= line
        }
    }
    LastPos := FileObj.Pos ; Remember the last read position
    FileObj.Close() ; Close the file
    newLines := RTrim(newLines, "`n") ; Remove the trailing newline
    Debug(newLines)
    return newLines
}

; Debug and log found lines
Debug(newLines)
{
    if (newLines != "")
    {
        OutputDebug, % newLines
        FileAppend, % newLines, debug.log
    }
}

﻿#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent
#SingleInstance, force
#Include lib\AddToolTip.ahk

Toggle := 1

EnvGet, localappdata, localappdata
squadlog := % localappdata . "\SquadGame\Saved\Logs\SquadGame.log"
squadinput := % localappdata . "\SquadGame\Saved\Config\WindowsNoEditor\input.ini"

global NameVersion = "Squad Claimer v2.0.0"
global LastPos := 0

FileDelete, debug.log ; Delete the previous debug log

; Create the INI if it doesn't exist
if !FileExist("config.ini")
{
    IniWrite, Logi, config.ini, Settings, SquadName
    IniWrite, End, config.ini, Settings, ToggleKey
    IniWrite, %consolekey%, config.ini, Settings, ConsoleKey
    IniWrite, 100, config.ini, Settings, Interval
    IniWrite, 1, config.ini, Settings, AlwaysOnTop
}

; Read from INI
IniRead, squadname, config.ini, Settings, SquadName, Logi
IniRead, hotkey, config.ini, Settings, ToggleKey, End
IniRead, consolekey, config.ini, Settings, ConsoleKey, %consolekey%
IniRead, timerinterval, config.ini, Settings, Interval, 100
IniRead, alwaysontop, config.ini, Settings, AlwaysOnTop, 1

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

; GUI
Gui, Font, s12
Gui, Add, Text,, Squad Name
Gui, Add, Edit, vSquadName gUpdate w270 hwndhSquadName, %squadname%
Gui, Add, Text,, Script Toggle Key
Gui, Add, Hotkey, vToggleKey gUpdate w150 hwndhToggleKey, %hotkey%
Gui, Add, Text,, Game Console Key
Gui, Add, Hotkey, vConsoleKey gUpdate w150 hwndhConsoleKey, %consolekey%
Gui, Add, Button, gAutoDetectCK x+10, Auto-detect
Gui, Add, Text, x15, Script Refresh Interval `(ms)
Gui, Add, Edit, vInterval gUpdate w60 hwndhInterval, %timerinterval%
if (alwaysontop = 1)
{    
    Gui, Add, Checkbox, vAlwaysOnTop gUpdate Checked, Always On Top
    Gui, +AlwaysOnTop
}
else
{ 
    Gui, Add, Checkbox, vAlwaysOnTop gUpdate, Always On Top
}
Gui, Add, Button, gToggleScript vStartStop hwndhStartStop, Stop
Gui, Add, Button, gCreateSquad vCreateSquad hwndhCreateSquad x+10, Create a squad
Gui, Show, w400, Squad Claimer - Running

; Tooltips
AddToolTip(hSquadName, "Enter the name of the squad you wish to create")
AddToolTip(hToggleKey, "Enter the key to Start/Stop the script")
AddToolTip(hConsoleKey, "Enter the key to open the in-game console")
AddToolTip(hInterval, "Enter the rate, in milliseconds, at which the script runs and makes checks")
AddToolTip(hStartStop, "Start/Stop the script")
AddToolTip(hCreateSquad, "Manually create a squad")

Update:
Gui, Submit, NoHide
IniWrite, %SquadName%, config.ini, Settings, SquadName
IniWrite, %ToggleKey%, config.ini, Settings, ToggleKey
IniWrite, %ConsoleKey%, config.ini, Settings, ConsoleKey
IniWrite, %Interval%, config.ini, Settings, Interval
Hotkey, %hotkey%, ToggleScript
SetTimer, ReadLog, %Interval%
IniWrite, %AlwaysOnTop%, config.ini, Settings, AlwaysOnTop
if (AlwaysOnTop = 1)
{  
    Gui, +AlwaysOnTop
}
else
{
    Gui, -AlwaysOnTop
}
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

CreateSquad:
    Process, Exist, SquadGame.exe
    If ErrorLevel
    {
        ControlSend,, {%ConsoleKey% down}, ahk_exe SquadGame.exe
        ControlSend,, {%ConsoleKey% up}, ahk_exe SquadGame.exe
        ControlSend,, createsquad %SquadName% 1, ahk_exe SquadGame.exe
        ControlSend,, {Enter}, ahk_exe SquadGame.exe
    }
return

AutoDetectCK:
    FileRead, InputIniContent, %squadinput%
    RegExMatch(InputIniContent, "ConsoleKeys=(\S+)", match)
    firstConsoleKey := match1
    GuiControl,, ConsoleKey, %FirstConsoleKey%
    IniWrite, %FirstConsoleKey%, config.ini, Settings, ConsoleKey
return

ReadLog:
    Process, Exist, SquadGame.exe
    If ErrorLevel
    {
        file := squadlog ; Squad log file
        lines := Monitor(file)
        ;if ((InStr(lines, "seconds to LoadMap") || InStr(lines, "WORLD TRANSLATION BEGIN {0, 0, 0}")) && WinActive("ahk_exe SquadGame.exe"))
        if (InStr(lines, "seconds to LoadMap") || InStr(lines, "WORLD TRANSLATION BEGIN {0, 0, 0}"))  
        {
            ControlSend,, {%ConsoleKey% down}, ahk_exe SquadGame.exe
            ControlSend,, {%ConsoleKey% up}, ahk_exe SquadGame.exe
            ControlSend,, createsquad %SquadName% 1, ahk_exe SquadGame.exe
            ControlSend,, {Enter}, ahk_exe SquadGame.exe
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
        trLine := Trim(FileObj.ReadLine()) ; read a line and remove leading/trailing white space
        if (trLine != "") ; Ignore empty lines
        {
            newLines .= trLine
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

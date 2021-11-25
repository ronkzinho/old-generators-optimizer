#Include JSON.ahk

#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetKeyDelay, 50

FileRead jsonString, settings.json

settings := JSON.Load(jsonString)

global next_seed = ""
global next_seed_type = ""
global token = ""
global timestamp = 0
global autoUpdate := settings["autoUpdate"]
global titleScreenDelay := settings["titleScreenDelay"]
global fastWorldCreation := settings["fastWorldCreation"]

IfNotExist, fsg_tokens
    FileCreateDir, fsg_tokens

#NoEnv
EnvGet, appdata, appdata 
global SavesDirectory := StrReplace(settings["savesFolder"], "%appdata%", appdata) (SubStr(settings["savesFolder"],0,1) == "/" ? "" : "/")
IfNotExist, %SavesDirectory%_oldWorlds
    FileCreateDir, %SavesDirectory%_oldWorlds

;HOW TO GET YOUR TOKEN
;When you press your macro to GetSeed it will create a file called fsg_seed_token.txt
;This has the seed and the token.
;
;All past seeds and verification data will be stored into the folder fsg_tokens with the name 
;fsg_seed_token followed by a date and time e.g. 123456789_2021261233.txt

Speak(txt){
     ComObjCreate("SAPI.SpVoice").Speak(txt)
}

KillProcesses(){
    RunHide("taskkill /F /IM wslhost.exe")
    RunHide("taskkill /F /IM wsl.exe")
    RunHide("taskkill /F /IM seed")
}

RunHide(Command) {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows, On
    Run, %ComSpec%,, Hide, cPid
    WinWait, ahk_pid %cPid%
    DetectHiddenWindows, %dhw%
    DllCall("AttachConsole", "uint", cPid)

    Shell := ComObjCreate("WScript.Shell")
    Exec := Shell.Exec(Command)
    Result := Exec.StdOut.ReadAll()

    DllCall("FreeConsole")
    Process, Close, %cPid%
    Return Result
}

HasGameSaved() {
    rawLogFile := StrReplace(SavesDirectory, "saves", "logs\latest.log")
    StringTrimRight, logFile, rawLogFile, 1
    numLines := 0
    Loop, Read, %logFile%
    {
        numLines += 1
    }
    saved := False
    while (!saved)
    {
        Loop, Read, %logFile%
        {
            if ((numLines - A_Index) < 2)
            {
                if (InStr(A_LoopReadLine, "Stopping worker threads")) {
                    saved := True
                    break
                }
            }
        }
    }
    return saved
}

GenerateSeed() {
    if (CheckEverything(false) != true){
        KillProcesses()
        ExitApp
    }
    fsg_seed_token := RunHide("wsl.exe python3 ./findSeed.py")
    timestamp := A_NowUTC
    fsg_seed_token_array := StrSplit(fsg_seed_token, ["Seed:", "Verification Token:", "Type:"]) 
    fsg_seed_array := StrSplit(fsg_seed_token_array[2], A_Space)
    fsg_type_array := StrSplit(fsg_seed_token_array[4], A_Space)
    fsg_seed := Trim(fsg_seed_array[2])
    fsg_type := (InStr(fsg_seed_token, "Type:", false) ? Trim(fsg_type_array[2]) : "")

    KillProcesses()

    return {seed: fsg_seed, token: fsg_seed_token, seed_type: fsg_type}
}

FindSeed(resetFromWorld){
    if WinExist("Minecraft"){
        if (next_seed == "" || (A_NowUTC - timestamp > 30 && !resetFromWorld)) {
            Speak("Searching")

            output := GenerateSeed()
            next_seed := output["seed"]
            token := output["token"]

            if (next_seed == ""){
                MsgBox % token
                return
            }

            next_seed_type := output["seed_type"]

            Speak("Seed Found") 

        }
        if FileExist("fsg_seed_token.txt"){
            FileMoveDir, fsg_seed_token.txt, fsg_tokens\fsg_seed_token_%A_NowUTC%.txt, R
        }
        clipboard = %next_seed%

        WinActivate, Minecraft
        Sleep, 100

        if (fastWorldCreation){
            FSGFastCreateWorld()
        }
        else {
            FSGCreateWorld()
        }
        
        if (next_seed_type){
            Speak(next_seed_type)
        }
        FileAppend, %token%, fsg_seed_token.txt
        output := GenerateSeed()
        next_seed := output["seed"]
        token := output["token"]
        next_seed_type := output["seed_type"]
    } else {
        MsgBox % "Minecraft is not open, open Minecraft and run agian."
    }
}

GetSeed(){
    WinGetActiveTitle, Title
    IfNotInString Title, -
        FindSeed(False)()
    else {
        ExitWorld()
        HasGameSaved()
        sleep, %titleScreenDelay%
        FindSeed(True)()
    } 
}

FSGCreateWorld(){
    Loop, Files, %SavesDirectory%*, D
    {
        _Check :=SubStr(A_LoopFileName,1,1)
        If (_Check!="_")
        {
            FileMoveDir, %SavesDirectory%%A_LoopFileName%, %SavesDirectory%_oldWorlds\%A_LoopFileName%%A_NowUTC%, R
        }
    }
    Send, {Esc}{Esc}{Esc}
    Send, `t
    Send, {enter}
    Send, `t
    Send, `t
    Send, `t
    Send, {enter}
    Send, ^a
    Send, ^v
    Send, `t
    Send, `t
    Send, {enter}
    Send, {enter}
    Send, {enter}
    Send, `t
    Send, `t
    Send, `t
    Send, `t
    Send, {enter}
    Send, `t
    Send, `t
    Send, `t
    Send, ^v
    Send, `t
    Send, `t
    Send, `t
    Send, `t
    Send, `t
    Send, {enter}
    Send, `t
    Send, {enter}
}

FSGFastCreateWorld(){
    Loop, Files, %SavesDirectory%*, D
    {
        _Check :=SubStr(A_LoopFileName,1,1)
        If (_Check!="_")
        {
            FileMoveDir, %SavesDirectory%%A_LoopFileName%, %SavesDirectory%_oldWorlds\%A_LoopFileName%%A_NowUTC%, R
        }
    }
    delay := 45 ; Fine tune for your PC/comfort level (Each screen needs to be visible for at least a frame)
    SetKeyDelay, 0
    send {Esc}{Esc}{Esc}
    send {Tab}{Enter}
    SetKeyDelay, delay 
    send {Tab}
    SetKeyDelay, 0
    send {Tab}{Tab}{Enter}
    send ^a
    send ^v
    send {Tab}{Tab}{Enter}{Enter}{Enter}{Tab}{Tab}{Tab}
    SetKeyDelay, delay
    send {Tab}{Enter}
    SetKeyDelay, 0
    send {Tab}{Tab}{Tab}^v{Shift}+{Tab}
    SetKeyDelay, delay
    send {Shift}+{Tab}{Enter}
}

ExitWorld()
{
    SetKeyDelay, 0
    send {Esc}{Shift}+{Tab}{Enter}
    SetKeyDelay, 50
}

if (!FileExist(SavesDirectory)){
    MsgBox % "Your saves folder is invalid!"
    ExitApp
}

if (autoUpdate == true || autoUpdate != false){
    update := RunHide("wsl.exe python3 ./updater.py check")
    
    IfInString, update, True
    {
        MsgBox, 4, Old Gen Optimizer, There is a new version of the optimizer, do you want to download it? (you will lose all essential files)
        IfMsgBox, Yes
        {
            RunHide("wsl.exe python3 ./updater.py")
            MsgBox, Done.
            Reload
        }
    }
}

if (FileExist("requirements.txt")){
    if (autoUpdate == true){
        RunHide("wsl.exe python3 ./updater.py force")
    }
    result := RunHide("wsl.exe pip install -r requirements.txt")
    if (result == ""){
        MsgBox, You have to install pip using: "sudo apt-get install python3-pip"
        ExitApp
    }
    FileDelete % "./requirements.txt"
}

if (autoUpdate != true and autoUpdate != false){
    MsgBox % "The configuration autoUpdate must be either true or false."
    ExitApp
}

if (!settings["generator"]){
    MsgBox % "Invalid generator."
}

if (fastWorldCreation != true and fastWorldCreation != false){
    MsgBox % "The configuration fastWorldCreation must be either true or false."
    ExitApp
}

if (!(titleScreenDelay > 0)){
    MsgBox % "The configuration titleScreenDelay must be a postive number."
    ExitApp
}

CheckEverything(settings["warnOnUnverifiable"])

CheckEverything(checkUnverifiable) {
    checkGen := RunHide("wsl.exe python3 ./gen.py")
    If InStr(checkGen, "Missing") || If InStr(checkGen, "csprng.c sha256sum") 
    {
        MsgBox, 4, OldGenOptimizer, %checkGen%Download generator again?
        IfMsgBox, Yes
        {
            RunHide("wsl.exe python3 ./gen.py download")
            MsgBox, Done.
            Reload
        }
    }
    if (checkUnverifiable == true){
        IfInString, checkGen, Runs with this generator won't be able to get verified.
        {
            MsgBox % checkGen
        }
    }
    return true
}

#IfWinActive, Minecraft
{
    Y::
        GetSeed()
    return

    U::
        ExitWorld()
    return

}
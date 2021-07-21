#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetKeyDelay, 50

global next_seed = ""
global next_seed_type = ""
global token = ""
global timestamp = 0
global autoUpdate = True

IfNotExist, fsg_tokens
    FileCreateDir, fsg_tokens

;UPDATE THIS TO YOUR MINECRAFT SAVES FOLDER
#NoEnv
EnvGet, appdata, appdata 
global SavesDirectory = appdata "\.minecraft\saves\" ; Replace this with your minecraft saves
IfNotExist, %SavesDirectory%_oldWorlds
    FileCreateDir, %SavesDirectory%_oldWorlds

;https://seedbankcustom.andynovo.repl.co/ to adjust your filter update inside filters.json
;TO EDIT YOUR FILTER
;GOTO https://seedbankcustom.andynovo.repl.co/
;SELECT YOUR FILTER AND GET A FILTER CODE e.g. 000A000A00000000000A000A00000000000A000A00000000000A000A000000000
;OPEN settings.json and update your filter and desired number of threads
;

;HOW TO GET YOUR TOKEN
;When you press your macro to GetSeed it will create a file called fsg_seed_token.txt
;This has the seed and the token.
;
;All past seeds and verification data will be stored into the folder fsg_tokens with the name 
;fsg_seed_token followed by a date and time e.g. 123456789_2021261233.txt

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

GenerateSeed() {
    try{
        fsg_seed_token := RunHide("wsl.exe python3 ./findSeed.py")
        timestamp := A_NowUTC
        fsg_seed_token_array := StrSplit(fsg_seed_token, ["Seed:", "Verification Token:", "Type:"]) 
        fsg_seed_array := StrSplit(fsg_seed_token_array[2], A_Space)
        fsg_type_array := StrSplit(fsg_seed_token_array[4], A_Space)
        fsg_seed := Trim(fsg_seed_array[2])
        fsg_type := Trim(fsg_type_array[2])
    } Catch e {
        return { error: "You didn't install everything it was supposed to" }
    }

    return {seed: fsg_seed, token: fsg_seed_token, seed_type: fsg_type}
}

FindSeed(resetFromWorld){
    if WinExist("Minecraft"){
        if (next_seed = "" || (A_NowUTC - timestamp > 30 && !resetFromWorld)) {
            ComObjCreate("SAPI.SpVoice").Speak("Searching")
            output := GenerateSeed()
            next_seed := output["seed"]
            token := output["token"]

            if (next_seed = ""){
                MsgBox % fsg_seed_token
                return
            }
            ComObjCreate("SAPI.SpVoice").Speak("Seed Found")
        
            next_seed_type := output["seed_type"] || ""
        }
        if FileExist("fsg_seed_token.txt"){
            FileMoveDir, fsg_seed_token.txt, fsg_tokens\fsg_seed_token_%A_NowUTC%.txt, R
        }
        clipboard = %next_seed%

        WinActivate, Minecraft
        Sleep, 100
        FSGCreateWorld() ;Change to FSGFastCreateWorld() if you want an optimized macro
        
        if (seed_type != ""){
            ComObjCreate("SAPI.SpVoice").Speak(seed_type)
        }
        FileAppend, %token%, fsg_seed_token.txt
        output := GenerateSeed()
        next_seed := output["seed"]
        token := output["token"]
        next_seed_type = output["seed_type"] || ""
    } else {
        MsgBox % "Minecraft is not open, open Minecraft and run agian."
    }
}

GetSeed(){
    WinGetPos, X, Y, W, H, Minecraft
    WinGetActiveTitle, Title
    IfNotInString Title, player
        FindSeed(False)()
    else {
        ExitWorld()
        sleep, 100
        Loop {
            IfWinActive, Minecraft 
            {
                PixelSearch, Px, Py, 0, 0, W, H, 0x00FCFC, 1, Fast
                if (!ErrorLevel) {
                    Sleep, 5000
                    IfWinActive, Minecraft 
                    {
                        FindSeed(True)()
                        break
                    }
                }
            }
        } 
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
    MsgBox, "Your saves folder is invalid!"
    ExitApp
}

if (autoUpdate == True){
    update := RunHide("wsl.exe python3 ./updater.py check")
    
    IfInString, update, True
    {
        MsgBox, 4, Old Gen Optimizer, There is a new version of the optimizer, do you want to download it? (you will lose all essential files)
        IfMsgBox, Yes
        {
            RunHide("wsl.exe python3 ./updater.py")
            MsgBox, Done.
        }
    }
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
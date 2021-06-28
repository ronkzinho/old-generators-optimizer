#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetKeyDelay, 50

IfNotExist, fsg_tokens
    FileCreateDir, fsg_tokens

#NoEnv
EnvGet, appdata, appdata 
global SavesDirectory = appdata "\.minecraft\saves\" ; Replace this with your minecraft saves
IfNotExist, %SavesDirectory%_oldWorlds
    FileCreateDir, %SavesDirectory%_oldWorlds

FindSeed(){
    if WinExist("Minecraft"){
        if FileExist("fsg_seed_token.txt"){
            FileMoveDir, fsg_seed_token.txt, fsg_tokens\fsg_seed_token_%A_NowUTC%.txt, R
        }

        ComObjCreate("SAPI.SpVoice").Speak("Searching")

        try{
            RunWait, wsl.exe python3 ./findSeed.py > fsg_seed_token.txt,, hide
        } Catch e {
            MsgBox % "You did something wrong."
            return
        }
        FileRead, fsg_seed_token, fsg_seed_token.txt

        fsg_seed_token_array := StrSplit(fsg_seed_token, ["Seed:", "Verification Token:", "Type:"]) 
        fsg_seed_array := StrSplit(fsg_seed_token_array[2], A_Space)
        fsg_type_array := StrSplit(fsg_seed_token_array[4], A_Space)
        fsg_seed := Trim(fsg_seed_array[2])
        fsg_type := Trim(fsg_type_array[2])

        if (fsg_seed = ""){
            MsgBox % fsg_seed_token
            return
        }


        clipboard = %fsg_seed%

        WinActivate, Minecraft
        Sleep, 100
        if (fsg_type){ 
            ComObjCreate("SAPI.SpVoice").Speak(fsg_type)
        } else ComObjCreate("SAPI.SpVoice").Speak("Seed Found")
        
        FSGFastCreateWorld() ;Change to FSGFastCreateWorld() if you want an optimized macro
    } else {
        MsgBox % "Minecraft is not open, open Minecraft and run again."
    }
}

GetSeed(){
    WinGetActiveTitle, Title
    IfInString Title, player
        ExitWorld()
    FindSeed()()
}

FSGCreateWorld(){
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
    SetKeyDelay, 0
    send {Esc}{Esc}{Esc}
    send {Tab}{Enter}
    SetKeyDelay, 45 ; Fine tune for your PC/comfort level
    send {Tab}
    SetKeyDelay, 0
    send {Tab}{Tab}{Enter}
    send ^a
    send ^v
    send {Tab}{Tab}{Enter}{Enter}{Enter}{Tab}{Tab}{Tab}
    SetKeyDelay, 45 ; Fine tune for your PC/comfort level
    send {Tab}{Enter}
    SetKeyDelay, 0
    send {Tab}{Tab}{Tab}^v{Shift}+{Tab}
    SetKeyDelay, 45 ; Fine tune for your PC/comfort level
    send {Shift}+{Tab}{Enter}
}

ExitWorld()
{
    send {Esc}+{Tab}{Enter}
    sleep, 100
    Loop, Files, %SavesDirectory%*, D
    {
        _Check := SubStr(A_LoopFileName,1,1)
        If (_Check != "_")
        {
            FileMoveDir, %SavesDirectory%%A_LoopFileName%, %SavesDirectory%_oldWorlds\%A_LoopFileName%_%A_NowUTC%, R
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
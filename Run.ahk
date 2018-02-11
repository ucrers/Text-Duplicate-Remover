#SingleInstance Force

MultipleFileArray := []

;Check if a task is running
SingleIsDisabled := false
MultipleIsDisabled := false

;Sort
Gui, Add, CheckBox, x5 y2 w16 h16 vMultipleSortCheck,
Gui, Add, Text, x24 y3 w480 h20 +BackgroundTrans, Sort
;Remove files
Gui, Add, CheckBox, x395 y2 w16 h16 vRemoveCheck,
Gui, Add, Text, x414 y3 w480 h20 +BackgroundTrans, Remove files
;Multiple
Gui, Add, Text, x0 y3 w480 h20 +Center +BackgroundTrans, Multiple merge/remove duplicates
Gui, Add, ListView, x0 y20 w480 h140 gFileListView, Name|Lines|Path
Gui, Add, Button, x0 y160 w480 h40 vMergeBtn gMerge, Merge
;Sort
Gui, Add, CheckBox, x5 y203 w16 h16 vSingleSortCheck,
Gui, Add, Text, x24 y203 w480 h20 +BackgroundTrans, Sort
;Save ScriptDir
Gui, Add, CheckBox, x385 y203 w16 h16 vSaveSDCheck,
Gui, Add, Text, x404 y203 w480 h20 +BackgroundTrans, Save ScriptDir
;Single
Gui, Add, Text, x0 y203 w480 h20 +Center +BackgroundTrans, Single remove duplicates
Gui, Add, ListBox, x0 y220 w480 h110, 

LV_ModifyCol(1, 140)
LV_ModifyCol(2, 60)
LV_ModifyCol(3, 250)

Gui, Show, w480 h340, Fast Multiple/Single File Duplicates Remover
return

GuiClose:
if (SingleIsDisabled || MultipleIsDisabled)
{
    MsgBox, 68, Task running, There's an task running in the background.`nDo you really want to cancel and close?
    IfMsgBox Yes
        ExitApp
}
else
{
    ExitApp
}
Return

Merge:
ListCount := 0
for index, element in MultipleFileArray
{
    ListCount += 1
}
if (ListCount = 0)
{
    MsgBox, 64, Empty list, The list is empty!
    Return
}

FileSelectFile, SaveFilePath, S8, , Save a file, Text Documents (*.txt)
if SaveFilePath !=
{
    GuiControlGet, MultipleSortCheck
    GuiControlGet, RemoveCheck
    
    MultipleIsDisabled := true
    GuiControl, Disable, MergeBtn,
    ComboArray := []
    for index, element in MultipleFileArray
    {
        Loop, Read, %element%
        {
           ComboArray.Push(A_LoopReadLine)
        }
        if (RemoveCheck)
        {
            FileDelete, %element%
        }
    }
    removedComboArray := trimArray(ComboArray)
    for index, element in removedComboArray
    {
        ComboText = %ComboText%%element%`n
    }
    if (MultipleSortCheck)
    {
        Sort, ComboText
    }
    FileAppend, %ComboText%, %SaveFilePath%.txt
    ComboText = 
    GuiControl, Enabled, MergeBtn, 
    MultipleIsDisabled := false
}
Return

GuiDropFiles:
x := A_GuiX
y := A_GuiY

if (x > 0 && y > 20 && x < 480 && y < 160)
{
    ;Multiple files
    Loop, Parse, A_GuiEvent, `n
    {
        if (InStr(A_LoopField, ".txt"))
        {
            MultipleFileArray.Push(A_LoopField)
            total_lines = 0
            Loop, Read, %A_LoopField%
            {
               total_lines = %A_Index%
            }
            SplitPath, A_LoopField, FileName
            LV_Add("", FileName, total_lines, A_LoopField)
        }
        else
        {
            Loop Files, %A_LoopField%\*.txt, R
            {
                MultipleFileArray.Push(A_LoopFileFullPath)
                total_lines = 0
                Loop, Read, %A_LoopFileFullPath%
                {
                    total_lines = %A_Index%
                }
                SplitPath, A_LoopFileFullPath, FileName
                LV_Add("", FileName, total_lines, A_LoopFileFullPath)
            }
        }
    }
}
if (x > 0 && y > 220 && x < 480 && y < 330)
{
    ;Single file
    if (!SingleIsDisabled)
    {
        SingleIsDisabled := true
        Loop, Parse, A_GuiEvent, `n
        {
            GuiControlGet, SingleSortCheck
            GuiControlGet, SaveSDCheck
            SingleComboArray := []
            Loop, Read, %A_LoopField%
            {
               SingleComboArray.Push(A_LoopReadLine)
            }
            FileDelete, %A_LoopField%
            
            removedSingleComboArray := trimArray(SingleComboArray)
            for index, element in removedSingleComboArray
            {
                SingleComboText = %SingleComboText%%element%`n
            }
            if (SingleSortCheck)
            {
                Sort, SingleComboText
            }
            FileLocation := A_LoopField
            if (SaveSDCheck)
            {
                SplitPath, A_LoopField, FileName
                FileLocation = %A_ScriptDir%/%FileName%
                FileDelete, %A_LoopField%
            }
            FileAppend, %SingleComboText%, %FileLocation%
            SingleComboText = 
            SingleIsDisabled := false
        }
    
    }
}
Return

FileListView:
if A_GuiEvent = DoubleClick
{
    if (A_EventInfo != 0)
    {
        LV_GetText(DeletePath, A_EventInfo, 3)
        for index, element in MultipleFileArray
        {
            if (InStr(element, DeletePath))
            {
                MultipleFileArray.Remove(A_Index)
                Break
            }
        }
        LV_Delete(A_EventInfo)
    }
}
return

;Functions
trimArray(arr) {

    hash := {}, newArr := []

    for e, v in arr
        if (!hash.Haskey(v))
            hash[(v)] := 1, newArr.push(v)

    return newArr
}
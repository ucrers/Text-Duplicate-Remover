#SingleInstance Force

MultipleFileArray := []
SingleIsDisabled := false

Gui, Add, ListView, x0 y20 w480 h140 gFileListView, Name|Lines|Path
Gui, Add, Button, x0 y160 w480 h40 vMergeBtn gMerge, Merge
Gui, Add, Text, x0 y2 w480 h20 +Center +BackgroundTrans, Multiple files merge (remove duplicates)
Gui, Add, ListBox, x0 y220 w480 h110, 
Gui, Add, Text, x0 y202 w480 h20 +Center +BackgroundTrans, Single file remove duplicates (fast)

LV_ModifyCol(1, 140)
LV_ModifyCol(2, 60)
LV_ModifyCol(3, 250)

Gui, Show, w480 h340, Fast Multiple/Single File Duplicates Remover
return

GuiClose:
ExitApp
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
    GuiControl, Disable, MergeBtn,
    ComboArray := []
    for index, element in MultipleFileArray
    {
        Loop, Read, %element%
        {
           ComboArray.Push(A_LoopReadLine)
        }
    }
    removedComboArray := trimArray(ComboArray)
    for index, element in removedComboArray
    {
        ComboText = %ComboText%%element%`n
    }
    Sort, ComboText
    FileAppend, %ComboText%, %SaveFilePath%.txt
    ComboText = 
    GuiControl, Enabled, MergeBtn, 
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
        MultipleFileArray.Push(A_LoopField)
        total_lines = 0
        Loop, Read, %A_LoopField%
        {
           total_lines = %A_Index%
        }
        SplitPath, A_LoopField, FileName
        LV_Add("", FileName, total_lines, A_LoopField)
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
            Sort, SingleComboText
            FileAppend, %SingleComboText%, %A_LoopField%
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
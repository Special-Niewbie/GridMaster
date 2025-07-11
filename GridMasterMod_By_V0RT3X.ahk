/*∙=====∙NOTES∙===============================================∙
» Original Author:  Special-Niewbie
» Original Source:  https://www.autohotkey.com/boards/viewtopic.php?f=6&t=137889&p=605912&hilit=GridMaster#p605912
» https://github.com/Special-Niewbie/GridMaster
    ▹ Requires Gdip_All. (extracted to run as self contained)
    ▹ https://github.com/Special-Niewbie/GridMaster/tree/main/NO_NEED_old_libs_for_GridMaster_v1_only
∙=============================================================∙
*/

#NoEnv
#Persistent
#SingleInstance, Force
SetBatchLines -1
SetWinDelay 0
OnMessage(0x0201, "WM_LBUTTONDOWNdrag")    ;;∙------∙Handle drag for captionless GUI window.


;;∙======∙Initialize GDI+ graphics system.
If !pToken := Gdip_Startup()
{
    MsgBox, 48, GDI+ Error, Gdiplus failed to start!,5
    ExitApp
}
OnExit, Exit    ;;∙------∙Ensure cleanup on exit.


;;∙======∙Screen resolution and midpoint coordinates.
Width := A_ScreenWidth
Height := A_ScreenHeight
CenterX := Width // 2
CenterY := Height // 2


;;∙======∙Initial configuration variables.
gridActive := false    ;;∙------∙Draw full grid initially?
centerCross := true    ;;∙------∙Draw center cross initially?
gridSpacing := 50    ;;∙------∙Spacing between grid lines in pixels.
centerThick := 1    ;;∙------∙Thickness of center cross lines.
gridThick  := 2    ;;∙------∙Thickness of all grid lines.
gridColor := 0xFF800080    ;;∙------∙Default grid lines color: Violet.
centerColor := 0xFFFF0000    ;;∙------∙Default center lines color: Red.
hwnd1  := ""    ;;∙------∙Overlay window handle placeholder.


;;∙======∙GUI appearance and layout settings.
guiX := 1300    ;;∙------∙Initial horizontal position of the GUI on screen.
guiY := 450    ;;∙------∙Initial vertical position of the GUI on screen.
guiW := 475    ;;∙------∙Width of the GUI window in pixels.
guiH := 175    ;;∙------∙Height of the GUI window in pixels.
guiColor := "Black"    ;;∙------∙Background color of the GUI.
tranView := 225    ;;∙------∙Transparency level (0–255) of main GUI.
inputColor := "Blue"    ;;∙------∙Color for input text fields.
mainFont := "Arial"    ;;∙------∙Primary font used for static text labels.
inputFont := "Segoe UI"    ;;∙------∙Font used for editable fields and buttons.
cBoxFont := "Calibri"    ;;∙------∙Font used for checkboxes.
noteFont := "Calibri"    ;;∙------∙Font used for instructional or footer notes.


;;∙======∙GUI Setup.
Gui, Grids:+AlwaysOnTop +ToolWindow -Caption +Border +E0x80000
Gui, Grids:Color, %guiColor%
Gui, Grids:Font, s10 cAqua q5, %mainFont%

Gui, Grids:Add, Text, x15 y20 BackgroundTrans, Cross Hair Color:
Gui, Grids:Add, DropDownList, x+5 yp vCenterColorChoice w110 Choose15, Maroon|Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Olive|Lime|Green|Aqua|Teal|Blue|Navy|Blue-Purple|Violet|Red-Purple|Fuchsia|Pink|White|Gray|Silver|Black

Gui, Grids:Add, Text, x+20 yp BackgroundTrans, Grid Lines Color:
Gui, Grids:Add, DropDownList, x+5 yp vGridColorChoice w110 Choose11, Maroon|Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Olive|Lime|Green|Aqua|Teal|Blue|Navy|Blue-Purple|Violet|Red-Purple|Fuchsia|Pink|White|Gray|Silver|Black

Gui, Grids:Add, Text, x65 y+10 BackgroundTrans, Spacing:`n(in pixels)
Gui, Grids:Font, c%inputColor% Bold q5, %inputFont%
Gui, Grids:Add, Edit, x+5 yp vSpacingEdit Limit3 w40, %gridSpacing%
Gui, Grids:Font, cAqua Norm q5, %mainFont%

Gui, Grids:Add, Text, x+10 yp BackgroundTrans, GridLines:`nThickness
Gui, Grids:Font, c%inputColor% Bold q5, %inputFont%
Gui, Grids:Add, Edit, x+5 yp vGridThickEdit w40, %gridThick%
Gui, Grids:Font, cAqua Norm q5, %mainFont%

Gui, Grids:Add, Text, x+10 yp BackgroundTrans, CrossHair:`nThickness
Gui, Grids:Font, c%inputColor% Bold q5, %inputFont%
Gui, Grids:Add, Edit, x+5 yp vCenterThickEdit w40, %centerThick%
Gui, Grids:Font, cAqua Norm q5, %mainFont%

Gui, Grids:Font, s10 cFFA500 Norm, Calibri
Gui, Grids:Add, Checkbox, x120 y+15 vGridToggle Checked, Draw Full Grid
Gui, Grids:Add, Checkbox, x+5 yp vCenterCrossToggle Checked, Show Cross Hairs

Gui, Grids:Font, Norm q5, %inputFont%
Gui, Grids:Add, Button, x152 y+10 w50 h25 gHideDraw, Hide
Gui, Grids:Add, Button, x+10 yp w50 h25 gClearDraw, Clear
Gui, Grids:Add, Button, x+10 yp w50 h25 Default gStartDraw, Show

Gui, Grids:Font, s8 c676767 Italic q5, %noteFont%
Gui, Grids:Add, Text, x0 y+5 w%guiW% Center BackgroundTrans, ( Press F1 To Restore Gui Once Hiden )

Gui, Grids:Show, x%guiX% y%guiY% w%guiW% h%guiH%, GRIDS
WinSet, Transparent, %tranView%, GRIDS
WinWait, GRIDS ahk_class AutoHotkeyGUI
ControlFocus, Button5, GRIDS    ;;∙------∙Focus default button on GUI launch.
Return


;;∙======∙Functions and ∙========================∙
StartDraw:    ;;∙------∙Get user input from GUI without hiding.
    Gui, Grids:Submit, NoHide
    spacing := SpacingEdit
    centerThick := CenterThickEdit
    gridThick := GridThickEdit

    ;;∙======∙Validation check on input values.
    if (spacing < 1) || (centerThick < 0.1) || (gridThick < 0.1)
    {
        MsgBox,,, Please enter valid values (spacing > 0, thickness >= 0.1).,5
        Return
    }

    ;;∙======∙Color name-to-RGB mapping.
    colors := {"Maroon":       0xFF800000
    , "Red":		0xFFFF0000
    , "Red-Orange":	0xFFFF4500
    , "Orange":	0xFFFFA500
    , "Yellow-Orange":	0xFFFFBE00
    , "Yellow":	0xFFFFFF00
    , "Yellow-Green":	0xFF9ACD32
    , "Olive":	0xFF808000
    , "Lime":	0xFF00FF00
    , "Green":	0xFF008000
    , "Aqua":	0xFF00FFFF
    , "Teal":		0xFF008B8B
    , "Blue":		0xFF0000FF
    , "Navy":	0xFF000080
    , "Blue-Purple":	0xFF8A2BE2
    , "Violet":	0xFF800080
    , "Red-Purple":	0xFFC71585
    , "Fuchsia": 	0xFFFF00FF
    , "Pink":		0xFFDE6FDE
    , "White":	0xFFFFFFFF
    , "Gray":	0xFF808080
    , "Silver":	0xFFC0C0C0
    , "Black":	0xFF000000}

    gridColor   := colors[GridColorChoice]
    centerColor := colors[CenterColorChoice]
    gridActive  := GridToggle
    centerCross := CenterCrossToggle

    DrawOverlay(spacing, gridActive, gridColor, centerCross, centerColor, centerThick, gridThick)
Return

ClearDraw:    ;;∙------∙Clear overlay by drawing nothing.
    DrawOverlay(0, false, gridColor, false, centerColor, centerThick, gridThick)
Return

;;∙------∙Draw or clear the overlay window based on current settings.
DrawOverlay(spacing, drawGrid, gridColor, drawCenter, centerColor, centerThick, gridThick)
{
    global hwnd1, pToken, Width, Height, CenterX, CenterY

    ;;∙======∙Close previous window if it exists.
    if (hwnd1)
    {
        WinClose, ahk_id %hwnd1%
        hwnd1 := ""
    }

    ;;∙======∙Create transparent overlay window.
    Gui, Lines: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, Lines: Show, NA
    hwnd1 := WinExist()

    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G   := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)

    ;;∙======∙Draw center cross if enabled (with its own color).
    if (drawCenter)
    {
        pPenCenter := Gdip_CreatePen(centerColor, centerThick)    ;;∙------∙Center Lines thickness.
        Gdip_DrawLine(G, pPenCenter, 0, CenterY, Width, CenterY)
        Gdip_DrawLine(G, pPenCenter, CenterX, 0, CenterX, Height)
        Gdip_DeletePen(pPenCenter)
    }

    ;;∙======∙Draw grid lines if enabled (with grid color).
    if (drawGrid)
    {
        pPenGrid := Gdip_CreatePen(gridColor, gridThick)    ;;∙------∙Grid Lines thickness.
        maxRight := Width  - CenterX
        maxLeft := CenterX
        maxTop := CenterY
        maxBottom := Height - CenterY

        countX := Floor(maxRight / spacing)
        countY := Floor(maxBottom / spacing)

        Loop, %countX%
        {
            offset := A_Index * spacing
            Gdip_DrawLine(G, pPenGrid, CenterX + offset, 0, CenterX + offset, Height)
            Gdip_DrawLine(G, pPenGrid, CenterX - offset, 0, CenterX - offset, Height)
        }

        Loop, %countY%
        {
            offset := A_Index * spacing
            Gdip_DrawLine(G, pPenGrid, 0, CenterY + offset, Width, CenterY + offset)
            Gdip_DrawLine(G, pPenGrid, 0, CenterY - offset, Width, CenterY - offset)
        }
        Gdip_DeletePen(pPenGrid)
    }

    UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
}

HideDraw:
    Gui, Grids:Hide
Return


F1::    ;;∙------∙🔥∙Hotkey to restore GUI after hiding.
    Gui, Grids:Show, x%guiX% y%guiY% w%guiW% h%guiH%, GRIDS
    WinSet, Transparent, %tranView%, GRIDS
    WinWait, GRIDS ahk_class AutoHotkeyGUI
    ControlFocus, Button5, GRIDS  ; Set focus to 7th button "Start".
Return

WM_LBUTTONDOWNdrag() {    ;;∙------∙Drag function for borderless GUI.
   PostMessage, 0x00A1, 2, 0
}

Esc::ExitApp    ;;∙------∙Close with ESC key.

Exit:
    Gdip_Shutdown(pToken)    ;;∙------∙Shutdown and cleanup GDI+.
    ExitApp
Return


;;∙======∙Self-contained Gdip Functions∙============∙
Gdip_Startup()
{
    if !DllCall("GetModuleHandle", "str", "gdiplus", "ptr")
        DllCall("LoadLibrary", "str", "gdiplus")
    VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
    DllCall("gdiplus\GdiplusStartup", "ptr*", pToken, "ptr", &si, "ptr", 0)
    return pToken
}

Gdip_Shutdown(pToken)
{
    DllCall("gdiplus\GdiplusShutdown", "ptr", pToken)
    if hModule := DllCall("GetModuleHandle", "str", "gdiplus", "ptr")
        DllCall("FreeLibrary", "ptr", hModule)
    return 0
}

Gdip_GraphicsFromHDC(hdc)
{
    DllCall("gdiplus\GdipCreateFromHDC", "ptr", hdc, "ptr*", pGraphics)
    return pGraphics
}

Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
    return DllCall("gdiplus\GdipSetSmoothingMode", "ptr", pGraphics, "int", SmoothingMode)
}

Gdip_CreatePen(ARGB, w)
{
    DllCall("gdiplus\GdipCreatePen1", "uint", ARGB, "float", w, "int", 2, "ptr*", pPen)
    return pPen
}

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
    return DllCall("gdiplus\GdipDrawLine", "ptr", pGraphics, "ptr", pPen, "float", x1, "float", y1, "float", x2, "float", y2)
}

Gdip_DeletePen(pPen)
{
    return DllCall("gdiplus\GdipDeletePen", "ptr", pPen)
}

Gdip_DeleteGraphics(pGraphics)
{
    return DllCall("gdiplus\GdipDeleteGraphics", "ptr", pGraphics)
}

CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
{
    hdc2 := hdc ? hdc : GetDC()
    VarSetCapacity(bi, 40, 0)
    NumPut(40, bi, 0, "uint"), NumPut(w, bi, 4, "uint"), NumPut(h, bi, 8, "uint")
    NumPut(1, bi, 12, "ushort"), NumPut(bpp, bi, 14, "ushort")
    hbm := DllCall("CreateDIBSection", "ptr", hdc2, "ptr", &bi, "uint", 0, "ptr*", ppvBits, "ptr", 0, "uint", 0)
    if !hdc
        ReleaseDC(hdc2)
    return hbm
}

CreateCompatibleDC(hdc=0)
{
    return DllCall("CreateCompatibleDC", "ptr", hdc)
}

SelectObject(hdc, hgdiobj)
{
    return DllCall("SelectObject", "ptr", hdc, "ptr", hgdiobj)
}

DeleteObject(hObject)
{
    return DllCall("DeleteObject", "ptr", hObject)
}

DeleteDC(hdc)
{
    return DllCall("DeleteDC", "ptr", hdc)
}

GetDC(hwnd=0)
{
    return DllCall("GetDC", "ptr", hwnd)
}

ReleaseDC(hdc, hwnd=0)
{
    return DllCall("ReleaseDC", "ptr", hwnd, "ptr", hdc)
}

UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
{
    if (x != "" && y != "")
        VarSetCapacity(pt, 8), NumPut(x, pt, 0), NumPut(y, pt, 4)
    if (w = "" || h = "")
        WinGetPos,,, w, h, ahk_id %hwnd%
    return DllCall("UpdateLayeredWindow", "ptr", hwnd, "ptr", 0, "ptr", ((x = "" && y = "") ? 0 : &pt), "int64*", w|h<<32, "ptr", hdc, "int64*", 0, "uint", 0, "uint*", Alpha<<16|1<<24, "uint", 2)
}
;;∙============================================================∙
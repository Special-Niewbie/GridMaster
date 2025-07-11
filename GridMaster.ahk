/*
Grid Master
Copyright (C) 2025 Special-Niewbie Softwares
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, and distribute copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
Commercial use, sale, or integration of the Software into commercial products
requires explicit written permission from the copyright holder.
Redistributions in any form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

;;∙============================================================∙
#NoEnv
#Persistent
#SingleInstance, Force
SetBatchLines -1
SetWinDelay 0

;;∙------∙Initialize GDI+.
If !pToken := Gdip_Startup()
{
    MsgBox, 48, GDI+ Error, Gdiplus failed to start!,5
    ExitApp
}
OnExit, Exit

;;∙------∙Screen dimensions and center point.
Width    := A_ScreenWidth
Height   := A_ScreenHeight
CenterX  := Width // 2
CenterY  := Height // 2

;;∙------∙Dynamic variables.
gridActive   := false
centerCross  := true
gridSpacing  := 50
gridColor    := 0xFF676767    ;;∙------∙Default grid color: Gray.
centerColor  := 0xFFFF0000    ;;∙------∙Default center color: Red.
hwnd1        := ""

;;∙------∙System Tray Menu.
Menu, Tray, NoStandard
Menu, Tray, Add, >>> Grid Master Menu <<<, TitleLabel
Menu, Tray, Disable, >>> Grid Master Menu <<<
Menu, Tray, Add, , Separator
Menu, Tray, Add, Reload, ReloadScript
Menu, Tray, Add, Project Site, OpenProjectSite
Menu, Tray, Add, Donate, OpenDonationSite
Menu, Tray, Add, , Separator
Menu, Tray, Add, Show Version, ShowVersionInfo
Menu, Tray, Add, Exit, ExitApp

;;∙------∙GUI Setup.
Gui, 2:+AlwaysOnTop +ToolWindow
Gui, 2:Add, Text,, Grid spacing:
Gui, 2:Add, Edit, vSpacingEdit w60, %gridSpacing%
Gui, 2:Add, Checkbox, vGridToggle Checked, Draw Full Grid
Gui, 2:Add, Checkbox, vCenterCrossToggle Checked, Show Center Cross
Gui, 2:Add, Text,, Grid Color:
Gui, 2:Add, DropDownList, vGridColorChoice w100 Choose3, Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Green|Blue-Green|Blue|Violet|Red-Purple|White|Gray|Black
Gui, 2:Add, Text,, Center Color:
Gui, 2:Add, DropDownList, vCenterColorChoice w100 Choose5, Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Green|Blue-Green|Blue|Violet|Red-Purple|White|Gray|Black
Gui, 2:Add, Button, x20 y+10 w70 gClearDraw, Cancel
Gui, 2:Add, Button, x+10 yp w70 gStartDraw, Start
Gui, 2:Show, x1500 y450, Grid Master
Return

StartDraw:
    Gui, 2:Submit, NoHide
    spacing := SpacingEdit
    if (spacing < 1)
    {
        MsgBox,,, Please enter a valid spacing.,5
        Return
    }

    ;;∙------∙Define RGB hex primary, secondary, tertiary, and Achromatic colors.
    colors := {"Red":    0xFFFF0000
            , "Red-Orange":    0xFFFF4500
            , "Orange":    0xFFFFA500
            , "Yellow-Orange":    0xFFFFBE00
            , "Yellow":    0xFFFFFF00
            , "Yellow-Green":    0xFF9ACD32
            , "Green":    0xFF008000
            , "Blue-Green":    0xFF008B8B
            , "Blue":    0xFF0000FF
            , "Blue-Purple":    0xFF8A2BE2
            , "Violet":    0xFF800080
            , "Red-Purple":    0xFFC71585
            , "White":    0xFFFFFFFF
            , "Gray":    0xFF808080
            , "Black":    0xFF000000}

    gridColor   := colors[GridColorChoice]
    centerColor := colors[CenterColorChoice]
    gridActive  := GridToggle
    centerCross := CenterCrossToggle

    DrawOverlay(spacing, gridActive, gridColor, centerCross, centerColor)
Return

ClearDraw:
    DrawOverlay(0, false, gridColor, false, centerColor)
Return

DrawOverlay(spacing, drawGrid, gridColor, drawCenter, centerColor)
{
    global hwnd1, pToken, Width, Height, CenterX, CenterY

    ;;∙------∙Close previous window if it exists.
    if (hwnd1)
    {
        WinClose, ahk_id %hwnd1%
        hwnd1 := ""
    }

    ;;∙------∙Create transparent overlay window.
    Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, 1: Show, NA
    hwnd1 := WinExist()

    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G   := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)

    ;;∙------∙Draw center cross if enabled (with its own color).
    if (drawCenter)
    {
        pPenCenter := Gdip_CreatePen(centerColor, 1)
        Gdip_DrawLine(G, pPenCenter, 0, CenterY, Width, CenterY)
        Gdip_DrawLine(G, pPenCenter, CenterX, 0, CenterX, Height)
        Gdip_DeletePen(pPenCenter)
    }

    ;;∙------∙Draw grid lines if enabled (with grid color).
    if (drawGrid)
    {
        pPenGrid := Gdip_CreatePen(gridColor, 1)
        ;; Draw vertical lines (from left edge)
        x := 0
        While (x < Width)
        {
            Gdip_DrawLine(G, pPenGrid, x, 0, x, Height)
            x += spacing
        }

        ;; Draw horizontal lines (from top edge)
        y := 0
        While (y < Height)
        {
            Gdip_DrawLine(G, pPenGrid, 0, y, Width, y)
            y += spacing
        }
        Gdip_DeletePen(pPenGrid)
    }

    UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
}

;;∙------∙Close with ESC key.
Esc::ExitApp

Exit:
    Gdip_Shutdown(pToken)
    ExitApp
Return

;;∙------∙Title.
TitleLabel:
return

;;∙------∙Function to show version information.
ShowVersionInfo:
{
    version := "2.0.0"

    MsgBox, 64, Version Info,
    (
Grid Master: %version%
		
Author: Special-Niewbie Softwares
Copyright (C) 2025 Special-Niewbie Softwares
    )
    Return
}

ReloadScript:
    Reload
return

OpenProjectSite:
    Run, https://github.com/Special-Niewbie/GridMaster

OpenDonationSite:
	Run, https://www.paypal.com/ncp/payment/WYU4A2HTRTVHG
return

ExitApp:
ExitApp

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
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

#SingleInstance, Force
#NoEnv
SetBatchLines, -1
#Include, libs/Gdip_All.ahk

; === Inizializza GDI+ ===
If !pToken := Gdip_Startup()
{
    MsgBox, 48, GDI+ Error, Gdiplus non è stato avviato!
    ExitApp
}
OnExit, Exit

; === Impostazioni schermo ===
Width := A_ScreenWidth
Height := A_ScreenHeight
CenterX := Width // 2
CenterY := Height // 2

; === Variabili dinamiche ===
gridActive := false
gridSpacing := 100
lineColor := 0xFFFFFFFF ; Default white
hwnd1 := ""

Menu, Tray, NoStandard

; System Tray Menu
Menu, Tray, Add, 👉 >>> Grid Master Menu <<<, TitleLabel
Menu, Tray, Disable, 👉 >>> Grid Master Menu <<<
Menu, Tray, Add, , Separator
Menu, Tray, Add, Reload, ReloadScript
Menu, Tray, Add, Project Site, OpenProjectSite
Menu, Tray, Add, Donate, OpenDonationSite
Menu, Tray, Add, , Separator
Menu, Tray, Add, Show Version, ShowVersionInfo
Menu, Tray, Add, Exit, ExitApp

; === GUI ===
Gui, 2:+AlwaysOnTop +ToolWindow
Gui, 2:Add, Text,, Grid spacing (px):
Gui, 2:Add, Edit, vSpacingEdit w60, %gridSpacing%
Gui, 2:Add, Checkbox, vGridToggle, Draw Full Grid
Gui, 2:Add, DropDownList, vColorChoice w100 Choose1, White|Red|Green|Blue|Yellow
Gui, 2:Add, Button, x20 y+10 w70 gClearDraw, Cancel
Gui, 2:Add, Button, x+10 yp w70 gStartDraw, Start
Gui, 2:Show,, Grid Master

; === Disegna subito la croce centrale ===
DrawOverlay(gridSpacing, false, lineColor)
Return

StartDraw:
Gui, 2:Submit, NoHide
spacing := SpacingEdit
if (spacing < 1)
{
    MsgBox, Please enter a valid spacing.
    Return
}

; Colori base ARGB
colors := {"White": 0xFFFFFFFF, "Red": 0xFFFF0000, "Green": 0xFF00FF00, "Blue": 0xFF0000FF, "Yellow": 0xFFFFFF00}
lineColor := colors[ColorChoice]
gridActive := GridToggle

DrawOverlay(spacing, gridActive, lineColor)
Return

ClearDraw:
DrawOverlay(0, false, lineColor)
Return

DrawOverlay(spacing, drawGrid, color)
{
    global hwnd1, pToken, Width, Height, CenterX, CenterY

    ; Distruggi finestra se esiste
    if (hwnd1)
    {
        WinClose, ahk_id %hwnd1%
        hwnd1 := ""
    }

    ; Nuova finestra trasparente
    Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, 1: Show, NA
    hwnd1 := WinExist()

    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)

    pPen := Gdip_CreatePen(color, 1)

    ; Croce centrale
    Gdip_DrawLine(G, pPen, 0, CenterY, Width, CenterY)
    Gdip_DrawLine(G, pPen, CenterX, 0, CenterX, Height)

    ; Griglia laterale se attiva
    if (drawGrid)
    {
        maxRight := Width - CenterX
        maxLeft := CenterX
        maxTop := CenterY
        maxBottom := Height - CenterY

        ; Calcolo numero massimo righe in ogni direzione
        countX := Floor(maxRight / spacing)
        countY := Floor(maxBottom / spacing)

        Loop, %countX%
        {
            offset := A_Index * spacing
            Gdip_DrawLine(G, pPen, CenterX + offset, 0, CenterX + offset, Height)
            Gdip_DrawLine(G, pPen, CenterX - offset, 0, CenterX - offset, Height)
        }

        Loop, %countY%
        {
            offset := A_Index * spacing
            Gdip_DrawLine(G, pPen, 0, CenterY + offset, Width, CenterY + offset)
            Gdip_DrawLine(G, pPen, 0, CenterY - offset, Width, CenterY - offset)
        }
    }

    UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

    Gdip_DeletePen(pPen)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
}


; Chiusura con ESC
Esc::ExitApp

Exit:
Gdip_Shutdown(pToken)
ExitApp
Return

; Title
TitleLabel:
return

; Function to show version information
ShowVersionInfo:
{
    version := "1.0.0"

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

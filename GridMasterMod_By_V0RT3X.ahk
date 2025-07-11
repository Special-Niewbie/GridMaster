#NoEnv
#Persistent
#SingleInstance, Force
SetBatchLines, -1
SetWinDelay, 0
OnMessage(0x0201, "WM_LBUTTONDOWNdrag")    ;;∙------∙Handle drag for captionless GUI window.

;;∙======∙Initialize GDI+ Graphics System.
If !pToken := Gdip_Startup()
{
    MsgBox, 48, GDI+ Error, Gdiplus failed to start!, 5
    ExitApp
}
OnExit, ExitSub    ;;∙------∙Ensure cleanup on exit.

;;∙======∙Global Settings.
global Width := A_ScreenWidth
global Height := A_ScreenHeight
global CenterX := Width // 2
global CenterY := Height // 2
global hwnd1 := ""    ;;∙------∙Overlay window handle
global pToken
global gridSpacing := 50
global gridThick := 2
global centerThick := 1
global ruleThirdsThick := 2
global rulerThick := 1
global gridOpacity := 255
global centerOpacity := 255
global ruleThirdsOpacity := 255
global rulerOpacity := 200
global rulerIncrement := 50
global gridType := "Rectangular"
global isoAngle := 30
global radialRings := 8
global radialSpokes := 12
global perspectiveLines := 8
global perspectiveVPX := 0
global perspectiveVPY := -200
global rulerPosition := "All"

;;∙======∙GUI appearance and layout settings.
guiX := 1000
guiY := 300
guiW := 360
guiH := 620
guiColor := "Black"
tranView := 225
mainFont := "Arial"
inputFont := "Segoe UI"
noteFont := "Calibri"

;;∙======∙Create Main GUI.
CreateGUI()
return

CreateGUI() {
    global

    Gui, Main:New, +AlwaysOnTop +ToolWindow -Caption +Border +E0x80000
    Gui, Main:Color, %guiColor%
    Gui, Main:Font, s9 cAqua, %mainFont%

    Gui, Main:Add, Text, x15 y20 BackgroundTrans, Grid Type:
    Gui, Main:Add, DropDownList, x115 yp-3 vGridTypeChoice w110 Choose1, Rectangular|Radial|Isometric|Perspective

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Spacing:`n(pixels)
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x310 yp vSpacingEdit w35, %gridSpacing%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Grid Lines Color:
    Gui, Main:Add, DropDownList, x115 yp-3 vGridColorChoice w110 Choose11, Maroon|Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Olive|Lime|Green|Aqua|Teal|Blue|Navy|Blue-Purple|Violet|Red-Purple|Fuchsia|Pink|White|Gray|Silver|Black

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Grid Lines:`nThickness
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x310 yp vGridThickEdit w35, %gridThick%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Cross Hair Color:
    Gui, Main:Add, DropDownList, x115 yp vCenterColorChoice w110 Choose15, Maroon|Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Olive|Lime|Green|Aqua|Teal|Blue|Navy|Blue-Purple|Violet|Red-Purple|Fuchsia|Pink|White|Gray|Silver|Black

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Cross Hair:`nThickness
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x310 yp vCenterThickEdit w35, %centerThick%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Rule of Thirds:
    Gui, Main:Add, DropDownList, x115 yp vRuleThirdsColorChoice w110 Choose5, Maroon|Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Olive|Lime|Green|Aqua|Teal|Blue|Navy|Blue-Purple|Violet|Red-Purple|Fuchsia|Pink|White|Gray|Silver|Black

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Rule Thirds:`nThickness
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x310 yp vRuleThirdsThickEdit w35, %ruleThirdsThick%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Ruler Color:
    Gui, Main:Add, DropDownList, x115 yp vRulerColorChoice w110 Choose20, Maroon|Red|Red-Orange|Orange|Yellow-Orange|Yellow|Yellow-Green|Olive|Lime|Green|Aqua|Teal|Blue|Navy|Blue-Purple|Violet|Red-Purple|Fuchsia|Pink|White|Gray|Silver|Black

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Increments:
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x310 yp vRulerIncrementEdit w35, %rulerIncrement%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Ruler Position:
    Gui, Main:Add, DropDownList, x115 yp vRulerPositionChoice w110 Choose1, All|Top|Bottom|Left|Right

    Gui, Main:Font, s10 cFFA500, Calibri
    Gui, Main:Add, Checkbox, x+20 yp+2 vRulerOverlayToggle, Ruler Overlay
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Radial Rings:
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x125 yp vRadialRingsEdit w35, %radialRings%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Radial Spokes:
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x280 yp vRadialSpokesEdit w35, %radialSpokes%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Isometric Angle:
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x125 yp vIsoAngleEdit w35, %isoAngle%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Perspective Lines:
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x280 yp vPerspLinesEdit w35, %perspectiveLines%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Grid Line Opacity:`n(0-255)
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x125 yp vGridOpacityEdit w35, %gridOpacity%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Cross Hair Opacity:`n(0-255)
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x280 yp vCenterOpacityEdit w35, %centerOpacity%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Add, Text, x15 y+25 BackgroundTrans, Rule of 3rd Opacity:`n(0-255)
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x125 yp vRuleThirdsOpacityEdit w35, %ruleThirdsOpacity%
    Gui, Main:Font, s9 cAqua Norm
    
    Gui, Main:Add, Text, x+15 yp BackgroundTrans, Ruler Opacity:`n(0-255)
    Gui, Main:Font, cBlue Bold
    Gui, Main:Add, Edit, x280 yp vRulerOpacityEdit w35, %rulerOpacity%
    Gui, Main:Font, s9 cAqua Norm

    Gui, Main:Font, s10 cFFA500, Calibri
    Gui, Main:Add, Checkbox, x55 y+25 vGridToggle Checked, Draw Full Grid
    Gui, Main:Add, Checkbox, x180 yp vCenterCrossToggle Checked, Show Cross Hairs
    Gui, Main:Add, Checkbox, x55 y+25 vRuleOfThirdsToggle, Rule of Thirds
    Gui, Main:Add, Checkbox, x180 yp vGradientFadeToggle, Gradient Fade

    Gui, Main:Font, Norm, %inputFont%
    Gui, Main:Add, Button, x25 y+15 w50 h25 gResetGUI, Reset
    Gui, Main:Add, Button, x+15 yp w50 h25 gHideGUI, Hide
    Gui, Main:Add, Button, x+15 yp w50 h25 gClearOverlay, Clear
    Gui, Main:Add, Button, x+15 yp w50 h25 Default gUpdateOverlay, Show
    Gui, Main:Add, Button, x+15 yp w50 h25 Default gExitOut, Exit

    Gui, Main:Font, s8 c676767 Italic, %noteFont%
    Gui, Main:Add, Text, x0 y+10 w%guiW% Center BackgroundTrans, ( Press F1 To Restore GUI Once Hidden )
    
    Gui, Main:Show, x%guiX% y%guiY% w%guiW% h%guiH%, Grid & Ruler Overlay
    WinSet, Transparent, %tranView%, Grid & Ruler Overlay
    ControlFocus, Button9, Grid & Ruler Overlay    ;;∙------∙Focus default button (Start) on GUI launch.
}

UpdateOverlay:
    Gui, Main:Submit, NoHide
    
    ;;∙======∙Validation check on input values.
    if (SpacingEdit < 1) || (CenterThickEdit < 1) || (GridThickEdit < 1) || (RuleThirdsThickEdit < 1)
    {
        MsgBox, Please enter valid values (spacing and thickness must be at least 1).
        return
    }
    
    ;;∙======∙Apply settings.
    gridSpacing := SpacingEdit
    centerThick := CenterThickEdit
    gridThick := GridThickEdit
    ruleThirdsThick := RuleThirdsThickEdit
    gridOpacity := GridOpacityEdit
    centerOpacity := CenterOpacityEdit
    ruleThirdsOpacity := RuleThirdsOpacityEdit
    rulerOpacity := RulerOpacityEdit
    rulerIncrement := RulerIncrementEdit
    gridType := GridTypeChoice
    isoAngle := IsoAngleEdit
    radialRings := RadialRingsEdit
    radialSpokes := RadialSpokesEdit
    perspectiveLines := PerspLinesEdit
    rulerPosition := RulerPositionChoice
    
        ;;∙======∙Color name-to-RGB mapping. (Primary/Secondary/Tertiary/Achromatic/& AHK)
    colors := {"Maroon":0xFF800000, "Red":0xFFFF0000, "Red-Orange":0xFFFF4500, "Orange":0xFFFFA500
        , "Yellow-Orange":0xFFFFBE00, "Yellow":0xFFFFFF00, "Yellow-Green":0xFF9ACD32, "Olive":0xFF808000
        , "Lime":0xFF00FF00, "Green":0xFF008000, "Aqua":0xFF00FFFF, "Teal":0xFF008B8B, "Blue":0xFF0000FF
        , "Navy":0xFF000080, "Blue-Purple":0xFF8A2BE2, "Violet":0xFF800080, "Red-Purple":0xFFC71585
        , "Fuchsia":0xFFFF00FF, "Pink":0xFFDE6FDE, "White":0xFFFFFFFF, "Gray":0xFF808080, "Silver":0xFFC0C0C0
        , "Black":0xFF000000}
    
    gridColor := (colors[GridColorChoice] & 0x00FFFFFF) | (gridOpacity << 24)
    centerColor := (colors[CenterColorChoice] & 0x00FFFFFF) | (centerOpacity << 24)
    ruleThirdsColor := (colors[RuleThirdsColorChoice] & 0x00FFFFFF) | (ruleThirdsOpacity << 24)
    rulerColor := (colors[RulerColorChoice] & 0x00FFFFFF) | (rulerOpacity << 24)
    
    ;;∙======∙Create overlay.
    CreateOverlay(GridToggle, CenterCrossToggle, RuleOfThirdsToggle, RulerOverlayToggle, GradientFadeToggle)
    return

ClearOverlay:
    if (hwnd1) {
        Gui, Overlay:Destroy
        hwnd1 := ""
    }
    return

HideGUI:
    Gui, Main:Hide
    return

ResetGUI:
    Reload
Return


F1::    ;;∙------∙🔥∙Hotkey to restore GUI after hiding.
    Gui, Main:Show
    WinSet, Transparent, %tranView%, Grid & Ruler Overlay
    return

WM_LBUTTONDOWNdrag() {
    PostMessage, 0x00A1, 2, 0
}

ExitOut:
ExitSub:
    Gdip_Shutdown(pToken)
    ExitApp
    return

CreateOverlay(drawGrid, drawCenter, drawRuleThirds, drawRuler, gradientFade) {
    global
    
    ;;∙======∙Destroy previous overlay if exists.
    if (hwnd1) {
        Gui, Overlay:Destroy
        hwnd1 := ""
    }
    
    ;;∙======∙Create new overlay.
    Gui, Overlay:New, -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, Overlay:Show, NA
    hwnd1 := WinExist()
    
    ;;∙======∙Prepare graphics.
    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)
    
    ;;∙======∙Draw ruler if enabled.
    if (drawRuler) {
        DrawRuler(G, rulerColor, rulerIncrement, rulerPosition)
    }
    
    ;;∙======∙Draw center cross if enabled.
    if (drawCenter) {
        pPenCenter := Gdip_CreatePen(centerColor, centerThick)
        Gdip_DrawLine(G, pPenCenter, 0, CenterY, Width, CenterY)
        Gdip_DrawLine(G, pPenCenter, CenterX, 0, CenterX, Height)
        Gdip_DeletePen(pPenCenter)
    }
    
    ;;∙======∙Draw rule of thirds if enabled.
    if (drawRuleThirds) {
        pPenRuleThirds := Gdip_CreatePen(ruleThirdsColor, ruleThirdsThick)
        thirdX1 := Width / 3
        thirdX2 := Width * 2 / 3
        thirdY1 := Height / 3
        thirdY2 := Height * 2 / 3
        Gdip_DrawLine(G, pPenRuleThirds, thirdX1, 0, thirdX1, Height)
        Gdip_DrawLine(G, pPenRuleThirds, thirdX2, 0, thirdX2, Height)
        Gdip_DrawLine(G, pPenRuleThirds, 0, thirdY1, Width, thirdY1)
        Gdip_DrawLine(G, pPenRuleThirds, 0, thirdY2, Width, thirdY2)
        Gdip_DeletePen(pPenRuleThirds)
    }
    
    ;;∙======∙Draw grid if enabled.
    if (drawGrid) {
        if (gridType = "Rectangular") {
            DrawRectangularGrid(G, gridSpacing, gridColor, gridThick, gradientFade)
        }
        else if (gridType = "Isometric") {
            DrawIsometricGrid(G, gridSpacing, gridColor, gridThick, isoAngle)
        }
        else if (gridType = "Radial") {
            DrawRadialGrid(G, gridColor, gridThick, radialRings, radialSpokes)
        }
        else if (gridType = "Perspective") {
            DrawPerspectiveGrid(G, gridColor, gridThick, perspectiveLines)
        }
    }
    
    ;;∙======∙Update window.
    UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
    
    ;;∙======∙Cleanup.
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
}

DrawRuler(G, color, increment, position) {
    global Width, Height
    
    pPen := Gdip_CreatePen(color, 1)
    pBrush := Gdip_BrushCreateSolid(color)
    
    ;;∙======∙Create font for measurements.
    pFont := Gdip_FontCreate("Arial", 10, 0)  ; Font family, size, style.
    
    ;;∙======∙Draw top ruler.
    if (position = "All" || position = "Top") {
        ; Semi-transparent background for better text visibility
        bgBrush := Gdip_BrushCreateSolid((color & 0x00FFFFFF) | 0x80000000)  ; 50% opacity.
        Gdip_FillRectangle(G, bgBrush, 0, 0, Width, 25)
        Gdip_DeleteBrush(bgBrush)
        
        Loop, % Ceil(Width / 10) {
            x := (A_Index - 1) * 10
            if (Mod(x, increment) = 0) {
                ; Major tick with measurement
                Gdip_DrawLine(G, pPen, x, 0, x, 20)
                if (x > 0) {  ; Don't draw 0 at the very edge
                    Gdip_TextToGraphics(G, x, pFont, pBrush, x+2, 2, 50, 20, 0)
                }
            } else if (Mod(x, increment/2) = 0) {
                ; Medium tick
                Gdip_DrawLine(G, pPen, x, 0, x, 15)
            } else {
                ; Minor tick
                Gdip_DrawLine(G, pPen, x, 0, x, 8)
            }
        }
    }
    
    ;;∙======∙Draw bottom ruler.
    if (position = "All" || position = "Bottom") {
        bgBrush := Gdip_BrushCreateSolid((color & 0x00FFFFFF) | 0x80000000)
        Gdip_FillRectangle(G, bgBrush, 0, Height-25, Width, 25)
        Gdip_DeleteBrush(bgBrush)
        
        Loop, % Ceil(Width / 10) {
            x := (A_Index - 1) * 10
            if (Mod(x, increment) = 0) {
                Gdip_DrawLine(G, pPen, x, Height-20, x, Height)
                if (x > 0) {
                    Gdip_TextToGraphics(G, x, pFont, pBrush, x+2, Height-18, 50, 20, 0)
                }
            } else if (Mod(x, increment/2) = 0) {
                Gdip_DrawLine(G, pPen, x, Height-15, x, Height)
            } else {
                Gdip_DrawLine(G, pPen, x, Height-8, x, Height)
            }
        }
    }
    
    ;;∙======∙Draw left ruler.
    if (position = "All" || position = "Left") {
        bgBrush := Gdip_BrushCreateSolid((color & 0x00FFFFFF) | 0x80000000)
        Gdip_FillRectangle(G, bgBrush, 0, 0, 25, Height)
        Gdip_DeleteBrush(bgBrush)
        
        Loop, % Ceil(Height / 10) {
            y := (A_Index - 1) * 10
            if (Mod(y, increment) = 0) {
                Gdip_DrawLine(G, pPen, 0, y, 20, y)
                if (y > 0) {
                    ; Rotate text for vertical ruler (optional)
                    Gdip_TextToGraphics(G, y, pFont, pBrush, 2, y-8, 40, 16, 0)
                }
            } else if (Mod(y, increment/2) = 0) {
                Gdip_DrawLine(G, pPen, 0, y, 15, y)
            } else {
                Gdip_DrawLine(G, pPen, 0, y, 8, y)
            }
        }
    }
    
    ;;∙======∙Draw right ruler.
    if (position = "All" || position = "Right") {
        bgBrush := Gdip_BrushCreateSolid((color & 0x00FFFFFF) | 0x80000000)
        Gdip_FillRectangle(G, bgBrush, Width-25, 0, 25, Height)
        Gdip_DeleteBrush(bgBrush)
        
        Loop, % Ceil(Height / 10) {
            y := (A_Index - 1) * 10
            if (Mod(y, increment) = 0) {
                Gdip_DrawLine(G, pPen, Width-20, y, Width, y)
                if (y > 0) {
                    Gdip_TextToGraphics(G, y, pFont, pBrush, Width-22, y-8, 40, 16, 0)
                }
            } else if (Mod(y, increment/2) = 0) {
                Gdip_DrawLine(G, pPen, Width-15, y, Width, y)
            } else {
                Gdip_DrawLine(G, pPen, Width-8, y, Width, y)
            }
        }
    }
    
    Gdip_DeleteBrush(pBrush)
    Gdip_DeletePen(pPen)
    Gdip_DeleteFont(pFont)
}

DrawRectangularGrid(G, spacing, color, thickness, gradientFade) {
    global Width, Height, CenterX, CenterY
    
    pPen := Gdip_CreatePen(color, thickness)
    
    ;;∙======∙Vertical lines.
    Loop, % Ceil(Width / spacing) + 1 {
        x := CenterX + (A_Index * spacing)
        if (x < Width) {
            Gdip_DrawLine(G, pPen, x, 0, x, Height)
        }
        
        x := CenterX - (A_Index * spacing)
        if (x > 0) {
            Gdip_DrawLine(G, pPen, x, 0, x, Height)
        }
    }
    
    ;;∙======∙Horizontal lines.
    Loop, % Ceil(Height / spacing) + 1 {
        y := CenterY + (A_Index * spacing)
        if (y < Height) {
            Gdip_DrawLine(G, pPen, 0, y, Width, y)
        }
        
        y := CenterY - (A_Index * spacing)
        if (y > 0) {
            Gdip_DrawLine(G, pPen, 0, y, Width, y)
        }
    }
    
    Gdip_DeletePen(pPen)
}

DrawIsometricGrid(G, spacing, color, thickness, angle) {
    global Width, Height, CenterX, CenterY
    
    pPen := Gdip_CreatePen(color, thickness)
    angleRad := angle * 0.0174533  ; Degrees to radians
    
    ;;∙======∙Calculate direction vectors
    dx1 := Cos(angleRad)
    dy1 := Sin(angleRad)
    dx2 := Cos(angleRad + 2.0944)  ; 120 degrees
    dy2 := Sin(angleRad + 2.0944)
    dx3 := Cos(angleRad + 4.1888)  ; 240 degrees
    dy3 := Sin(angleRad + 4.1888)
    
    ;;∙======∙Draw lines in three directions
    maxDist := Sqrt(Width*Width + Height*Height)
    lineCount := Ceil(maxDist / spacing)
    
    Loop, % lineCount {
        offset := A_Index * spacing
        
        ;;∙======∙Direction 1
        x1 := CenterX - dx1 * offset
        y1 := CenterY - dy1 * offset
        x2 := CenterX + dx1 * offset
        y2 := CenterY + dy1 * offset
        Gdip_DrawLine(G, pPen, x1 - dx1*maxDist, y1 - dy1*maxDist, x2 + dx1*maxDist, y2 + dy1*maxDist)
        
        ;;∙======∙Direction 2
        x1 := CenterX - dx2 * offset
        y1 := CenterY - dy2 * offset
        x2 := CenterX + dx2 * offset
        y2 := CenterY + dy2 * offset
        Gdip_DrawLine(G, pPen, x1 - dx2*maxDist, y1 - dy2*maxDist, x2 + dx2*maxDist, y2 + dy2*maxDist)
        
        ;;∙======∙Direction 3
        x1 := CenterX - dx3 * offset
        y1 := CenterY - dy3 * offset
        x2 := CenterX + dx3 * offset
        y2 := CenterY + dy3 * offset
        Gdip_DrawLine(G, pPen, x1 - dx3*maxDist, y1 - dy3*maxDist, x2 + dx3*maxDist, y2 + dy3*maxDist)
    }
    
    Gdip_DeletePen(pPen)
}

DrawRadialGrid(G, color, thickness, rings, spokes) {
    global Width, Height, CenterX, CenterY
    
    pPen := Gdip_CreatePen(color, thickness)
    maxRadius := Min(CenterX, CenterY, Width - CenterX, Height - CenterY)
    
    ;;∙======∙Draw concentric circles
    Loop, % rings {
        radius := (A_Index / rings) * maxRadius
        Gdip_DrawEllipse(G, pPen, CenterX - radius, CenterY - radius, radius * 2, radius * 2)
    }
    
    ;;∙======∙Draw radial spokes
    Loop, % spokes {
        angle := (A_Index - 1) * 6.28318530718 / spokes  ; 2π / spokes
        x2 := CenterX + Cos(angle) * maxRadius
        y2 := CenterY + Sin(angle) * maxRadius
        Gdip_DrawLine(G, pPen, CenterX, CenterY, x2, y2)
    }
    
    Gdip_DeletePen(pPen)
}

DrawPerspectiveGrid(G, color, thickness, lines) {
    global Width, Height, CenterX, CenterY, perspectiveVPX, perspectiveVPY
    
    pPen := Gdip_CreatePen(color, thickness)
    vpX := CenterX + perspectiveVPX
    vpY := CenterY + perspectiveVPY
    
    ;;∙======∙Draw perspective lines
    Loop, % lines {
        ; Horizontal lines
        y := A_Index * Height / (lines + 1)
        Gdip_DrawLine(G, pPen, 0, y, Width, y)
        
        ; Vertical lines
        x := A_Index * Width / (lines + 1)
        Gdip_DrawLine(G, pPen, x, 0, x, Height)
    }
    
    ;;∙======∙Draw guidelines to vanishing point
    Gdip_DrawLine(G, pPen, vpX, vpY, 0, 0)
    Gdip_DrawLine(G, pPen, vpX, vpY, Width, 0)
    Gdip_DrawLine(G, pPen, vpX, vpY, 0, Height)
    Gdip_DrawLine(G, pPen, vpX, vpY, Width, Height)
    
    Gdip_DeletePen(pPen)
}


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

Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
    return DllCall("gdiplus\GdipDrawEllipse", "ptr", pGraphics, "ptr", pPen, "float", x, "float", y, "float", w, "float", h)
}

Gdip_FontCreate(FontName, Size, Style:=0)
{
    DllCall("gdiplus\GdipCreateFont", "ptr", Gdip_FontFamilyCreate(FontName), "float", Size, "int", Style, "int", 0, "ptr*", pFont)
    return pFont
}

Gdip_FontFamilyCreate(FontName)
{
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "wstr", FontName, "ptr", 0, "ptr*", pFontFamily)
    return pFontFamily
}

Gdip_DeleteFont(pFont)
{
    return DllCall("gdiplus\GdipDeleteFont", "ptr", pFont)
}

Gdip_TextToGraphics(pGraphics, Text, pFont, pBrush, x, y, w, h, Align:=0)
{
    CreateRectF(RC, x, y, w, h)
    DllCall("gdiplus\GdipDrawString", "ptr", pGraphics, "wstr", Text, "int", -1, "ptr", pFont, "ptr", &RC, "ptr", Gdip_StringFormatCreate(Align), "ptr", pBrush)
    return
}

Gdip_StringFormatCreate(Format:=0)
{
    DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", 0, "ptr*", pFormat)
    return pFormat
}

CreateRectF(ByRef RectF, x, y, w, h)
{
    VarSetCapacity(RectF, 16)
    NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}

Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
    return DllCall("gdiplus\GdipFillRectangle", "ptr", pGraphics, "ptr", pBrush, "float", x, "float", y, "float", w, "float", h)
}

Gdip_BrushCreateSolid(ARGB=0xff000000)
{
    DllCall("gdiplus\GdipCreateSolidFill", "int", ARGB, "ptr*", pBrush)
    return pBrush
}

Gdip_DeletePen(pPen)
{
    return DllCall("gdiplus\GdipDeletePen", "ptr", pPen)
}

Gdip_DeleteBrush(pBrush)
{
    return DllCall("gdiplus\GdipDeleteBrush", "ptr", pBrush)
}

Gdip_DeleteGraphics(pGraphics)
{
    return DllCall("gdiplus\GdipDeleteGraphics", "ptr", pGraphics)
}

CreateDIBSection(w, h, hdc:="", bpp:=32, ByRef ppvBits:=0)
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

CreateCompatibleDC(hdc:=0)
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

GetDC(hwnd:=0)
{
    return DllCall("GetDC", "ptr", hwnd)
}

ReleaseDC(hdc, hwnd:=0)
{
    return DllCall("ReleaseDC", "ptr", hwnd, "ptr", hdc)
}

UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
{
    if (x != "" && y != "")
        VarSetCapacity(pt, 8), NumPut(x, pt, 0), NumPut(y, pt, 4)
    if (w = "" || h = "")
        WinGetPos,,, w, h, ahk_id %hwnd%
    return DllCall("UpdateLayeredWindow", "ptr", hwnd, "ptr", 0, "ptr", ((x = "" && y = "") ? 0 : &pt), "int64*", w|h<<32, "ptr", hdc, "int64*", 0, "uint", 0, "uint*", Alpha<<16|1<<24, "uint", 2)
}
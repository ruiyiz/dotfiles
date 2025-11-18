; Leader Key: Win+Space
#Space::
{
    ToolTip "Leader: [w]indow [a]pp [t]ext"
    ih := InputHook("L1 T3")
    ih.Start()
    ih.Wait()
    ToolTip  ; Clear
    
    if (ih.Input = "w") {
        ToolTip "Window: [c]enter [h]alf [f]ull [m]ax [r]estore [0]BBG [1-6]sizes"
        ih2 := InputHook("L1 T3")
        ih2.Start()
        ih2.Wait()
        ToolTip
        
        ; Get screen dimensions
        MonitorGetWorkArea(, &workLeft, &workTop, &workRight, &workBottom)
        screenWidth := workRight - workLeft
        screenHeight := workBottom - workTop
        
        Switch ih2.Input {
            Case "c":  ; Center window (keep current size)
                WinGetPos(,, &width, &height, "A")
                newX := workLeft + (screenWidth - width) / 2
                newY := workTop + (screenHeight - height) / 2
                WinMove newX, newY,,, "A"
            
            Case "h":  ; Half-center (60% width, screen height, centered)
                newWidth := screenWidth * 0.6
                newHeight := screenHeight
                newX := workLeft + (screenWidth - newWidth) / 2
                newY := workTop + (screenHeight - newHeight) / 2
                WinMove newX, newY, newWidth, newHeight, "A"
            
            Case "f":  ; Fill screen (not maximized, just sized to work area)
                WinRestore "A"  ; Un-maximize first if needed
                WinMove workLeft, workTop, screenWidth, screenHeight, "A"
            
            Case "m":  ; Maximize
                WinMaximize "A"
            
            Case "r":  ; Restore
                WinRestore "A"
            
            ; Preset sizes (centered)
            Case "0":  ; 1900x1200 centered (Bloomberg)
                newWidth := 1900
                newHeight := 1200
                newX := workLeft + (screenWidth - newWidth) / 2
                newY := workTop + (screenHeight - newHeight) / 2
                WinMove newX, newY, newWidth, newHeight, "A"
            
            Case "1":  ; 1920x1080 centered
                newWidth := 1920
                newHeight := 1080
                newX := workLeft + (screenWidth - newWidth) / 2
                newY := workTop + (screenHeight - newHeight) / 2
                WinMove newX, newY, newWidth, newHeight, "A"
            
            Case "2":  ; 1600x900 centered
                newWidth := 1600
                newHeight := 900
                newX := workLeft + (screenWidth - newWidth) / 2
                newY := workTop + (screenHeight - newHeight) / 2
                WinMove newX, newY, newWidth, newHeight, "A"
            
            Case "3":  ; 1280x720 centered
                newWidth := 1280
                newHeight := 720
                newX := workLeft + (screenWidth - newWidth) / 2
                newY := workTop + (screenHeight - newHeight) / 2
                WinMove newX, newY, newWidth, newHeight, "A"
            
            Case "4":  ; 2/3 center (66% width, 80% height)
                newWidth := screenWidth * 0.66
                newHeight := screenHeight * 0.8
                newX := workLeft + (screenWidth - newWidth) / 2
                newY := workTop + (screenHeight - newHeight) / 2
                WinMove newX, newY, newWidth, newHeight, "A"
            
            Case "5":  ; 3/4 center (75% width, 85% height)
                newWidth := screenWidth * 0.75
                newHeight := screenHeight * 0.85
                newX := workLeft + (screenWidth - newWidth) / 2
                newY := workTop + (screenHeight - newHeight) / 2
                WinMove newX, newY, newWidth, newHeight, "A"
            
            Case "6":  ; Square in center (80% of screen height for both dimensions)
                size := screenHeight * 0.8
                newX := workLeft + (screenWidth - size) / 2
                newY := workTop + (screenHeight - size) / 2
                WinMove newX, newY, size, size, "A"
        }
    }
    
    ; Placeholder for other categories
    else if (ih.Input = "a") {
        ToolTip "App: [n]otepad [c]alc [t]erminal"
        ; Add app launching shortcuts here
        ih2 := InputHook("L1 T3")
        ih2.Start()
        ih2.Wait()
        ToolTip
    }
    
    else if (ih.Input = "t") {
        ToolTip "Text: [u]pper [l]ower [c]opy"
        ; Add text manipulation shortcuts here
        ih2 := InputHook("L1 T3")
        ih2.Start()
        ih2.Wait()
        ToolTip
    }
}
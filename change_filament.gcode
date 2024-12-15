;=======================================================================
; Machine: A1 mini
; Version: v1.0
; Author: CoolZeroNL
;
; Instructions:
; ------------
; - in Bambu Studio, u mark your color swapps with the "Change Filament" option
;
; - when print has paused
; - go into control -> filament
; - load the new filament by pushing the load button or using the lower extruder-button 
; - resume the print
;=======================================================================
; https://forum.bambulab.com/t/bambu-lab-x1-specific-g-code/666
;=======================================================================

; turn on clog detect
G392 S0

; turn off mass estimation
M1007 S0

; set printing and travel acceleration in mm/min^2
M204 S9000

{if toolchange_count > 1}
    ; set CNC workspace plane
    G17

    ; spiral lift a little from second lift
    G2 Z{max_layer_z + 0.4} I0.86 J0.86 P1 F10000
    G1 Z{max_layer_z + 3.0} F1200

    ; Waits until previous cycle is done, in this case moving up
    M400

    ; turn off fans P1 and P2
    M106 P1 S0
    M106 P2 S0

    ; check temp
    {if old_filament_temp > 142 && next_extruder < 255}
        M104 S[old_filament_temp]
    {endif}
    
    ; we need more power for X stepper, else it wont cut, and skips steps
    M17 X1.2
    
    ; move before cutter
    G1 X185 F10000
    
    ; slowly cut
    G1 X197 F100
    G1 X199 F800

    ; slowly move back from cut
    G1 X190 F1000
    
    ; move to poop chute and bed to front
    G1 X0 F10000
    G1 X-13.5 F9000 ; chute move
    
    ; reset back to default power for X stepper
    M17 X0.7
    
    ; unload, extruder retract
    G1 E-25 F900
    
    ; wait untill finish
    M400

    ; AMS stuff
    ; M620.1 E F[old_filament_e_feedrate] T{nozzle_temperature_range_high[previous_extruder]}
    ; M620.10 A0 F[old_filament_e_feedrate]
    ; T[next_extruder]
    ; M620.1 E F[new_filament_e_feedrate] T{nozzle_temperature_range_high[next_extruder]}
    ; M620.10 A1 F[new_filament_e_feedrate] L[flush_length] H[nozzle_diameter] T[nozzle_temperature_range_high]

    ; play sound
    M17                                                 ; Enable Steppers
    M400 S1                                             ; wait 1 sec
    M1006 S1
    M1006 A0 B0 L100 C37 D10 M100 E37 F10 N100
    M1006 A0 B0 L100 C41 D10 M100 E41 F10 N100
    M1006 A0 B0 L100 C44 D10 M100 E44 F10 N100
    M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
    M1006 A43 B10 L100 C39 D10 M100 E46 F10 N100
    M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
    M1006 A0 B0 L100 C39 D10 M100 E43 F10 N100
    M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
    M1006 A0 B0 L100 C41 D10 M100 E41 F10 N100
    M1006 A0 B0 L100 C44 D10 M100 E44 F10 N100
    M1006 A0 B0 L100 C49 D10 M100 E49 F10 N100
    M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
    M1006 A44 B10 L100 C39 D10 M100 E48 F10 N100
    M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
    M1006 A0 B0 L100 C39 D10 M100 E44 F10 N100
    M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
    M1006 A43 B10 L100 C39 D10 M100 E46 F10 N100
    M1006 W
    
    ; pause for user to load and press resume    
    M400 U1
    ; pause will move the nozzle to the poop chute, if its not place there
    ; resume, will do a purge, and a wipe...

    ; ---> we manual now change the filament, and press load

    ; prevent oozing when moving, extruder retract
    G1 E-2 F900

{endif}

; as there is no AMS, these next three lines only serve to hide T[next_extruder]
; if this was not included, the T[next_extruder] command is input after this
; code and will cause the system to hang as the toolchange command searches
; for the AMS

M620 S[next_extruder]A
T[next_extruder]
M621 S[next_extruder]A

;
G392 S1

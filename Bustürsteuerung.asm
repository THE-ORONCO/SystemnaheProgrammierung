;----------------------------------
; Bustürsteuerung-Steuerung
;----------------------------------
CSEG AT 0H
LJMP Init
ORG 80H

; Einsprung für den Timeout des Timers
ORG 000Bh
CALL TIMEOUT_TIMER_DOOR_1
RETI

; Einsprung für den Timeout des Timers von Tür 2
ORG 001Bh
CALL TIMEOUT_TIMER_DOOR_2
RETI


; Eingabevektoren TAST und SENS
; Taster:
; STOP_IN_1     Taster, zum Öffnen der Tür 1 von innnen (Stop-Taster)
; STOP_IN_2     Taster, zum Öffnen der Tür 2 von innnen (Stop-Taster)
; STOP_OUT_1    Taster, zum Öffnen der Tür 1 von außen
; STOP_OUT_2    Taster, zum Öffnen der Tür 2 von außen
; DRIVERS_OK    Freigabe-Taster des Busfahrers
;
; Sensoren:
; OPENED_1      Ausgabe des Geöffnet-Sensors der Tür 1
; OPENED_2      Ausgabe des Geöffnet-Sensors der Tür 2
; CLOSED_1      Ausgabe des Geschlossen-Sensors der Tür 1
; CLOSED_2      Ausgabe des Geschlossen-Sensors der Tür 2
; BLOCKED_1     Jemand steht in der schließenden Tür 1
; BLOCKED_2     Jemand steht in der schließenden Tür 2

; Zeug das Menschen verändern können (Taster)
TAST EQU 20H
STOP_IN_1  EQU TAST.0
STOP_OUT_1 EQU TAST.1

DRIVERS_OK EQU TAST.4

STOP_IN_2  EQU TAST.6
STOP_OUT_2 EQU TAST.7


; Das was der Bus fühlt (Gefühle bzw. Sensoren)
SENS EQU 21H
OPENED_1   EQU SENS.0
CLOSED_1   EQU SENS.1
BlOCKED_1  EQU SENS.2

OPENED_2   EQU SENS.5
CLOSED_2   EQU SENS.6
BlOCKED_2  EQU SENS.7

; Ausgabevektor
; OPEN_1        Tür 1 soll geöffnet werden
; OPEN_2        Tür 2 soll geöffnet werden
; CLOSE_1       Tür 1 soll geschlossen werden
; CLOSE_2       Tür 2 soll geschlossen werden

; Motorensteuerung -> einer An Tür bewegt sich | beide an -> Tür blockiert 
MOTR EQU 22H
OPEN_1 EQU MOTR.0
CLOSE_1 EQU MOTR.1

OPEN_2 EQU MOTR.6
CLOSE_2 EQU MOTR.7

; FlipFlops zum Zwischenspeichern
FF EQU 23H
STOP_1_FF EQU FF.0
OPEN_1_FF EQU FF.1
STOP_2_FF EQU FF.6
OPEN_2_FF EQU FF.7

; INITIALISIERUNG
Init:
    MOV TAST, #00H
    MOV SENS, #00H
    MOV MOTR, #00H
    MOV FF, #00H

    MOV P0, #00H ; P0 wird verwendet um TAST von der IDE anzusprechen
    MOV P1, #42H ; P1 wird verwendet um SENS in der IDE anzuzeigen
    MOV P2, #00H ; P2 wird verwendet um MOTR in der IDE anzuzeigen



    ; TIMER Kram
    MOV IE, #10011010b      ; aktivieren der Timer-Interupts
    MOV tmod, #00100010b    ; 1. Bit für Timer0 -> mod 2 und 5. Bit für Timer1 -> mod 2
    MOV tl0, #000h          ; Timer0-Initialsierung 
    MOV th0, #001h

    MOV tl1, #000h          ; Timer1-Initialsierung 
    MOV th1, #001h

    MOV r1, #5h     ; Wiederholungen für Timer1 auf 5 setzen (im echten Leben bräuchten wir 39368 Wiederholungen)
    MOV r2, #5h     ; Wiederholungen für Timer2 auf 5 setzen (im echten Leben bräuchten wir 39368 Wiederholungen)

    LJMP Anfang


;-----------------------------------------
; PROGRAMM-SCHLEIFE
;-----------------------------------------

Anfang:
    ; Eingaben aus Port 0 und 1 in TAST und SENS schreiben und MOTR, sowie FF in Port 2 und 3 (IDE-Anzeige) schreiben
    MOV TAST, P0
    MOV SENS, P1
    MOV P2, MOTR
    MOV P3, FF

    ; ------------------------------------------ Tür 1

    ; Abfrage ob ein Stop-Taster (innen oder außen) für Tür 1 gedrückt wurde (und wenn ja FF setzen)
    MOV C, STOP_IN_1
    ORL C, STOP_OUT_1
    JC SET_STOP_1_FF

CONTINUE_AFTER_STOP_1_FF_SET:

    ; Wenn Stop-Taster 1 (FlipFlop) und Freigabe gesetzt, OPEN_1 (Motor 1 bzw. zugehöriges FF) auf 1 setzen
    MOV C, STOP_1_FF
    ANL C, DRIVERS_OK
    JC SET_OPEN_1_FF

CONTINUE_AFTER_OPEN_1_FF_SET:

    ; Schauen ob die Tür 1 geöffnet ist (Endtaster gesetzt) und wenn ja den Timer starten
    MOV C, OPEN_1
    ANL C, OPENED_1
    JC START_TIMER_DOOR_1
CONTINUE_AFTER_TIMER_1_SET:

    ; Wenn Tür nicht zu ist und der Zu-Motor an ist, dann schaue ob Blockiert
    MOV C, CLOSED_1
    CPL C
    ANL C, CLOSE_1
    JC CHECK_FOR_BLOCKED_DOOR_1

CONTINUE_AFTER_CHECK_FOR_BLOCKED_DOOR_1:

    ; ------------------------------------------ Tür 2

    ; Abfrage ob ein Stop-Taster (innen oder außen) für Tür 2 gedrückt wurde
    MOV C, STOP_IN_2
    ORL C, STOP_OUT_2
    JC SET_STOP_2_FF

CONTINUE_AFTER_STOP_2_FF_SET:

    ; Wenn Stop-Taster 2 (FlipFlop) und Freigabe gesetzt, OPEN_2 (Motor 2 bzw. zugehöriges FF) auf 1 setzen
    MOV C, STOP_2_FF
    ANL C, DRIVERS_OK
    JC SET_OPEN_2_FF

CONTINUE_AFTER_OPEN_2_FF_SET:

    ; Schauen ob die Tür 2 geöffnet ist (Endtaster gesetzt) und wenn ja den Timer starten
    MOV C, OPEN_2
    ANL C, OPENED_2
    JC START_TIMER_DOOR_2
CONTINUE_AFTER_TIMER_2_SET:

    ; Wenn Tür nicht zu ist und der Zu-Motor an ist, dann schaue ob Blockiert
    MOV C, CLOSED_2
    CPL C
    ANL C, CLOSE_2
    JC CHECK_FOR_BLOCKED_DOOR_2

CONTINUE_AFTER_CHECK_FOR_BLOCKED_DOOR_2:

    LJMP Anfang


;-------------------------------------------------
; Einzele Programmschnippsel
;-------------------------------------------------


START_TIMER_DOOR_1:
    SETB tr0; start timer0
    LJMP CONTINUE_AFTER_TIMER_1_SET


; sobald Tür 1 geöffnet ist, läuft ein Timer, der bei jedem Interupt hierher springt
TIMEOUT_TIMER_DOOR_1:    
    DJNZ r1, TMP; r1 dekrementieren und wegspringen, wenn ungleich 0 (Decrement Jump Not Zero)

    ; Hier gehts weiter, wenn der Timer oft genug abgelaufen ist (wenn die Tür lange genug offen war)
    ; -> Timer & Motor ausschalten und Stop-Anfragen resetten
    MOV r1, #5h ; r1 auf 5 zurücksetzen (im echten Leben bräuchten wir 39368 Wiederholungen)
    CLR tr0     ; stop timer0

    CLR STOP_1_FF   ; Resetten des Stop 1 FlipFlop
    CLR OPEN_1_FF   ; Resetten des Open 1 FlopFlop
    CLR OPEN_1      ; Motor nicht mehr auf öffnend setzen
    SETB CLOSE_1    ; Motor auf schließend setzen

    RET

TMP:
    RET

SET_STOP_1_FF:
    ; Setzen des "FlipFlops" und zurückspringen
    SETB STOP_1_FF
    LJMP CONTINUE_AFTER_STOP_1_FF_SET

SET_OPEN_1_FF:
    ; Setzen des "FlipFlops" (plus Motoroutput) und zurückspringen
    SETB OPEN_1_FF
    SETB OPEN_1
    CLR CLOSE_1
    LJMP CONTINUE_AFTER_OPEN_1_FF_SET

CHECK_FOR_BLOCKED_DOOR_1:
    ; Überprüfen, ob Tür 1 blockiert ist, und wenn ja wieder die Tür öffnen!
    MOV C, BlOCKED_1
    JC SET_OPEN_1_FF
    LJMP CONTINUE_AFTER_CHECK_FOR_BLOCKED_DOOR_1

;-----------------------------------------------

START_TIMER_DOOR_2:
    SETB tr1; start timer1
    ;MOV r2, #5h ; r2 auf 5 setzen; im echten Leben sollte das 39368
    
    LJMP CONTINUE_AFTER_TIMER_2_SET


; sobald Tür 2 geöffnet ist, läuft ein Timer, der bei jedem Interupt hierher springt
TIMEOUT_TIMER_DOOR_2:
    DJNZ r2, TMP

    ; Hier gehts weiter, wenn der Timer oft genug abgelaufen ist (wenn die Tür lange genug offen war)
    ; -> Timer & Motor ausschalten und Stop-Anfragen resetten
    MOV r2, #5h ; r2 auf 5 setzen (im echten Leben bräuchten wir 39368 Wiederholungen)
    CLR tr1     ; stop timer1

    CLR STOP_2_FF   ; Resetten des Stop 2 FlipFlop
    CLR OPEN_2_FF   ; Resetten des Open 2 FlopFlop
    CLR OPEN_2      ; Motor nicht mehr auf öffnend setzen
    SETB CLOSE_2    ; Motor auf schließend setzen

    RET

SET_STOP_2_FF:
    ; Setzen des "FlipFlops" und zurückspringen
    SETB STOP_2_FF
    LJMP CONTINUE_AFTER_STOP_2_FF_SET

SET_OPEN_2_FF:
    ; Setzen des "FlipFlops" (plus Motoroutput) und zurückspringen
    SETB OPEN_2_FF
    SETB OPEN_2
    CLR CLOSE_2
    LJMP CONTINUE_AFTER_OPEN_2_FF_SET

CHECK_FOR_BLOCKED_DOOR_2:
    ; Überprüfen, ob Tür 1 blockiert ist, und wenn ja wieder die Tür öffnen!
    MOV C, BlOCKED_2
    JC SET_OPEN_2_FF
    LJMP CONTINUE_AFTER_CHECK_FOR_BLOCKED_DOOR_2

END
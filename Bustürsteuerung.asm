;----------------------------------
; Bustürsteuerung-Steuerung
;----------------------------------
CSEG AT 0H
LJMP Init
ORG 100H; TODO: brauchen wir dashier wirklich??? Sagt, wo das Programm im Speicher abgelegt wird...

; Einsprung für den Timeout des Timers
ORG 0Bh
call TIMEOUT_TIMER_DOOR_1
reti


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

TAST EQU 20H
SENS EQU 21H

; Zeug das Menschen verändern können (Taster)
STOP_IN_1  EQU TAST.0
STOP_IN_2  EQU TAST.1
STOP_OUT_1 EQU TAST.2
STOP_OUT_2 EQU TAST.3
DRIVERS_OK EQU TAST.4

; Das was der Bus fühlt (Gefühle bzw. Sensoren)
OPENED_1   EQU SENS.0
OPENED_2   EQU SENS.1
CLOSED_1   EQU SENS.2
CLOSED_2   EQU SENS.3
BlOCKED_1  EQU SENS.4
BlOCKED_2  EQU SENS.5

; Ausgabevektor
; OPEN_1        Tür 1 soll geöffnet werden
; OPEN_2        Tür 2 soll geöffnet werden
; CLOSE_1       Tür 1 soll geschlossen werden
; CLOSE_2       Tür 2 soll geschlossen werden
MOTR EQU 22H
OPEN_1 EQU MOTR.0
OPEN_2 EQU MOTR.1
CLOSE_1 EQU MOTR.2
CLOSE_2 EQU MOTR.3


; INITIALISIERUNG
Init:
    MOV TAST, #00H
    MOV SENS, #00H ; oxC um die Closed Variablen zu setzen, wird duch P1 gesetzt
    ; MOV CLOSED_1, 1 ; Tür eins ist geschlossen
    ; MOV CLOSED_2, 1 ; Tür zwei ist geschlossen
    MOV MOTR, #00H

    MOV P0, #00H ; P0 wird verwendet um TAST von der IDE anzusprechen
    MOV P1, #0CH ; P1 wird verwendet um SENS in der IDE anzuzeigen
    MOV P2, #00H ; P2 wird verwendet um MOTR in der IDE anzuzeigen

    ; TIMER Kram
    MOV IE, #10010010b
    MOV tmod, #00000010b
    MOV tl0, #000h  ; Timer-Initionalsierung 
    MOV th0, #001h

    LJMP Anfang


;--------------------
; PROGRAMM-SCHLEIFE
;--------------------

Anfang:
    ; Eingaben aus Port 0 in TAST schreiben und SENS und MOTR in Port 1 und 2 (IDE-Anzeige) schreiben
    MOV TAST, P0
    MOV SENS, P1
    MOV P2, MOTR

    ; Abfrage ob ein Stop-Taster (innen oder außen) für Tür 1 gedrückt wurder
    MOV C, STOP_IN_1
    ORL C, STOP_OUT_1

    ; Wenn Stop-Taster 1 und Freigabe gesetzt, OPEN_1 (Motor 1) auf 1 setzen
    ANL C, DRIVERS_OK
    MOV OPEN_1, C

    ; Platz für die 2. Tür
    ; ...


    ; Schauen ob die Tür 1 geöffnet ist (Endtaster gesetzt) und wenn ja den Motor beenden
    MOV C, OPEN_1
    ANL C, OPENED_1
    JC START_TIMER_DOOR_1
CONTINUE:
    CPL C
    ANL C, OPEN_1
    MOV OPEN_1, C


    ; ...

    LJMP Anfang

START_TIMER_DOOR_1:
    setb tr0; start timer0
    LJMP CONTINUE

TIMEOUT_TIMER_DOOR_1:
    inc	r1
	cjne	r1, #5h, TMP ; Schleife der Wiederholungen des Timers (wir brauchen 39368 Wiederholungen)
	mov	r1, #00h

    ; ...
	MOV STOP_IN_1, 0
    CLR P0.0
    MOV STOP_OUT_1, 0
    CLR P0.2
    MOV CLOSE_1, 1
    ; ...

	ret

TMP:
    ret

END

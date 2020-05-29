;----------------------------------
; Bustürsteuerung-Steuerung
;----------------------------------
CSEG AT 0H
; ORG 100H; TODO: brauchen wir dashier wirklich??? Sagt, wo das Programm im Speicher abgelegt wird...
LJMP Init


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
OPENED_1   EQU SENS.1
OPENED_2   EQU SENS.2
CLOSED_1   EQU SENS.3
CLOSED_2   EQU SENS.4
BlOCKED_1  EQU SENS.5
BlOCKED_2  EQU SENS.6

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
    MOV SENS, #00H
    MOV MOTR, #00H

    MOV P0, #00H ; P0 wird verwendet um TAST von der IDE anzusprechen
    MOV P1, #00H ; P1 wird verwendet um SENS in der IDE anzuzeigen
    MOV P2, #00H ; P2 wird verwendet um MOTR in der IDE anzuzeigen

    LJMP Anfang


;--------------------
; PROGRAMM-SCHLEIFE
;--------------------
Anfang:
    ; Eingaben aus Port 0 in TAST schreiben und SENS und MOTR in Port 1 und 2 schreiben
    MOV TAST, P0
    MOV P1, SENS
    MOV P2, MOTR
    
    ;-------------------------------------------------------------------------- Ende von unserem

    MOV C, START1
    ORL C, START2
    ANL C, G_AUF
    ORL C, /G_KONT
    JNC S1
    SETB M_AUF

S1: 
    MOV C,M_ZU
    ORL C, /STOP1
    ORL C, /STOP2
    ORL C, /G_AUF
    JNC S2
    CLR M_AUF

S2:
    MOV C, START1
    ORL C, START2
    ANL C, /G_AUF
    JNC S3
    SETB M_ZU 

S3:
    MOV C, M_AUF
    ORL C, /STOP1
    ORL C, /STOP2
    ORL C, /G_ZU
    ORL C, /G_KONT
    JNC S4
    CLR M_ZU 

S4:
    MOV C, M_ZU
    Mov HUPE, C
    ;-------------------
    ; Ausgabe
    ;-------------------
    MOV P3, AUS3
    ; SCHLEIFENENDE
    LJMP Anfang
    ;----------------
END

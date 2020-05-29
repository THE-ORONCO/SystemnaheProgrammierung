;----------------------------------
; Bustürsteuerung-Steuerung
;----------------------------------
CSEG AT 0H
LJMP Anfang
ORG 100H

; Eingabevektoren TAST und SENS
; Taster:
; STOP_IN_1     Taster, zum Öffnen der Tür1 von innnen (Stop-Taster)
; STOP_IN_2     Taster, zum Öffnen der Tür2 von innnen (Stop-Taster)
; STOP_OUT_1    Taster, zum Öffnen der Tür1 von außen
; STOP_OUT_2    Taster, zum Öffnen der Tür1 von außen
; DRIVERS_OK    Freigabe-Taster des Busfahrers
;
; Sensoren:
; OPENED_1      Ausgabe des Geöffnet-Sensors der Tür1
; OPENED_2      Ausgabe des Geöffnet-Sensors der Tür2
; CLOSED_1      Ausgabe des Geschlossen-Sensors der Tür1
; CLOSED_2      Ausgabe des Geschlossen-Sensors der Tür2
; BLOCKED_1     Jemand steht in der schließenden Tür1
; BLOCKED_2     Jemand steht in der schließenden Tür2

TAST EQU 20H
SENS EQU 21H

STOP_IN_1 EQU TAST.0
STOP_IN_2 EQU TAST.1
STOP_OUT_1 EQU TAST.2
STOP_OUT_2 EQU TAST.3
DRIVERS_OK EQU TAST.4

OPENED_1 EQU SENS.1
OPENED_2 EQU SENS.2
CLOSED_1 EQU SENS.3
CLOSED_2 EQU SENS.4
BlOCKED_1 EQU SENS.5
BlOCKED_2 EQU SENS.6

; Ausgabevektor
; OPEN_1        Tür 1 soll geöffnet werden
; OPEN_2        Tür 2 soll geöffnet werden
; CLOSE_1       Tür 1 soll geschlossen werden
; CLOSE_2       Tür 2 soll geschlossen werden
;
;
;
;
AUS3 EQU 22H
M_AUF EQU AUS3.0
M_ZU EQU AUS3.1
HUPE EQU AUS3.7
; Merker
M1 EQU 22H
; INITIALISIERUNG
MOV EIN1, #00H
MOV AUS3, #00H
MOV P1, #0FFH
;--------------------
; SCHLEIFE
;--------------------
Anfang:
MOV EIN1, P1
;--------------------
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

;----------------------------------
; Bustürsteuerung-Steuerung
;----------------------------------
CSEG AT 0H
LJMP Anfang
ORG 100H

; Eingabevektor
EIN1 EQU 20H
START1 EQU EIN1.0
START2 EQU EIN1.1
STOP1 EQU EIN1.2
STOP2 EQU EIN1.3
G_AUF EQU EIN1.5
G_ZU EQU EIN1.6
G_KONT EQU EIN1.7
; Ausgabevektor
AUS3 EQU 21H
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

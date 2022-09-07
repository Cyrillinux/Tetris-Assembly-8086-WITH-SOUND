; Sound Server STOP
;== Ici commence le programme v‚ritable ================================

code      segment para 'CODE'             ;D‚finition du segment de CODE

	org 100h

	assume cs:code, ds:code, es:code, ss:code

start:    jmp PROGRAMMini              ;La premiŠre instruction ex‚cut‚e

;== Donn‚es (restent en m‚moire) =======================================

ancint    equ this dword              ;Ancien vecteur d'interruption 1Ch
ofsancint dw (?)            ;Adresse d'offset vecteur d'interruption 1Ch
segancint dw (?)               ;Adresse de segment vecteur d'interr. 1Ch


;== Voici la nouvelle interruption (reste en m‚moire) ==================

newint    proc far

	jmp  short newintbs

	db "SD"                           ;Identification du programme

newintbs: pushf

	jmp  cs:[ancint]               ;Vers l'ancienne routine de 1Ch

newint    endp

;== Sous-programmes ====================================================
; ------
; - matisuara proc
; --
;agar suaranya mati
  
  matisuara proc
      in al,61h
      and al, 11111100b       ; menutup soundcard (invers dari akses soundcard)
      out 61h, al
      ret
  matisuara endp

instend   equ this byte                ;Jusqu'… cette cellule de m‚moire
				      ;tout doit rester r‚sident

;== Donn‚es (peuvent ˆtre effac‚es par le DOS) =========================

elimine   db 13,10,"Sound Server disabled.",13,10,"$"

;== Programme (peut ˆtre effac‚ par le DOS) ============================
;-- Routine de lancement et initialisation -----------------------------

PROGRAMMini   label near

    call matisuara
    
	mov  ax,351Ch         ;Lire contenu vecteur d'interruption 1Ch
	int  21h                                 ;Appeler fonction DOS
	cmp  word ptr es:[bx+2],"DS"     ;Tester si programme PROGRAMM
	jne  quit             ;Pas de PROGRAMM install‚ --> INSTALL

;-- PROGRAMM est d‚sactiv‚ ---------------------------------------------

	mov  dx,es:ofsancint   ;Adresse d'offset de l'interruption 1Ch
	mov  ax,es:segancint ;Adresse de segment de l'interruption 1Ch
	mov  ds,ax                                            ;dans DS
	mov  ax,251Ch     ;Replacer contenu vecteur d'interruption 1Ch
	int  21h                                 ;sur ancienne routine

	mov  bx,es             ;Ranger adresse de segment du programme
	mov  es,es:[2Ch]  ;Retirer du PSP adr. seg. de l'environnement
	mov  ah,49h                         ;Lib‚rer … nouveau m‚moire
	int  21h                                 ;d'ancien environnent

	mov  es,bx                       ;Lib‚rer … nouveau la m‚moire
	mov  ah,49h                              ;de l'ancien PROGRAMM
	int  21h                     ;… travers la fonction 49h du DOS

	push cs                                 ;Sauver CS sur la pile
	pop  ds                                       ;Ramener dans DS

	mov  dx,offset elimine            ;Message : programme ‚limin‚
	mov  ah,9               ;Num‚ro de fonction pour Ecrire chaŒne
	int  21h                                 ;Appeler fonction DOS

	mov  ax,4C00h                 ;Terminer programme correctement
	int  21h                ;Appeler fonction pour terminer progr.

;-- Installation de PROGRAMM -------------------------------------------

quit   label near

    call matisuara
    
    mov  ax,4C00h                 ;Terminer programme correctement
    int  21h                ;Appeler fonction pour terminer progr.

;== Fin ================================================================

code      ends                                   ;Fin du segment de CODE
	end  start

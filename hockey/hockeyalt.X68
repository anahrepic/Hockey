PROGRAM	EQU	$1000
DATA	EQU	$2000

	ORG	DATA
; pamtimo pozicije svega
GOLMANL	DS.W	2
NAPADL	DS.W	2
GOLMAND	DS.W	2
NAPADD	DS.W	2
LOPTICA	DS.W	2
SMJER	DS.B	2
BRZINA	DS.W	1
BOJA	DS.L	1
N	DS.W	1
POBJEDA	DS.W	1	
; pamtimo score
SCOREL	DC.B	'L: 0', 0
SCORED	DC.B	'D: 0', 0
; poruke za pocetak igre
POZ	DC.B	'Dobrodosli u igru Hockey!', 0  
UPUTE1	DC.B	'Svaki igrac ima po dvije ploce.', 0 
UPUTE2	DC.B	'Lijevi igrac pokrece svoje ploce tipkama Q, A, W i S', 0 ; 52 znaka, najvise
UPUTE3	DC.B	'a desni igrac brojevima 8, 5, 9 i 6 na numpadu.', 0
KRENI	DC.B	'Za pocetak igre pritisnite tipku razmaka (spacebar).', 0
BRISI	DC.B	'                                                     ', 0 ; za brisanje
POBJEDNIKL DC.B	'Pobjednik je lijevi igrac!', 0
POBJEDNIKD DC.B	'Pobjednik je desni igrac!', 0
PONOVNO	DC.B	'Ukoliko zelite igrati ponovno, pritisnite spacebar!', 0

	ORG	PROGRAM
START:	JSR	CISTIZASLON
	JSR	POCETNIZASLON
	JSR	POZADINA
	JSR	CRTAJCENTAR
	; postavljanje pocetne brzine LOPTICE = 2 milisekunde (prije sljedeceg pomaka)
	MOVE.W	#3, BRZINA
	; postavljanje boje loptice 
	MOVE.L	#$00FFFFFF, BOJA
	; nakon 5 pomaka boja se vraca u normalu
	MOVE.W	#0, N
	
	; stavi nulu u D7
	MOVE.W	#0, D7
	
	; iskljuci keyboard echo
	MOVE.B	#0, D1
	MOVE.B	#12, D0
	TRAP	#15
		
	; postavljanje pocetnih pozicija
	MOVEA.L	#GOLMANL, A0
	
	; lijevi golman
	MOVE.W	#95, (A0)+
	MOVE.W	#126, (A0)+
	; lijevi napadac
	MOVE.W	#199, (A0)+
	MOVE.W	#230, (A0)+
	; desni golman
	MOVE.W	#543, (A0)+
	MOVE.W	#230, (A0)+
	; desni napadac
	MOVE.W	#439, (A0)+
	MOVE.W	#154, (A0)+
	; loptica 
	MOVE.W	#320, (A0)+
	MOVE.W	#240, (A0)
	
	; crtanje elemenata igre + odredivanje slucajnog smjera loptice
	MOVEA.L	#GOLMANL, A0
	JSR	CRTAJJEDNUPLOCU
	MOVEA.L	#NAPADL, A0
	JSR	CRTAJJEDNUPLOCU
	MOVEA.L	#NAPADD, A0
	JSR	CRTAJJEDNUPLOCU
	MOVEA.L	#GOLMAND, A0
	JSR	CRTAJJEDNUPLOCU
	JSR	CRTAJLOPTICU
	JSR	STAVISMJERLOPTICE
		
	; vrijeme pomaka spremamo u D5 za usporedbu s trenutnim vremenom
	MOVE.B	#8, D0
	TRAP	#15
	MOVE.L	D1, D5
	
	
INFPETLJA:
	; provjerimo je li proslo BRZINA stotinki od vremena proslog pomaka (ono pise u D5)
	MOVE.B	#8, D0
	TRAP	#15
	SUB.L	D5, D1
	CMP.W	BRZINA, D1
	BLS	INFPETLJA	; D1 <= brzina -> nije proslo dovoljno vremena
	;ako je proslo dovoljno vremena, onda ga moramo spremiti za buducu usporedbu!
	MOVE.B	#8, D0
	TRAP	#15
	MOVE.L	D1, D5
	
	JSR	SCOREISPIS
	JSR	BRISILOPTICU
	JSR	POMAKNILOPTICU
	JSR	CRTAJLOPTICU
	
DALJE:	CLR.B	D1
	; inace, spremimo se za sljedecu iteraciju petlje + updateamo lopticu
	; provjera je li pritisnuta NEKA tipka
	MOVE.B	#7, D0
	TRAP	#15
	TST.B	D1
	; ako je tipka pritisnuta, obradimo
	BEQ	INFPETLJA
	JSR	OBRADIULAZ
	
	BRA	INFPETLJA

KRAJ:	MOVE.B	#9,D0
	TRAP	#15
	
*-----------------------------------------------------------------------------------------*
; pomicanje blokova izvodimo pritiskom tipki na tipkovnici
; mozemo koristiti numpad:
; LIJEVI IGRAC: Q (GORE), A (DOLJE) za golmana, W (GORE), S (DOLJE) za napadaca
; DESNI IGRAC: 9 (GORE), 6 (DOLJE) za golmana, 8 (GORE) , 5 (DOLJE) za napadaca

; ako stisnemo Q, W, 8 ili 9 (NA NUMPADU), to je -1 po y (Y RASTE PREMA DOLJE)
; ako stisnemo A, S, 4 ILI 6 (NA NUMPADU), to je +1 po y 
*-----------------------------------------------------------------------------------------*
; podrutina za crtanje pozadine
POZADINA:
	; olovka za ispunu, charcoal boje #36454F
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15
	
	; ispuna
	MOVE.W	#15, D1
	MOVE.W	#15, D2
	MOVE.B	#89, D0
	TRAP	#15
	JSR	CRTAJOBRUB
	RTS
	
CRTAJOBRUB:

	; boja olovke za obrub - BIJELA
	MOVE.L 	#$00FFFFFF, D1
	MOVE.B	#80, D0
	TRAP	#15
	
	;boja filla
	MOVE.L 	#$00FFFFFF, D1
	MOVE.B	#81, D0
	TRAP	#15

	; debljina olovke za obrub 10px
	MOVE.B 	#10, D1
	MOVE.B	#93, D0
	TRAP	#15
			
	; crtanje 6 pravokutnika koji predstavljaju obrub
	MOVE.W	#0, D1
	MOVE.W	#0, D2
	MOVE.W	#10, D3
	MOVE.W	#120, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	MOVE.W	#0, D1
	MOVE.W	#360, D2
	MOVE.W	#10, D3
	MOVE.W	#480, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	MOVE.W	#630, D1
	MOVE.W	#0, D2
	MOVE.W	#640, D3
	MOVE.W	#120, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	MOVE.W	#630, D1
	MOVE.W	#360, D2
	MOVE.W	#640, D3
	MOVE.W	#480, D4
	MOVE.B	#87, D0
	TRAP	#15

	MOVE.W	#0, D1
	MOVE.W	#0, D2
	MOVE.W	#640, D3
	MOVE.W	#10, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	MOVE.W	#0, D1
	MOVE.W	#470, D2
	MOVE.W	#640, D3
	MOVE.W	#480, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	RTS
	
CRTAJCENTAR:	
	; boja olovke za obrub - BIJELA
	MOVE.L 	#$00FFFFFF, D1
	MOVE.B	#80, D0
	TRAP	#15
	
	;boja filla
	MOVE.L 	#$00FFFFFF, D1
	MOVE.B	#81, D0
	TRAP	#15

	; debljina olovke za obrub 10px
	MOVE.B 	#10, D1
	MOVE.B	#93, D0
	TRAP	#15

	; crtanje isprekidane linije na centru
	MOVE.W 	#317, D1
	MOVE.W	#0, D2
	MOVE.W	#323, D3
	MOVE.W	#16, D4
	MOVE.W	#15, D6 ; brojac

LINIJA:	MOVE.B	#87, D0
	TRAP	#15
	ADD.W	#32, D2
	ADD.W	#32, D4
	SUBQ	#1, D6
	BNE	LINIJA
	
	RTS
		
*-----------------------------------------------------------------------------------------*
; podrutina za crtanje TOCNO JEDNE PLOCE, adresa pozicije poslana je preko A0
CRTAJJEDNUPLOCU:
	; boja olovke za ploce - BIJELA
	MOVE.L 	#$00FFFFFF, D1
	MOVE.B	#80, D0
	TRAP	#15
	
	;boja filla
	MOVE.L 	#$00FFFFFF, D1
	MOVE.B	#81, D0
	TRAP	#15

	; debljina olovke za ploce 10px
	MOVE.B 	#10, D1
	MOVE.B	#93, D0
	TRAP	#15
	
	; crtanje
	MOVE.W	(A0)+, D1
	MOVE.W	(A0)+, D2
	MOVE.W	D1, D3
	ADD.W	#8, D3
	MOVE.W	D2, D4
	ADD.W	#60, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	RTS
	
*------------------------------------------------------------------------------------------*
; podrutine za brisanje "traga" koji ostaje za plocama kad se pomicu
; dvije su, ovisno o tome ide li pomak prema gore ili prema dolje
; adresa STARIH koordinata stize preko A0

POMAKDOLJECISTI:
	; boja olovke - CHARCOAL
	MOVE.L 	#$004F4536, D1
	MOVE.B	#80, D0
	TRAP	#15
	
	;boja filla
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15

	; debljina olovke, ista kao i za ploce, 10px
	MOVE.B 	#10, D1
	MOVE.B	#93, D0
	TRAP	#15
	
	MOVE.W	(A0)+, D1
	MOVE.W	(A0), D2
	MOVE.W	D1, D3
	ADD.W	#8, D3
	MOVE.W	D2, D4
	ADDQ	#5, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	RTS
	
POMAKGORECISTI:
	; boja olovke - CHARCOAL
	MOVE.L 	#$004F4536, D1
	MOVE.B	#80, D0
	TRAP	#15
	
	;boja filla
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15

	; debljina olovke, ista kao i za ploce, 10px
	MOVE.B 	#10, D1
	MOVE.B	#93, D0
	TRAP	#15
	
	MOVE.W	(A0)+, D1
	MOVE.W	(A0), D2
	MOVE.W	D1, D3
	ADD.W	#8, D3
	
	MOVE.W	D2, D4
	ADD.W	#60, D4
	ADD.W	#55, D2
	MOVE.B	#87, D0
	TRAP	#15
	
	RTS

*-----------------------------------------------------------------------------------------*
; podrutina za brisanje loptice prije crtanja nove loptice
BRISILOPTICU:
	; boja olovke - CHARCOAL
	MOVE.L 	#$004F4536, D1
	MOVE.B	#80, D0
	TRAP	#15
	
	;boja filla
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15

	; debljina olovke, ista kao i za lopticu, 5px
	MOVE.B 	#5, D1
	MOVE.B	#93, D0
	TRAP	#15
	
	MOVEA.L	#LOPTICA, A0
	MOVE.W	(A0)+, D1
	MOVE.W	(A0), D2
	MOVE.W	D1, D3
	ADD.W	#7, D3
	
	MOVE.W	D2, D4
	ADD.W	#5, D4
	MOVE.B	#87, D0
	TRAP	#15
	
	; treba li opet crtati centar?
	MOVEA.L	#LOPTICA, A0
	CMPI	#300, (A0)
	BCS	KRAJBRISANJA
	CMPI	#330, (A0)
	BHI	KRAJBRISANJA
	JSR	CRTAJCENTAR

KRAJBRISANJA:	
	RTS

*-----------------------------------------------------------------------------------------*
; podrutina za crtanje loptice

CRTAJLOPTICU:
	ADD.W	#1, N
	CMP.W	#20, N
	BNE	BEZPROMJENE
	MOVE.L	#$00FFFFFF, BOJA
	MOVE.W	#0, N
BEZPROMJENE:
	; boja olovke za lopticu
	MOVE.L 	BOJA, D1
	MOVE.B	#80, D0
	TRAP	#15
	
	;boja filla
	MOVE.L 	BOJA, D1
	MOVE.B	#81, D0
	TRAP	#15
	
	; debljina olovke za lopticu 5px
	MOVE.B 	#5, D1
	MOVE.B	#93, D0
	TRAP	#15
	
	; crtanje loptice (5x7 px)
	MOVEA.L	#LOPTICA, A0
	MOVE.W	(A0)+, D1
	MOVE.W	(A0), D2
	MOVE.W	D1, D3
	ADDQ	#7, D3
	MOVE.W	D2, D4
	ADDQ	#5, D4
	MOVE.W	#87, D0
	TRAP	#15

	RTS

*---------------------------------------------------------------------------------------*
; podrutina za postavljanje smjera loptice
STAVISMJERLOPTICE:
	; slucajan smjer kretanja
	MOVEA.L	#SMJER, A0
	MOVE.B	#8, D0
	TRAP	#15
	
	
	AND.L	#$FFFF, D1
	DIVU	#2, D1

	SWAP	D1
	;0 u donjem bajtu -> x negativan
	;1 u donjem bajtu -> x pozitivan
	CMP.B	#0, D1
	BEQ	NULAX
	MOVE.B	#1, (A0)+
	BRA	DRUGA	
	
NULAX:	MOVE.B	#-1, (A0)+
	
	; sad isto za y
DRUGA:	MOVE.B	#8, D0
	TRAP	#15
	AND.L	#$FFFF, D1
	DIVU	#2, D1
	SWAP	D1
	CMP.B	#0, D1
	BEQ	NULAY
	MOVE.B	#1, (A0)
	RTS
	
NULAY:	MOVE.B	#-1, (A0)
	
	RTS
	
*------------------------------------------------------------------------------------------*
; podrutina za promjenu pozicije loptice (uzimamo u obzir i moguce sudare)
POMAKNILOPTICU:
; provjeravamo je li doslo do gola
GOLPRVAPROVJERA:
	MOVEA.L	#LOPTICA+2, A0
	CMPI	#360, (A0)
	BHI	PROVJERASUDARA	; sigurno nema gola
	CMPI	#120, (A0)
	BCS	PROVJERASUDARA	; sigurno nema gola
	
LIJEVIGOLPROVJERA:
	MOVEA.L	#LOPTICA, A0
	CMPI	#20, (A0)
	BHI	DESNIGOLPROVJERA	
	; gol!
	BRA	OBRADIGOLLIJEVI	

DESNIGOLPROVJERA:
	MOVEA.L	#LOPTICA, A0
	CMPI	#600, (A0)
	BCS	PROVJERASUDARA		
	; gol!
	BRA	OBRADIGOLDESNI	


; provjeravamo sudare s plocama
PROVJERASUDARA:
	TST.B	D7
	; ako je 0, mozes raditi provjere
	BNE	POMAKNILOPTICUX
; prvo, lijevi golman
LGOLMANX:
	MOVEA.L	#LOPTICA, A0
	MOVEA.L	#GOLMANL, A1	
	MOVE.W	(A1), D6
	SUB.W	#$15,	D6
	CMP.W	(A0), D6		; ako ne nademo nista sumnjivo, idemo na iducu provjeru
	BHI	LNAPADX
	ADD.W	#37, D6
	CMP.W	(A0), D6
	BCS	LNAPADX
LGOLMANY:
	MOVEA.L	#LOPTICA+2, A0
	MOVEA.L	#GOLMANL+2, A1
	MOVE.W	(A1), D6
	SUB.W	#$10, D6
	CMP.W	(A0), D6
	BHI	LNAPADX
	ADD.W	#$65, D6
	CMP.W	(A0), D6
	BCC	PROMJENAOBASMJERA
	
LNAPADX:
	MOVEA.L	#LOPTICA, A0
	MOVEA.L	#NAPADL, A1	
	MOVE.W	(A1), D6
	SUB.W	#$15,	D6
	CMP.W	(A0), D6		; ako ne nademo nista sumnjivo, idemo na iducu provjeru
	BHI	DNAPADX
	ADD.W	#37, D6
	CMP.W	(A0), D6
	BCS	DNAPADX

	
LNAPADY:
	MOVEA.L	#LOPTICA+2, A0
	MOVEA.L	#NAPADL+2, A1
	MOVE.W	(A1), D6
	SUB.W	#$10, D6
	CMP.W	(A0), D6
	BHI	DNAPADX
	ADD.W	#$65, D6
	CMP.W	(A0), D6
	BCC	PROMJENAOBASMJERA
	

DNAPADX:
	MOVEA.L	#LOPTICA, A0
	MOVEA.L	#NAPADD, A1	
	MOVE.W	(A1), D6
	SUB.W	#$15,	D6
	CMP.W	(A0), D6		; ako ne nademo nista sumnjivo, idemo na iducu provjeru
	BHI	DGOLMANX
	ADD.W	#40, D6
	CMP.W	(A0), D6
	BCS	DGOLMANX

DNAPADY:
	MOVEA.L	#LOPTICA+2, A0
	MOVEA.L	#NAPADD+2, A1
	MOVE.W	(A1), D6
	SUB.W	#$10, D6
	CMP.W	(A0), D6
	BHI	DGOLMANX
	ADD.W	#$65, D6
	CMP.W	(A0), D6
	BCC	PROMJENAOBASMJERA

DGOLMANX:
	MOVEA.L	#LOPTICA, A0
	MOVEA.L	#GOLMAND, A1	
	MOVE.W	(A1), D6
	SUB.W	#$15,	D6
	CMP.W	(A0), D6		; ako ne nademo nista sumnjivo, idemo na iducu provjeru
	BHI	POMAKNILOPTICUX
	ADD.W	#40, D6
	CMP.W	(A0), D6
	BCS	POMAKNILOPTICUX

DGOLMANY:
	MOVEA.L	#LOPTICA+2, A0
	MOVEA.L	#GOLMAND+2, A1
	MOVE.W	(A1), D6
	SUB.W	#$10, D6
	CMP.W	(A0), D6
	BHI	POMAKNILOPTICUX
	ADD.W	#$65, D6
	CMP.W	(A0), D6
	BCC	PROMJENAOBASMJERA
	

POMAKNILOPTICUX:
	TST.B	D7
	BEQ	NEODUZIMAJ
	SUBI.B	#1, D7	
NEODUZIMAJ:
	MOVEA.L	#SMJER, A0
	MOVE.B	(A0), D6
	BMI	NEGX
	
POZX:	MOVEA.L	#LOPTICA, A0
	; provjera smije li ici tu
	CMP.W	#610, (A0)
	; ako ne, mijenjamo x
	BCC	PROMJENAX		
	BRA	DOZVOLJENPOMAKPOZX


NEGX:	MOVEA.L	#LOPTICA, A0
	; provjera smije li ici tu
	CMP.W	#20, (A0)
	BLS	PROMJENAX		
	; ako da, prijedimo na provjere sudara s plocama
	BRA	DOZVOLJENPOMAKNEGX
	

POMAKNILOPTICUY:
	MOVEA.L	#SMJER+1, A0	; neparna adresa, pazi!
	MOVE.B	(A0), D6
	BMI	NEGY
	
POZY:	MOVEA.L	#LOPTICA+2, A0
	; provjera smije li ici tu
	CMP.W	#455, (A0)
	BCC	PROMJENAY
	BRA	DOZVOLJENPOMAKPOZY
			
NEGY:	MOVEA.L	#LOPTICA+2, A0
	; provjera smije li ici tu
	CMP.W	#20, (A0)
	BLS	PROMJENAY
	; ako da, pomaknemo se
	BRA DOZVOLJENPOMAKNEGY
		
PROMJENAX:
	MOVEA.L	#SMJER, A0
	NEG.B	(A0)
	BRA	POMAKNILOPTICUY
	
PROMJENAY:
	MOVEA.L	#SMJER+1, A0
	NEG.B	(A0)
	RTS
	
PROMJENAOBASMJERA:
	BEQ	POMAKNILOPTICUX
	MOVEA.L	#SMJER, A0
	NEG.B	(A0)
	MOVEA.L	#SMJER+1, A0
	NEG.B	(A0)
	MOVE.B	#10, D7
	MOVE.L	#$00A0E7E8, BOJA
	RTS
			
DOZVOLJENPOMAKPOZX:
	MOVEA.L	#LOPTICA, A0
	ADDQ	#$3, (A0)
	BRA	POMAKNILOPTICUY
	
DOZVOLJENPOMAKNEGX:
	MOVEA.L	#LOPTICA, A0
	SUBQ	#$3, (A0)
	BRA	POMAKNILOPTICUY
	
DOZVOLJENPOMAKPOZY:
	MOVEA.L	#LOPTICA+2, A0
	ADDQ	#$3, (A0)
	RTS
	
DOZVOLJENPOMAKNEGY:
	MOVEA.L	#LOPTICA+2, A0
	SUBQ	#$3,(A0)
	RTS

*-----------------------------------------------------------------------------------------*
;podrutina za obradu pritiska tipke - pomice odgovarajucu plocu i ponovno ucrtava ploce
OBRADIULAZ:
	MOVE.B	#5, D0
	TRAP	#15
		
	; u D1.B je ASCII kod pritisnute tipke
	; ASCII kodovi koji nam trebaju:
	; Q = $51	9 = $39
	; W = $57	6 = $36
	; A = $41	8 = $38
	; S = $53	5 = $35
	
	;za slova su dvije provjere jer malo i veliko slovo imaju drukciji ASCII kod
	CMP.B	#$51, D1
	BEQ	LGOLMANGORE
	CMP.B	#$71, D1
	BEQ	LGOLMANGORE
	 
	CMP.B	#$41, D1
	BEQ	LGOLMANDOLJE
	CMP.B	#$61, D1
	BEQ	LGOLMANDOLJE
	
	CMP.B	#$57, D1
	BEQ	LNAPADACGORE
	CMP.B	#$77, D1
	BEQ	LNAPADACGORE
	
	CMP.B	#$53, D1
	BEQ	LNAPADACDOLJE
	CMP.B	#$73, D1
	BEQ	LNAPADACDOLJE

	CMP.B	#$39, D1
	BEQ	DGOLMANGORE
	CMP.B	#$36, D1
	BEQ	DGOLMANDOLJE
	CMP.B	#$38, D1
	BEQ	DNAPADACGORE
	CMP.B	#$35, D1
	BEQ	DNAPADACDOLJE
	
	; ako smo dosli do ovdje, pritisnuta je *neka* tipka, ali ne ona koja nas zanima
	; dakle, izlazimo iz podrutine
	RTS
	
	;a ako je pritisnuta neka tipka od interesa, odradimo odgovarajuci pomak (3px)
	
LGOLMANGORE:
	MOVEA.L	#GOLMANL, A0
	CMPI	#26, 2(A0)
	BLS	NEMAPOMAKA
	MOVEA.L	#GOLMANL, A0
	JSR	POMAKGORECISTI
	MOVEA.L	#GOLMANL, A0
	SUB.W	#2, 2(A0)
	MOVEA.L	#GOLMANL, A0
	JSR	CRTAJJEDNUPLOCU	
	RTS
	
LGOLMANDOLJE:
	MOVEA.L	#GOLMANL, A0
	CMPI	#395, 2(A0)
	BCC	NEMAPOMAKA
	MOVEA.L	#GOLMANL, A0
	JSR	POMAKDOLJECISTI
	MOVEA.L	#GOLMANL, A0
	ADD.W	#2, 2(A0)
	MOVEA.L	#GOLMANL, A0
	JSR	CRTAJJEDNUPLOCU
	RTS
	
LNAPADACGORE:
	MOVEA.L	#NAPADL, A0
	CMPI	#25, 2(A0)
	BLS	NEMAPOMAKA
	MOVEA.L	#NAPADL, A0
	JSR	POMAKGORECISTI
	MOVEA.L	#NAPADL, A0
	SUB.W	#2, 2(A0)
	MOVEA.L	#NAPADL, A0
	JSR	CRTAJJEDNUPLOCU
	RTS
	
LNAPADACDOLJE:
	MOVEA.L	#NAPADL, A0
	CMPI	#395, 2(A0)
	BCC	NEMAPOMAKA
	MOVEA.L	#NAPADL, A0
	JSR	POMAKDOLJECISTI
	MOVEA.L	#NAPADL, A0
	ADD.W	#2, 2(A0) 
	MOVEA.L	#NAPADL, A0
	JSR	CRTAJJEDNUPLOCU
	RTS	
	
DGOLMANGORE:
	MOVEA.L	#GOLMAND, A0
	CMPI	#25, 2(A0)
	BLS	NEMAPOMAKA
	MOVEA.L	#GOLMAND, A0
	JSR	POMAKGORECISTI
	MOVEA.L	#GOLMAND, A0
	SUB.W	#2, 2(A0)
	MOVEA.L	#GOLMAND, A0
	JSR	CRTAJJEDNUPLOCU
	RTS

DGOLMANDOLJE:
	MOVEA.L	#GOLMAND, A0
	CMPI	#395, 2(A0)
	BCC	NEMAPOMAKA
	MOVEA.L	#GOLMAND, A0
	JSR 	POMAKDOLJECISTI
	MOVEA.L	#GOLMAND, A0
	ADD.W	#2, 2(A0) 
	MOVEA.L	#GOLMAND, A0
	JSR	CRTAJJEDNUPLOCU
	RTS
	
DNAPADACGORE:
	MOVEA.L	#NAPADD, A0
	CMPI	#25, 2(A0)
	BLS	NEMAPOMAKA
	MOVEA.L	#NAPADD, A0
	JSR	POMAKGORECISTI
	MOVEA.L	#NAPADD, A0
	SUB.W	#2, 2(A0)
	MOVEA.L	#NAPADD, A0
	JSR	CRTAJJEDNUPLOCU
	RTS
	
DNAPADACDOLJE:
	MOVEA.L	#NAPADD, A0
	CMPI	#395, 2(A0)
	BCC	NEMAPOMAKA
	MOVEA.L	#NAPADD, A0
	JSR	POMAKDOLJECISTI
	MOVEA.L	#NAPADD, A0
	ADD.W	#2, 2(A0) 
	MOVEA.L	#NAPADD, A0
	JSR	CRTAJJEDNUPLOCU
	RTS
	
NEMAPOMAKA:
	RTS
	
*---------------------------------------------------------------------------------------------------*			
; podrutina za pocetni zaslon
POCETNIZASLON:	
	; namjestanje cursora
	; 10 -> 0A u hex
	; 25 -> 19 u hex
	CLR.W	D1
	MOVE.W	#$190A, D1
	MOVE.B	#11, D0
	TRAP	#15
	
	; ispis teksta
	MOVE.B	#14, D0
	LEA	POZ, A1
	TRAP	#15
	
	;i sad ponovno
	CLR.W	D1
	MOVE.W	#$170C, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	UPUTE1, A1
	TRAP	#15
	
	CLR.W	D1
	MOVE.W	#$0E0D, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	UPUTE2, A1
	TRAP	#15
	
	CLR.W	D1
	MOVE.W	#$0E0E, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	UPUTE3, A1
	TRAP	#15

	CLR.W	D1
	MOVE.W	#$0E10, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	KRENI, A1
	TRAP	#15

	JSR	POZADINA
	JSR	SPACELOOP
		
	; ako je tipka pritisnuta, moramo izbrisati tekst
	; prvo moramo postaviti boju na CHARCOAL - #36454F
	MOVE.L 	#$004F4536, D1
	MOVE.B	#21, D0
	TRAP	#15
	
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15

	
	CLR.W	D1
	MOVE.W	#$190A, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	BRISI, A1
	TRAP	#15
	
	CLR.W	D1
	MOVE.W	#$170C, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	BRISI, A1
	TRAP	#15
	
	CLR.W	D1
	MOVE.W	#$0E0D, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	BRISI, A1
	TRAP	#15
	
	CLR.W	D1
	MOVE.W	#$0E0E, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	BRISI, A1
	TRAP	#15

	CLR.W	D1
	MOVE.W	#$0E10, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	BRISI, A1
	TRAP	#15


	RTS
	
*-----------------------------------------------------------------------------------------*
; za cekanje dok se ne pritisne spacebar
SPACELOOP:	
	CLR.B	D1
	; provjera je li pritisnuta NEKA tipka
	MOVE.B	#7, D0
	TRAP	#15
	TST.B	D1
	; ako je tipka pritisnuta, obradimo
	MOVE.B	#5, D0
	TRAP	#15
	CMP.B	#32, D1
	BNE	SPACELOOP
	RTS
	
*-----------------------------------------------------------------------------------------*
; ispis scorea
SCOREISPIS:
	; olovka za ispunu, charcoal boje #36454F
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15
	
	; ispuna
	MOVE.W	#15, D1
	MOVE.W	#15, D2
	MOVE.B	#89, D0
	TRAP	#15
	
	; boja i stil fonta
	MOVE.L	#$00FFFFFF, D1
	MOVE.L	#0, D2
	MOVE.B	#21, D0
	TRAP	#15
			
	; namjestanje cursora
	CLR.W	D1
	MOVE.W	#$1F01, D1
	MOVE.B	#11, D0
	TRAP	#15
	
	; ispis lijevog scorea
	MOVE.B	#14, D0
	LEA	SCOREL, A1
	TRAP	#15
	
	; namjestanje cursora, opet
	CLR.W	D1
	MOVE.W	#$2D01, D1
	MOVE.B	#11, D0
	TRAP	#15
	
	; ispis desnog scorea
	MOVE.B	#14, D0
	LEA	SCORED, A1
	TRAP	#15
	
	RTS


*----------------------------------------------------------------------------------------*
OBRADIGOLDESNI:
	MOVEA.L	#SCOREL, A0
	ADDQ.L	#3, A0
	MOVE.B	(A0), D0
	SUB.B	#$30, D0 ; ascii -> bin
	ADD.B	#1, D0
	CMP.B	#5, D0
	BNE	SPREMI
	MOVE.W	#1, POBJEDA	; 2 u pobjeda znaci da je pobijedio lijevi
	BRA	ZAVRSNIZASLON

OBRADIGOLLIJEVI:
	MOVEA.L	#SCORED, A0
	ADDQ.L	#3, A0	; pomicemo se do broja
	MOVE.B	(A0), D0
	SUB.B	#$30, D0 ; ascii -> bin
	ADD.B	#1, D0
	CMP.B	#5, D0
	BNE	SPREMI
	MOVE.W	#2, POBJEDA	;2 u pobjeda znaci da je pobijedio desni
	BRA	ZAVRSNIZASLON

SPREMI:
	ADD.B	#$30, D0
	MOVE.B	D0, (A0)
	
	; ubrzaj lopticu
	MOVE.W	BRZINA, D0
	CMPI.B	#1, D0
	; ako je vec 1, nemas sto ubrzavati
	BEQ	NACENTAR
	SUB.W	#1, BRZINA 

NACENTAR:
	; lopticu na centar
	MOVEA.L	#LOPTICA, A0
	MOVE.W	#320, (A0)+
	MOVE.W	#240, (A0)
	; stavi smjer
	JSR	STAVISMJERLOPTICE
	
	BRA	INFPETLJA
	
*-----------------------------------------------------------------------------------------
CISTIZASLON:
	; boja 
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15
		
	; cisti zaslon
	MOVE.W	#0, D1
	MOVE.W	#0, D2
	MOVE.W	#640, D3
	MOVE.W	#480, D4

	MOVE.B	#87, D0
	TRAP	#15
	RTS

ZAVRSNIZASLON:
	JSR	CISTIZASLON
	JSR	POZADINA
	
	; olovka za ispunu, charcoal boje #36454F
	MOVE.L 	#$004F4536, D1
	MOVE.B	#81, D0
	TRAP	#15
	
	; ispuna
	MOVE.W	#15, D1
	MOVE.W	#15, D2
	MOVE.B	#89, D0
	TRAP	#15
		
	; boja teksta
	MOVE.L	#$00FFFFFF, D1
	MOVE.L	#0, D2
	MOVE.B	D0, 21
	TRAP	#15
	
	; namjestanje cursora
	CLR.W	D1
	MOVE.W	#$190A, D1
	MOVE.B	#11, D0
	TRAP	#15
	
	CMPI	#1, POBJEDA
	BNE	POBJEDADESNI
	
POBJEDALIJEVI:
	; ispis teksta
	MOVE.B	#14, D0
	LEA	POBJEDNIKL, A1
	TRAP	#15
	BRA	SLJEDECIKOMADTEKSTA
		
POBJEDADESNI:
	; ispis teksta
	MOVE.B	#14, D0
	LEA	POBJEDNIKD, A1
	TRAP	#15
	BRA	SLJEDECIKOMADTEKSTA

SLJEDECIKOMADTEKSTA:
	CLR.W	D1
	MOVE.W	#$100C, D1
	MOVE.B	#11, D0
	TRAP	#15
	MOVE.B	#14, D0
	LEA	PONOVNO, A1
	TRAP	#15
	
	
; i sad cekamo pritisak spacebara. ako do njega dode, igra se ponovno pokrece
	JSR	SPACELOOP
	JSR	CISTIZASLON
	
	; ocisti score
	MOVEA.L	#SCOREL, A0
	ADDQ.L	#3, A0
	MOVE.B	#'0', (A0)
	
	MOVEA.L #SCORED, A0
	ADDQ.L	#3, A0
	MOVE.B	#'0', (A0)
	
	BRA	START

	
	BRA	KRAJ	
	
	
	
	END	START		




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~

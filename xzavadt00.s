; Autor reseni: Tomáš Zavadil xzavadt00

; Projekt 2 - INP 2024
; Vigenerova sifra na architekture MIPS64

; DATA SEGMENT
                .data
msg:            .asciiz "tomaszavadil" ; Vase jmeno a prijmeni bez mezer a diakritiky
cipher:         .space  31             ; Misto pro zapis zasifrovaneho textu
key:            .asciiz "zav"          ; Sifrovaci klic - prvni tri pismena prijmeni
params_sys5:    .space  8              ; Misto pro ulozeni adresy retezce pro syscall 5

; CODE SEGMENT
                .text

main:
                ; Inicializace registrů a konstant
                daddi   r10, r0, 97    ; r10 = ASCII hodnota 'a'
                daddi   r11, r0, 122   ; r11 = ASCII hodnota 'z'
                daddi   r12, r11, 1    ; r12 = ASCII hodnota 'z' + 1
                daddi   r18, r0, 26    ; r18 = konstanta 26 (použití při cyklickém posunu)

                ; Nastavení ukazatelů
                daddi   r5, r0, msg    ; r5 = adresa zprávy
                daddi   r6, r0, cipher ; r6 = adresa pro výstup
                daddi   r7, r0, key    ; r7 = adresa klíče
                daddi   r8, r0, 0      ; r8 = index klíče
                daddi   r9, r0, 0      ; r9 = směr posunu (0 = vpřed, 1 = vzad)

encrypt_loop:
                lb      r13, 0(r5)     ; Načtení znaku zprávy do r13
                beq     r13, r0, encrypt_end ; Pokud je znak nulový, konec šifrování

                lb      r14, 0(r7)     ; Načtení znaku klíče do r14
                beq     r14, r0, reset_key_pointer ; Pokud je konec klíče, reset klíče

                ; Výpočet posunu
                sub     r15, r14, r10  ; r15 = hodnota posunu (0 až 25)
                daddi   r15, r15, 1    ; Převod na posun (1 až 26)

                ; Kontrola směru posunu
                beq     r9, r0, shift_forward ; Pokud r9 == 0, posun vpřed

shift_backward:
                ; Posun vzad
                sub     r16, r13, r15  ; r16 = původní znak - posun
                slt     r17, r16, r10  ; r17 = 1, pokud r16 < 'a'
                bne     r17, r0, wrap_around_backward ; Pokud r16 < 'a', cyklický posun
                j       store_char

wrap_around_backward:
                add     r16, r16, r18  ; r16 = r16 + 26 (cyklický posun zpět)
                j       store_char

shift_forward:
                ; Posun vpřed
                add     r16, r13, r15  ; r16 = původní znak + posun
                slt     r17, r16, r12  ; r17 = 1, pokud r16 < ('z'+1)
                bne     r17, r0, store_char ; Pokud r16 < ('z'+1), žádný cyklický posun
                sub     r16, r16, r18  ; r16 = r16 - 26 (cyklický posun vpřed)

store_char:
                sb      r16, 0(r6)     ; Uložení zašifrovaného znaku do 'cipher'

                ; Posun ukazatelů
                daddi   r5, r5, 1      ; Posun v 'msg'
                daddi   r6, r6, 1      ; Posun v 'cipher'
                daddi   r7, r7, 1      ; Posun v 'key'

                ; Přepnutí směru posunu
                xori    r9, r9, 1      ; Přepnutí r9 mezi 0 a 1
                j       encrypt_loop

reset_key_pointer:
                daddi   r7, r0, key    ; Resetování ukazatele klíče na začátek
                j       encrypt_loop

encrypt_end:
                sb      r0, 0(r6)      ; Přidání nulového znaku na konec 'cipher'

                ; Příprava pro výpis zašifrovaného textu
                daddi   r4, r0, cipher ; Nastavení adresy zašifrovaného textu do r4
                jal     print_string   ; Volání funkce pro výpis

; NASLEDUJICI KOD NEMODIFIKUJTE!

                syscall 0              ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5             ; systemova procedura - vypis retezce na terminal
                jr      r31           ; return - r31 je urcen na return address

.data

choix1: .asciiz "1.Valider un numéro de carte bancaire.\n"
choix2: .asciiz "2.Générer un numéro de carte bancaire.\n"
choix3: .asciiz "3.Quitter.\n"
n: .asciiz "\n"
fin_prog: .asciiz "Au revoir.\n"

choix_carte_1: .asciiz "1.American Express\n"
choix_carte_2: .asciiz "2.Diners Club - International\n"
choix_carte_3: .asciiz "3.Discover\n"
choix_carte_4: .asciiz "4.InstaPayment\n"
choix_carte_5: .asciiz "5.JCB\n"
choix_carte_6: .asciiz "6.Maestro\n"
choix_carte_7: .asciiz "7.MasterCard\n"
choix_carte_8: .asciiz "8.Visa\n"
choix_carte_9: .asciiz "9.Visa Electron\n"

codeCarte: .space 80
msg1: .asciiz "Veuillez les numéros de votre carte (un à un) (pressez entrée entre chaque numéro et un nombre >=10 pour signaler la fin)\n"
msg2: .asciiz "numero carte invalide\n"
	
.text

#Menu choix de l'action
debut:
	li $v0 4
	la $a0 choix1
	syscall

	la $a0 choix2
	syscall

	la $a0 choix3
	syscall

	li $v0 5
	syscall

#Valider un numéro
premier_choix: 
	bne $v0 1 deuxieme_choix
main: 
	jal InputCode
	move $a1, $v1
	jal algoMod10
testprint:
	bgt $t0, $t2, exit	#on parcourt jusqu'a la fin
	lw $a0, codeCarte($t0)	#tmp = tab[debut]
	syscall
	addi $t0, $t0, 4	#debut += 1
	b testprint
exit:	
	li $v0 10
	syscall

#proto de algoMod10:
# 	codeCarte  - le code de la carte.
# 	v1  - le nombre de chiffres du code
					#t0 - index d�but du tableau
InputCode:
	li $v0 4 
	la $a0 msg1
	syscall				#print msg1
	li $t0 0 			#t0 indice d�but = 0
LoopInputCode:	
	li $v0 5 			#v0 = input int
	syscall
	bge $v0 10 end_LoopInputCode	#on quitte la boucle si input >=10
	bge $t0 80 CarteIncorrect 	#si plus de 20 elements, carte incorrecte
	sw $v0, codeCarte($t0) 		#tab[debut] = input
	addi $t0, $t0, 4 		#indice++
	b LoopInputCode
end_LoopInputCode:
	blt $t0 13 CarteIncorrect 	#si moins de 13 chiffres, code inconnu
	div $v1, $t0, 4 		# v1 = nombre d'�l�ment dans le tableau
	j end_InputCode
CarteIncorrect:
	li $v0 4
	la $a0 msg2
	syscall
	li $v0 0
	j end_InputCode
end_InputCode:
	jr $ra

	
#proto de algoMod10: 
# 	codeCarte  - le code de la carte.
# 	a1  - le nombre de chiffres du code
#	cet algo suit les �taptes step by step de maniere naive.
				# variables temporairres de algoMod10:
				# t0 - Index Debut
				# t1 - nbchiffres
				# t2 - Index Max
				# t3 - tmp
algoMod10:
Step1:
	addi $t0, $zero, 0	# t0 Index debut = 0
	addi $t1, $a1, -1	# on enl�ve le dernier chiffre.
Step2:
	mul  $t2, $t1, 4	# t2 Index max = max
	addi $t3, $zero, 0	# t3 tmp = 0;
	div $t5, $t2, 2         # t5 = moiti�
inverser:
	bge $t0, $t5 Step3	# on parcrout jusqu'a la moiti�
	lw $t3, codeCarte($t2)	#tmp = tab[max]
	lw $t4, codeCarte($t0)	#t4 = tab[debut]
	sw $t4, codeCarte($t2)	#tab[max] = t4
	sw $t3, codeCarte($t0)	#tab[debut] = tmp
	
	addi $t0, $t0, 4	#debut++
	addi $t2, $t2, -4	#max--
	b inverser
Step3:
	addi $t0, $zero, 0	#t0 = Index debut = 0.
	mul $t2, $t1, 	4	#t2 = Index max = max
multImpaire:
	bgt $t0, $t2, Step4	#on parcourt jusqu'a la fin
	lw $t3, codeCarte($t0)	#tmp = tab[debut]
	mul $t3, $t3, 2		#tmp *= 2
	sw $t3, codeCarte($t0)	#tab[debut] = tmp
	addi $t0, $t0, 8	#debut += 2
	b multImpaire
	
Step4:
	addi $t0, $zero, 0	#t0 = Index debut = 0.
	addi $t4, $zero, 10
sub9:
	bgt $t0, $t2, Step5	#on parcourt jusqu'a la fin
	lw $t3, codeCarte($t0)	#tmp = tab[debut]
	blt $t3, $t4, inf10	#if tmp<10
	addi $t3, $t3, -9	#tmp -= 9
	sw $t3, codeCarte($t0)	#tab[debut] = tmp
inf10:
	addi $t0, $t0, 8	#debut += 2
	b sub9
Step5:
	addi $t0, $zero, 0	#t0 = Index debut = 0.
	addi $t4, $zero, 0	#t4 somme = 0
somme:
	bge $t0, $t2, Step6	#on parcourt jusqu'a la fin
	lw $t3, codeCarte($t0)	#tmp = tab[debut]
	add $t4, $t4, $t3
	addi $t0, $t0, 8	#debut ++
	b somme
Step6:
	rem $t3, $t4, 10	#t3 = t4%10
Step7:
	addi $t2, $zero, 10	#t2 = 10
	sub $v1, $t2, $t4	#v1 = t2 - t4
	jr $ra			#jump back
	
    
	j debut
	
#Générer un numéro de carte
deuxieme_choix: 
	bne $v0 2 dernier_choix
	
#Menu choix du type de carte
menu_bis:
	li $v0 4
	la $a0 choix_carte_1
	syscall
	la $a0 choix_carte_2
	syscall
	la $a0 choix_carte_3
	syscall
	la $a0 choix_carte_4
	syscall
	la $a0 choix_carte_5
	syscall
	la $a0 choix_carte_6
	syscall
	la $a0 choix_carte_7
	syscall
	la $a0 choix_carte_8
	syscall
	la $a0 choix_carte_9
	syscall

	li $v0 5
	syscall
	
#compteur pour la boucle while
	li $t2 1
	li $t3 0
	
#American Express
choixc_1:	
	bne $v0 1 choixc_2
	li $t4 13
	li $v0 1
	la $a0 3
	syscall
	li $t7 7
	li $t5 4
	or $t6 $t7 $t5
	la $a0 ($t6)
	syscall
	j debutWhile

#Diners Club - International
choixc_2:
	bne $v0 2 choixc_3
	li $t4 12
	li $v0 1
	la $a0 36
	syscall
	j debutWhile

#Discover
choixc_3:
	bne $v0 3 choixc_4
	li $v0 1
	la $a0 6
	syscall
	li $t5 4
	li $t6 2
	or $t7 $t5 $zero
	or $t8 $t6 5
	or $t9 $t7 $t8
	bne $t9 $zero deux
	li $a0 011
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile
	
deux:	bne $t9 $t6 quatre
	la $a0 22
	syscall
	li $v0 42
	la $a1 9
	syscall
	addi $a0 $a0 1
	bne $a0 9 else
	li $v0 1
	syscall
	la $a0 2
	syscall
	li $v0 42
	la $a1 6
	syscall
	li $v0 1
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 10
	j debutWhile
	
else:	bne $a0 2 else2
	li $v0 1
	syscall
	la $a0 2
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $a0 $a0 6
	li $v0 1
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 10
	j debutWhile
	
else2:	li $v0 1
	syscall
	la $a0 2
	syscall
	li $v0 42
	la $a1 10
	syscall
	li $v0 1
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 10
	j debutWhile
	
quatre: bne $t9 $t5 cinq
	li $a0 4
	syscall
	li $v0 42
	la $a1 6
	syscall
	addi $a0 $a0 4
	li $v0 1
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 13
	j debutWhile
	
cinq:	la $a0 5
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 14
	j debutWhile
	
#InstaPayment
choixc_4:
	bne $v0 4 choixc_5
	li $t4 13
	li $v0 1
	la $a0 63
	syscall
	li $v0 42
	la $a1 3
	syscall
	addi $t5 $a0 7
	li $v0 1
	la $a0 ($t5)
	syscall
	j debutWhile

#JCB
choixc_5:
	bne $v0 5 choixc_6
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	li $v0 1
	la $a0 35
	syscall
	li $v0 42
	la $a1 62
	syscall
	addi $t5 $a0 28
	li $v0 1
	la $a0 ($t5)
	syscall
	j debutWhile

#Maestro
choixc_6:
	bne $v0 6 choixc_7
	li $t5 5
	or $t6 $t5 2
	or $t7 $t6 6
	bne $t7 2 cinq_6
	li $v0 1
	la $a0 2893
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile
	
cinq_6:	bne $t7 5 six_6
	li $v0 1
	la $a0 50
	syscall
	li $v0 42
	la $a1 3
	syscall
	addi $a0 $a0 1
	bne $a0 2 _else
	li $v0 1
	la $a0 20
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile
_else:	li $v0 1
	syscall
	la $a0 8
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile
	
six_6:	li $v0 1
	la $a0 6
	syscall
	li $t8 7
	or $t9 $t8 3
	bne $t9 $t8 _else2
	li $v0 1
	la $a0 7
	syscall
	or $t0 $t5 6
	or $t1 $t0 8
	bne $t1 5 huit
	li $v0 1
	la $a0 59
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile
huit: 	bne $t1 8 _else_again
	li $v0 1
	la $a0 81
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile
_else_again: 
	li $v0 1
	la $a0 6
	syscall
	li $v0 42
	la $a1 2
	syscall
	addi $a0 $a0 2
	li $v0 1
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile
_else2: li $v0 1
	la $a0 304
	syscall
	li $v0 42
	la $a1 4
	syscall
	addi $t4 $a0 12
	j debutWhile

#MasterCard
choixc_7:
	bne $v0 7 choixc_8
	li $t6 5
	or $t5 $t6 2
	bne $t5 $t6 nb_bis
	li $t4 14
	li $v0 42
	la $a1 5
	syscall
	addi $a0 $a0 1
	li $v0 1
	syscall
	j debutWhile
	
nb_bis: li $t4 10
	li $v0 1
	la $a0 2
	syscall
	li $t5 2
	or $t6 $t5 7
	la $a0 ($t6)
	syscall
	la $a0 2
	syscall
	bne $t6 7 alea
	la $a0 0
	syscall
	li $v0 42
	la $a1 10
	syscall
	li $v0 1
	syscall
	li $v0 42
	la $a1 10
	syscall
	j debutWhile
	
alea:	li $v0 42
	la $a1 2
	syscall
	li $v0 42
	la $a1 10
	syscall
	li $v0 1
	syscall
	li $v0 42
	la $a1 10
	syscall
	j debutWhile

#Visa
choixc_8:
	bne $v0 8 choixc_9
	li $t5 12
	li $t6 15
	or $t4 $t5 $t6 
	#or $t4 $t7 18
	li $v0 1
	la $a0 4
	syscall
	j debutWhile

#Visa Electron
choixc_9:
	bne $v0 9 debut
	li $v0 1
	la $a0 4
	syscall
	li $t5 5
	li $t6 1
	or $t7 $t5 8
	or $t8 $t7 9
	or $t9 $t8 $zero
	or $t0 $t9 $t6
	bne $t0 $zero else1
	li $v0 1
	la $a0 026
	syscall
	li $t4 12
	j debutWhile

else1:	bne $t0 $t5 else_2
	li $v0 1
	la $a0 508
	syscall
	li $t4 12
	j debutWhile

else_2: bne $t0 8 else3
	li $v0 1
	la $a0 844
	syscall
	li $t4 12
	j debutWhile
	
else3: 	bne $t0 9 else4
	li $v0 1
	la $a0 91
	syscall
	li $t1 7
	or $t5 $t1 3
	la $a0 ($t5)
	syscall
	li $t4 12
	syscall
	j debutWhile

else4: 	li $v0 1
	la $a0 17500
	syscall
	li $t4 10
	j debutWhile	

#boucle permettant de générer un numéro de carte
debutWhile:
	bge $t3 $t4 finboucle
	li $v0 42
	la $a1 10
	syscall
	addi $t3 $t3 1
	li $v0 1
	syscall
	j debutWhile
finboucle:
	li $v0 4
	la $a0 n
	syscall
	j debut

#Quitter la programme
dernier_choix: 
	bne $v0 3 sortie
sortie:
	li $v0 4
	la $a0 fin_prog
	syscall
	li $v0 10
	syscall

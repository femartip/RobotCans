; Base de Hechos:
;R=Robot LL=Latas L=Lata N=nivel 
;(R ?c ?f LL [L ?cl ?fl]^m N ?n)
;c=col f=fila cl/fl=col/fila lata 
; D=Dimensiones (D ?col_ini ?col_fin ?fila_inicial ?fila_final)
; C=Contenedores CC[C ?cc ?fc]^m
(defglobal ?*nod-gen* = 0)

(deffacts bh    ;;base de hechos 
    (D 8 5)     ;;Dimension hecho estatico 
    (C 1 5)     ;;Cada contenedro, hecho estatico  
    (C 1 3) 
    (C 2 1) 
    (C 4 3) 
    (C 4 5) 
    (C 6 1) 
    (C 7 5) 
    (C 8 3) 
    (C 8 1) 
    (R 2 3 nivel 0 LL L 3 1 L 3 3 L 6 4))   ;;Hechos dinamicos 

(deffunction inicio ()
    (reset)
	(printout t "Profundidad Maxima:= " )
	(bind ?prof (read))
	(printout t "Tipo de Busqueda " crlf "    1.- Anchura" crlf "    2.- Profundidad" crlf )
	(bind ?a (read))
	(if (= ?a 1)
	       then   (set-strategy breadth)
	       else   (set-strategy depth))
        (printout t " Ejecuta run para poner en marcha el programa " crlf)
	  
	(assert (profundidad-maxima ?prof)) 
	
)

(defrule subir     ;;subir 
    (R ?c ?f nivel ?n LL $?ll)     ;;Estado del robot y latas 
    (D ?cf ?ff)  ;;Dimensiones estaticas del tablero 
    (profundidad-maxima ?prof)  ;Profundidad maxima 
    (test (< ?f ?ff))  ;;Comprueba que no se sale del tablero  
    (not (C  ?c =(+ ?f 1))) ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test(not (member$ (create$ L ?c (+ ?f 1)) $?ll)))  ;;No nos movemos a una lata
    (test (< ?n ?prof)) ;;Comprobar que no se ha superado la profundidad maxima
=>
(assert (R ?c (+ ?f 1) nivel (+ ?n 1) LL $?ll))   ;;Si celda a de arriba libre y dentro del limite se mueve
(bind ?*nod-gen* (+ ?*nod-gen* 1)))   

(defrule bajar     ;;bajar
    (R ?c ?f nivel ?n LL $?ll)   ;;Estado del robot y latas 
    (profundidad-maxima ?prof) ;profundidad maxima 
    (test (> ?f 1))   ;;Comprueba que no se sale del tablero 
    (not (C ?c =(- ?f 1)))  ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test(not (member$ (create$ L ?c (- ?f 1)) $?ll)))
    (test (< ?n ?prof))
=>
(assert (R ?c (- ?f 1) nivel (+ ?n 1) LL $?ll))    ;;Si celda de abajo libre y dentro del limite se mueve 
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule izq    ;;izquierda
    (R ?c ?f nivel ?n LL $?ll)   ;;Estado del robot y latas  
    (profundidad-maxima ?prof) ;profundidad maxima
    (test (> ?c 1))   ;;Comprueba que no se sale del tablero
    (not (C = (- ?c 1) ?f)) ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test(not (member$ (create$ L (- ?c 1) ?f) $?ll)))
    (test (< ?n ?prof))
=>
(assert (R (- ?c 1) ?f nivel (+ ?n 1) LL $?ll))    ;;Si celda a izquierda libre y dentro del limite se mueve
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule der    ;;derecha 
    (R ?c ?f nivel ?n LL $?ll)   ;;Estado del robot y latas 
    (D ?cf ?ff)   ;;Dimensiones estaticas del tablero 
    (profundidad-maxima ?prof) ;profundidad maxima
    (test (< ?c ?cf))   ;;Comprueba que no se sale del tablero 
    (not (C = (+ ?c 1) ?f)) ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test(not (member$ (create$ L (+ ?c 1) ?f) $?ll)))
    (test (< ?n ?prof))
=>
(assert (R (+ ?c 1) ?f nivel (+ ?n 1) LL $?ll))    ;;Si celda a derecha libre y dentro de limites se mueve 
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule sublata     ;;subir lata 
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)     ;;Estado del robot y latas 
    (D ?cf ?ff)  ;;Dimensiones estaticas del tablero 
    (profundidad-maxima ?prof) ;profundidad maxima
    (test (< ?fl ?ff))  ;;Comprueba que no se sale del tablero  
    (not (C ?c = (+ ?f 2))) ;;Comprueba que se puede mover ya que no hay ningun contenedor
    (test (not(member$ (create$ L ?c (+ ?f 2)) $?r1)))  ;;comprobar que ya no hay otra lata
    (test (not(member$ (create$ L ?c (+ ?f 2)) $?r2)))
    (test (and (= ?cl ?c) (= ?fl (+ ?f 1))))    ;;Comprueba si hay una lata arriba
    (test (< ?n ?prof))
=>
(assert (R ?c (+ ?f 1) nivel (+ ?n 1) LL $?r1 L ?cl (+ ?fl 1) $?r2))   ;;Si celda a de arriba libre y dentro del limite, mueve tanto al robto como a al lata 
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule bajlata     ;;bajar lata
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)   ;;Estado del robot y latas   
    (profundidad-maxima ?prof) ;profundidad maxima
    (test (> ?fl 1))   ;;Comprueba que no se sale del tablero 
    (not (C ?c = (- ?f 2)))  ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test (not(member$ (create$ L ?c (- ?f 2)) $?r1)))  ;;comprobar que ya no hay otra lata
    (test (not(member$ (create$ L ?c (- ?f 2)) $?r2)))
    (test (and (= ?cl ?c) (= ?fl (- ?f 1))))    ;;Comprueba si hay una lata abajo
    (test (< ?n ?prof))
=>
(assert (R ?c (- ?f 1) nivel (+ ?n 1) LL $?r1 L ?cl (- ?fl 1) $?r2))    ;;Si celda de abajo libre y dentro del limite, mueve tanto al robot como a la lata  
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule izqlata    ;;izquierda lata
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)   ;;Estado del robot y latas   
    (profundidad-maxima ?prof) ;profundidad maxima
    (test (> ?cl 1))   ;;Comprueba que no se sale del tablero
    (not (C = (- ?c 2) ?f)) ;;Comprueba que se puede mover ya que no hay ningun contenedor
    (test (not(member$ (create$ L (- ?c 2) ?f) $?r1)))  ;;comprobar que ya no hay otra lata 
    (test (not(member$ (create$ L (- ?c 2) ?f) $?r2)))
    (test (and (= ?cl (- ?c 1)) (= ?fl ?f)))    ;;Comprueba si hay una lata a la izquierda
    (test (< ?n ?prof))
=>
(assert (R (- ?c 1) ?f nivel (+ ?n 1) LL $?r1 L (- ?cl 1) ?fl $?r2))    ;;Si celda a izquierda libre y dentro del limite, mueve tanto al robot como a la lata 
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule derlata    ;;derecha lata
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)   ;;Estado del robot y latas 
    (D ?cf ?ff)   ;;Dimensiones estaticas del tablero 
    (profundidad-maxima ?prof) ;profundidad maxima
    (test (< ?cl ?cf))   ;;Comprueba que no se sale del tablero 
    (not (C = (+ ?c 2) ?f)) ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test (not(member$ (create$ L (+ ?c 2) ?f) $?r1)))  ;;comprobar que ya no hay otra lata
    (test (not(member$ (create$ L (+ ?c 2) ?f) $?r2)))
    (test (and (= ?cl (+ ?c 1)) (= ?fl ?f)))    ;;Comprueba si hay una lata a la derecha
    (test (< ?n ?prof))
=>
(assert (R (+ ?c 1) ?f nivel (+ ?n 1) LL $?r1 L (+ ?cl 1) ?fl $?r2))   ;;Si celda a derecha libre y dentro de limites, mueve tanto al robot como a la lata
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule sublatatriturar     ;;triturar lata arriba  
    (declare (salience 50))
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)     ;;Estado del robot y latas 
    (profundidad-maxima ?prof) ;profundidad maxima   
    (C ?c = (+ ?f 2)) ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test (and (= ?cl ?c) (= ?fl (+ ?f 1))))    ;;Comprueba si hay una lata arriba
    (test (< ?n ?prof))
=>
(assert (R ?c (+ ?f 1) nivel (+ ?n 1) LL $?r1 $?r2))   ;;Si celda a de arriba libre y dentro del limite, mueve tanto al robto como a al lata 
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule bajlatatriturar     ;;triturar lata abajo 
    (declare (salience 50))
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)   ;;Estado del robot y latas  
    (profundidad-maxima ?prof) ;profundidad maxima
    (C ?c = (- ?f 2))  ;;Comprueba que se puede mover ya que no hay ningun contenedor
    (test (and (= ?cl ?c) (= ?fl (- ?f 1))))    ;;Comprueba si hay una lata abajo 
    (test (< ?n ?prof))
=>
(assert (R ?c (- ?f 1) nivel (+ ?n 1) LL $?r1 $?r2))    ;;Si celda de abajo libre y dentro del limite, mueve tanto al robot como a la lata  
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule izqlatatriturar    ;;izquierda lata
    (declare (salience 50))
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)   ;;Estado del robot y latas  
    (profundidad-maxima ?prof) ;profundidad maxima
    (C = (- ?c 2) ?f) ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test (and (= ?cl (- ?c 1)) (= ?fl ?f)))    ;;Comprueba si hay una lata a la izquierda 
    (test (< ?n ?prof))
=>
(assert (R (- ?c 1) ?f nivel (+ ?n 1) LL $?r1 $?r2))    ;;Si celda a izquierda libre y dentro del limite, mueve tanto al robot como a la lata 
(bind ?*nod-gen* (+ ?*nod-gen* 1)))

(defrule derlatatriturar    ;;derecha lata
    (declare (salience 50))
    (R ?c ?f nivel ?n LL $?r1 L ?cl ?fl $?r2)   ;;Estado del robot y latas 
    (profundidad-maxima ?prof) ;profundidad maxima
    (C = (+ ?c 2) ?f) ;;Comprueba que se puede mover ya que no hay ningun contenedor 
    (test (and (= ?cl (+ ?c 1)) (= ?fl ?f)))    ;;Comprueba si hay una lata a la derecha
    (test (< ?n ?prof))
=>
(assert (R (+ ?c 1) ?f nivel (+ ?n 1) LL $?r1 $?r2))   ;;Si celda a derecha libre y dentro de limites, mueve tanto al robot como a la lata
(bind ?*nod-gen* (+ ?*nod-gen* 1)))


(defrule objetivo
    (declare (salience 100))
    ?t <- (R ?cr ?fr nivel ?n LL) 
    =>
    (printout t "SOLUCION ENCONTRADA EN EL NIVEL " ?n crlf); 
    (printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nod-gen* crlf)
    (printout t "HECHO OBJETIVO " ?t crlf) 

    (halt))

(defrule no_solucion
    (declare (salience -99))
    (R $?r nivel ?n LL $?l)
    
=>
    (printout t "SOLUCION NO ENCONTRADA" crlf)
    (printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nod-gen* crlf)
    
    (halt))	
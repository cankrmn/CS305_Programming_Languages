(define which4OP
	(lambda (op)
		(cond 
   		   ((eq? op '*) *) 
		   ((eq? op '/) /) 
		   (else 0)
		)
	)
) 

(define which2OP
        (lambda (op)
                (cond
                   ((eq? op '+) +)
                   ((eq? op '-) -)
		   (else 0)
                )
        )
)

(define twoOperatorCalculator 
	(lambda (lst)
		(if (null? (cdr lst)) 
			(car lst)
			(if (null? (cdddr lst))
					((which2OP (cadr lst)) (car lst) (caddr lst))
					(twoOperatorCalculator (cons ((which2OP (cadr lst)) (car lst) (caddr lst)) (cdddr lst)))
			)
		)
	)
)

(define fourOperatorCalculator
	(lambda (lst)
		(if (null? (cdr lst))
			lst
			(if (equal? (which4OP (cadr lst)) 0) 
				(append (list (car lst)) (list (cadr lst)) (fourOperatorCalculator (cddr lst)))
				(fourOperatorCalculator (cons ((which4OP (cadr lst)) (car lst) (caddr lst)) (cdddr lst)))
			)
		)	  
	)
)

(define calculatorNested
	(lambda (lst)
		(if (null? lst)
			lst
			(if (and (list? (car lst)) (null? (cdr lst)))
				(list (twoOperatorCalculator (fourOperatorCalculator (calculatorNested (car lst)))))
				(if (list? (car lst))
					(append  (list (twoOperatorCalculator (fourOperatorCalculator (calculatorNested (car lst))))) (list (cadr lst)) (calculatorNested (cddr lst)))
					(if (null? (cdr lst))
						lst
						(append (list (car lst)) (list (cadr lst)) (calculatorNested (cddr lst)))
					)	
				)
			)
		)
	)
)

(define checkOperators
	(lambda (lst)
		(if (not (list? lst)) #f
			(if (null? lst)
				#f
				(if (null? (cdr lst))
					(if (number? (car lst)) 
						#t
						(if (list? (car lst))
							(checkOperators (car lst))
							#f
						)
					)
					(if (cO_helper (cdr lst)) #t #f)
				)	
			)	
		)
	)
)

(define cO_helper
	(lambda (lst)
		(if (and (equal? (which2OP (car lst)) 0) (equal? (which4OP (car lst)) 0))
			#f
			(if (list? (cadr lst))
				(if (checkOperators (cdr lst))
					(if (null? (cddr lst)) 
						#t 
						(if (cO_helper (cddr lst))
							#t
							#f
						)
					)
					#f
				)
				(if (not (number? (cadr lst)))
					#f
					(if (null? (cddr lst))
						#t
						(if (cO_helper (cddr lst))
							#t
							#f
						)	
					)
 				)
			)
		)
	)
)

(define calculator
	(lambda (lst)
		(if (not (checkOperators lst))
			#f
			(twoOperatorCalculator (fourOperatorCalculator (calculatorNested lst)))
		)
	)
)		

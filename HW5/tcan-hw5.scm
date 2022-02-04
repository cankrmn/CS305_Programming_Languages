(define get-op 
  (lambda (operator) 
    (cond
      ((equal? operator '+) +)
      ((equal? operator '-) -)
      ((equal? operator '*) *)
      ((equal? operator '/) /)
      (else #f)
    )
  )
)

(define def?
  (lambda (def-stmt)
    (and
      (list? def-stmt)
      (equal? (length def-stmt) 3)
      (equal? (car def-stmt) 'define)
      (symbol? (cadr def-stmt))
    )
  )
)

(define if?
  (lambda (if-stmt)
    (and
      (list? if-stmt)
      (equal? (length if-stmt) 4)
      (equal? (car if-stmt) 'if)
    )
  )
)

(define cond?
  (lambda (cond-stmt)
    (and
      (list? cond-stmt)
      (equal? (car cond-stmt) 'cond)
      (>= (length cond-stmt) 3)
      (cond?-helper (cdr cond-stmt))
    )
  )
)

(define cond?-helper (lambda (cond-stmt)
  (if (or (not (list? (car cond-stmt))) (not (equal? (length (car cond-stmt)) 2)))
    #f
    (if (null? (cdr cond-stmt))
      (equal? (caar cond-stmt) 'else)
      (if (equal? (caar cond-stmt) 'else)
        #f
        (cond?-helper (cdr cond-stmt))
      )
    )
  )  
))

(define let?
  (lambda (let-stmt)
    (and
     (list? let-stmt)
     (equal? (length let-stmt) 3)
     (equal? (car let-stmt) 'let)
     (list? (cadr let-stmt))
     (let?s-helper (cadr let-stmt))
    )
  )
)

(define letstar?
  (lambda (let-stmt)
   (and
     (list? let-stmt) 
     (equal? (length let-stmt) 3)
     (equal? (car let-stmt) 'let*)
     (list? (cadr let-stmt))
     (let?s-helper (cadr let-stmt))
    )
  )
)

(define let?s-helper (lambda (stmt)
  (if (null? stmt)
    #t
    (if (or (not (list? (car stmt))) (not (equal? (length (car stmt)) 2)))
      #f
      (if (not (symbol? (caar stmt)))
	#f
	(let?s-helper (cdr stmt))
      )
    )
  )
))

(define operation?
  (lambda (op)
    (and
      (list? op)
      (not (null? op))
      (if (equal? (get-op (car op)) #f) #f #t)
    )
  )
)

(define def-val
  (lambda (var val old-env)
    (cons (cons var val) (delete-old var old-env))
  )
)

(define delete-old
  (lambda (var old-env)
    (cond
      ((null? old-env) '())
      ((equal? var (caar old-env)) (cdr old-env))
      (else (cons (car old-env) (delete-old var (cdr old-env))))
    )
  )
)

(define find-val
  (lambda (var environment)
    (cond
      ((null? environment) "ERROR")
      ((equal? (caar environment) var) (cdar environment))
      (else (find-val var (cdr environment)))
    )
  )
)

(define run-if (lambda (expr env)
  (if (not (equal? (interpret (car expr) env) 0))
    (interpret (cadr expr) env)
    (interpret (caddr expr) env)
  )
))

(define run-cond (lambda (expr env)
  (cond
    ((equal? (caar expr) 'else) (interpret (cadar expr) env))
    ((not (equal? (interpret (caar expr) env) 0)) (interpret (cadar expr) env)) 
    (else (run-cond (cdr expr) env))
  )
))

(define run-let (lambda (expr temp-env)
  (if (not (null? (car expr)))
    (let* (
      (vals (let-helper-evaluator (car expr) temp-env '() ))
      (env (let-helper-definer (car expr) vals temp-env))
      )
      (interpret (cadr expr) env)
    )
    (interpret (cadr expr) temp-env)
  )
))

(define let-helper-evaluator (lambda (expr env vals)
  (let* (
      (value (list (interpret (cadar expr) env)))
    )
  (if (null? (cdr expr))
    (append vals value)
    (let-helper-evaluator (cdr expr) env (append vals value))
  ))
))

(define let-helper-definer (lambda (expr vals env)
  (let* (
      (new-env (def-val (caar expr) (car vals) env))
    )
    (if (null? (cdr vals))
      new-env
      (let-helper-definer (cdr expr) (cdr vals) new-env)
    )
  )
))


(define run-letstar (lambda (expr temp-env)
  (if (not (null? (car expr)))
    (let* (
        (env (def-val (caaar expr) (interpret (cadaar expr) temp-env) temp-env))
      )
      (run-letstar (cons (cdar expr) (cdr expr)) env)
    )
    (interpret (cadr expr) temp-env)
  )
))

(define run-operation (lambda (expr env)
  (let (
        (operands (map interpret (cdr expr) (make-list (length (cdr expr)) env)))
	(operator (get-op (car expr)))
       )
       (apply operator operands)
  )
))

(define interpret
  (lambda (expr environment)
    (cond
      ((number? expr) expr)
      ((symbol? expr) (find-val expr environment))
      ((not (list? expr)) "ERROR")
      ((if? expr) (run-if (cdr expr) environment))
      ((cond? expr) (run-cond (cdr expr) environment))
      ((let? expr) (run-let (cdr expr) environment))
      ((letstar? expr) (run-letstar (cdr expr) environment))
      ((operation? expr) (run-operation expr environment))
      (else "ERROR")
    )
  )
)


(define repl
  (lambda (environment)
    (let* (
        (l1 (display "cs305> "))
        (expr (read))
        (new-environment 
          (if (def? expr)
            (def-val (cadr expr) (interpret (caddr expr) environment) environment)
	    environment
	  )
	)
        (value
          (cond
            ((def? expr) (cadr expr))
	    (else (interpret expr environment))
          )
        )
        (l2 (display "cs305: "))
        (l2-2 (display value))
        (l3 (newline))
        (l4 (newline))
      )
      (repl new-environment)
    )  
  )
)

(define cs305 (lambda () (repl '())))

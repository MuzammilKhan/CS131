

;Return #t if obj is an empty listdiff, #f otherwise.
(define (null-ld?  obj)
    (cond 
        [(null? obj)]
        [(not (pair? obj)) ]
        [(null? (car obj))]
        [else (eq? (car obj) (cdr obj))]))

;helper function
(define (listdiff_helper? a b)   
    (if  (and (not (null? a)) (pair? a))  ;PROBLEM HERE
        (cond
            [(eq? a b)]
            [(listdiff_helper? (cdr a) b)]
            [else #f]
         )
         #f ))

;Return #t if obj is a listdiff, #f otherwise.     
(define (listdiff? obj )
    (cond 
        [(not (pair? obj)) #f]
        [(null? (cdr obj))]
        [(null? obj) #f]
        [else (listdiff_helper? (car obj) (cdr obj))]
    ))


;Return a listdiff whose first element is obj and whose remaining elements are listdiff.
;(Unlike cons, the last argument cannot be an arbitrary object; it must be a listdiff.) <-assumption or do we check?????
(define (cons-ld  obj listdiff )
    (cond 
        [(listdiff? listdiff) (cons (cons obj) listdiff)]
        [else error]))

;Return the first element of listdiff. It is an error if listdiff has no elements.
(define (car-ld listdiff )
    (cond 
        [(null-ld? listdiff) 'error ]
        [(and (not(null? (cdr listdiff))) (null? (cddr listdiff)) (pair?  listdiff)) (car listdiff) ]
        [(pair? (car listdiff)) (caar listdiff) ]
        [else (car listdiff)] ))


;Return a listdiff containing all but the first element of listdiff. It is an error if listdiff has no elements.
(define (cdr-ld listdiff )
    (cond 
        ;[(null-ld? listdiff) 'error ]
        [(null? (cdr listdiff)) (cdr (car listdiff)) ]
        [else (cdr  listdiff)] ))

;Return a newly allocated listdiff of its arguments.
(define (listdiff . obj)
    (let ((tail (car (reverse obj))) (output (list obj))) 
    (cond
        [(pair? tail )   (cons output (cdr (car (reverse obj))))]
    [else output])))

;helper function
(define (length-ld-helper listdiff)
    (cond
        [(null-ld? listdiff) 0] ;minus 
        [(pair? listdiff) (+ (length-ld-helper (car listdiff) )   1 ) ]
        [else 0]
    )

)
;Return the length of listdiff.
(define (length-ld  listdiff )
    (cond 
        [(not(listdiff? listdiff)) 'error]
        [(null-ld? listdiff) 0]
        [else (length-ld-helper listdiff )]
    )
)

;Return a listdiff consisting of the elements of the first listdiff followed by the elements of the other listdiffs.
;The resulting listdiff is always newly allocated, except that it shares structure with the last argument. 
;(Unlike append, the last argument cannot be an arbitrary object; it must be a listdiff.)
(define (append-ld . listdiff )
        (cons (list listdiff) (cdr (car (reverse listdiff))))
) ;;UNSURE FIX ME!!!!!!!

;alistdiff must be a listdiff whose members are all pairs. 
;Find the first pair in alistdiff whose car field is eq? to obj, and return that pair; if there is no such pair, return #f.
(define (assq-ld obj alistdiff)
    (cond 
        [(null? alistdiff) #f]
        [(not(pair? alistdiff)) #f]
        [(null? (car alistdiff)) #f]
        [ (eq? obj (car alistdiff)) alistdiff]
        [(assq-ld obj (car alistdiff))]
        [else (assq-ld obj (cdr alistdiff))]
))

;Return a listdiff that represents the same elements as list.
(define (list->listdiff list )
    (listdiff list)) ;is this right?


;helper function
(define (listdiff->list-helper a b acc)
    (cond 
        [(equal? a b) acc]
        [(or (null? a) (not(pair? a))) '()]        
        [else (listdiff->list-helper (cdr a) b (append acc `(,(car a))))]
        )
    )

;Return a list that represents the same elements as listdiff.
(define (listdiff->list listdiff )  ;check 
    (cond
        [(null-ld? listdiff) '() ]
        [else  (listdiff->list-helper (car listdiff) (cdr listdiff) '())] ))

;Return a Scheme expression that, when evaluated, will return a copy of listdiff,
;that is, a listdiff that has the same top-level data structure as listdiff. 
;Your implementation can assume that the argument listdiff contains only booleans, characters, numbers, and symbols.
(define (expr-returning listdiff )
    (let ((x (car listdiff)) (y (cdr listdiff)))
    `(cons ',x ',y) ) 
)


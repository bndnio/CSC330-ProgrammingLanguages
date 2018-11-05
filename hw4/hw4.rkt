#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; these definitions are simply for the purpose of being able to run the tests
;; you MUST replace them with your solutions
;;

(define (sequence low high stride)
  (letrec (
    [next (lambda (num)
      (if (> num high)
          null
          (cons num (next (+ num stride))))
    )])
    (next low)
))

(define (string-append-map xs suffix)
  (let ([my-append (lambda (str)
                     (string-append str suffix)
       )])
       (map my-append xs)
  )
)

(define (list-nth-mod xs n)
  (cond [(< n 0) (error "list-nth-mod: negative number")]
        [(= (length xs) 0) (error "list-nth-mod: empty list")]
        [#t
          (letrec ([rem (remainder n (length xs))]
                   [find-nth (lambda (ys i)
                               (if (= i rem)
                                   (car ys)
                                   (find-nth (cdr ys) (+ i 1))
                  ))])
                  (find-nth xs 0)
        )]
))

(define (stream-for-n-steps s n)
  (if (= n 0) null (cons (car (s)) (stream-for-n-steps (cdr (s)) (- n 1))))
)

(define funny-number-stream
  (letrec ([get_next_funny (lambda (x)
                             (cons
                              (if (= (modulo x 5) 0) (- 0 x) x)
                              (lambda () (get_next_funny (+ x 1)))
          ))])
          (lambda () (get_next_funny 1))
))

(define cat-then-dog
  (letrec ([get_dog (lambda () (cons "dog.jpg" get_cat))]
           [get_cat (lambda () (cons "cat.jpg" get_dog))])
          get_cat
))

(define (stream-add-zero s)
  (letrec ([add_zero (lambda (s)
                       (cons
                        (cons 0 (car (s)))
                        (lambda () (add_zero (cdr (s))))
          ))])
          (lambda () (add_zero s))
))

(define (cycle-lists xs ys)
  (letrec ([zip_next (lambda (xs ys i)
                       (cons
                        (cons (list-nth-mod xs i) (list-nth-mod ys i))
                        (lambda ()
                          (zip_next xs ys (+ i 1))
           )))])
           (lambda () (zip_next xs ys 0))
))

(define (vector-assoc v vec)
  (letrec ([vec_len (vector-length vec)]
           [next (lambda (i)
                   (cond [(= i vec_len) #f]
                         [(equal? (vector-ref vec i) #f) #f]
                         [(equal? v (car (vector-ref vec i))) (vector-ref vec i)]
                         [#t (next (+ i 1))]
          ))])
          (next 0)
))

(define (cached-assoc xs n)
  (let* ([cache (make-vector n #f)]
         [i 0]
         [save-cache (lambda (ans) (set! i (+ i 1)))]
        )
        (lambda (v)
          (let* ([val (vector-assoc v cache)])
                (cond [val val]
                      [#t (let ([ans (assoc v xs)])
                          (cond [ans (begin (save-cache ans) ans)]
                                [#t #f]
       ))])))
))

(define-syntax while-less
  (syntax-rules (do)
    [(while-less e1 do e2)
      (letrec ([while (lambda (thunk) (if (car thunk) (while ((cdr thunk))) (car thunk)))]
               [base (if (procedure? e1) (e1) e1)]
               [eval-e (lambda (e) (if (procedure? e) (e) e))]
               [build-thunk (lambda () (cons (< (eval-e e2) base) build-thunk))])
              (begin (while (build-thunk)) #t)
)]))

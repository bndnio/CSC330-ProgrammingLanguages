;; Programming Languages, Homework 5 version 1.1
#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body)
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0

;; a closure is not in "source" programs; it is what functions evaluate to
(struct closure (env fun) #:transparent)

;; Problem A

;; CHANGE (put your solutions here)

(define (racketlist->mupllist lst)
  (cond [(null? lst) (aunit)]
        [(pair? (car lst)) (apair (racketlist->mupllist (car lst)) (racketlist->mupllist (cdr lst)))]
        [#t (apair (car lst) (racketlist->mupllist (cdr lst)))]
))


(define (mupllist->racketlist lst)
  (cond [(aunit? lst) null]
        [(apair? (apair-e1 lst)) (cons (mupllist->racketlist (apair-e1 lst)) (mupllist->racketlist (apair-e2 lst)))]
        [#t (cons (apair-e1 lst) (mupllist->racketlist (apair-e2 lst)))]
))


;; Problem B

;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; Do NOT change the two cases given to you.
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond [(var? e)
         (envlookup env (var-string e))]
        [(int? e) e]
        [(add? e)
         (let ([e1 (eval-under-env (add-e1 e) env)]
               [e2 (eval-under-env (add-e2 e) env)])
           (if (and (int? e1)
                    (int? e2))
               (int (+ (int-num e1)
                       (int-num e2)))
               (error "MUPL addition applied to a non-number")))]
        [(ifgreater? e)
         (let ([e1 (eval-under-env (ifgreater-e1 e) env)]
               [e2 (eval-under-env (ifgreater-e2 e) env)])
           (if (and (int? e1)
                    (int? e2))
               (if (> (int-num e1)
                      (int-num e2))
                   (eval-under-env (ifgreater-e3 e) env)
                   (eval-under-env (ifgreater-e4 e) env))
               (error "MUPL isgreater applied to a non-number")))]
        [(fun? e) (closure env e)]
        [(closure? e) e]
        [(call? e)
         (let ([closr (eval-under-env (call-funexp e) env)]
               [actual (eval-under-env (call-actual e) env)])
           (if (closure? closr)
               (let* ([cenv (closure-env closr)]
                      [cfun (closure-fun closr)]
                      [nameopt (fun-nameopt cfun)]
                      [formal (fun-formal cfun)]
                      [body (fun-body cfun)])
                 (if (equal? nameopt #f)
                     (eval-under-env (mlet formal actual body) cenv)
                     (eval-under-env (mlet formal actual (mlet nameopt closr body)) cenv)))
               (error "MUPL call applied to a non-closure")))]
        [(mlet? e)
         (let ([var (mlet-var e)]
               [ex (eval-under-env (mlet-e e) env)]
               [body (mlet-body e)])
           (eval-under-env body (cons (cons var ex) env)))]
        [(apair? e)
         (let ([e1 (eval-under-env (apair-e1 e) env)]
               [e2 (eval-under-env (apair-e2 e) env)])
           (apair e1 e2))]
        [(fst? e)
         (let ([ex (eval-under-env (fst-e e) env)])
           (if (apair? ex)
               (apair-e1 ex)
               ((error "MUPL fst applied to a non-apair"))))]
        [(snd? e)
         (let ([ex (eval-under-env (snd-e e) env)])
           (if (apair? ex)
               (apair-e2 ex)
               ((error "MUPL snd applied to a non-apair"))))]
        [(aunit? e) e]
        [(isaunit? e)
         (let ([v1 (eval-under-env (isaunit-e e) env)])
              (if (aunit? v1) (int 1) (int 0)))]
        [#t (error (format "bad MUPL expression: ~v" e))]))

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))
                               
;; Problem C

(define (ifaunit e1 e2 e3) (ifgreater (isaunit e1) (int 0) e2 e3))

(define (mlet* lstlst e2) (if (null? lstlst)
                              e2
                              (let ([sym (car (car lstlst))]
                                    [ex (cdr (car lstlst))]
                                    [rest (cdr lstlst)])
                                (mlet sym ex (mlet* rest e2)))))

(define (ifeq e1 e2 e3 e4) (ifgreater e1 e2
                                      e4
                                      (ifgreater e2 e1
                                                 e4
                                                 e3)))

;; Problem D

(define mupl-map "CHANGE")
;; this binding is a bit tricky. it must return a function.
;; the first two lines should be something like this:
;;
;;   (fun "mupl-map" "f"    ;; it is  function "mupl-map" that takes a function f
;;       (fun #f "lst"      ;; and it returns an anonymous function
;;          ...
;;
;; also remember that we can only call functions with one parameter, but
;; because they are curried instead of
;;    (call funexp1 funexp2 exp3)
;; we do
;;    (call (call funexp1 funexp2) exp3)
;; 

(define mupl-mapAddN
  (mlet "map" mupl-map
        "CHANGE (notice map is now in MUPL scope)"))

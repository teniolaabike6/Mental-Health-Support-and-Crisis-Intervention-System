;; Mental Health Screening Contract

;; Define possible error codes
(define-constant ERR-INVALID-INPUT (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))

;; Define a data variable to store the screening result
(define-data-var screening-result (optional (tuple (phq9-score uint) (gad7-score uint))) none)

;; Public function to submit screening data
(define-public (submit-screening
    (phq9-q1 uint) (phq9-q2 uint) (phq9-q3 uint) (phq9-q4 uint) (phq9-q5 uint)
    (phq9-q6 uint) (phq9-q7 uint) (phq9-q8 uint) (phq9-q9 uint)
    (gad7-q1 uint) (gad7-q2 uint) (gad7-q3 uint) (gad7-q4 uint)
    (gad7-q5 uint) (gad7-q6 uint) (gad7-q7 uint))
  (begin
    ;; Validate input scores
    (asserts! (and (<= phq9-q1 u3) (<= phq9-q2 u3) (<= phq9-q3 u3) (<= phq9-q4 u3) (<= phq9-q5 u3)
                   (<= phq9-q6 u3) (<= phq9-q7 u3) (<= phq9-q8 u3) (<= phq9-q9 u3)) ERR-INVALID-INPUT)
    (asserts! (and (<= gad7-q1 u3) (<= gad7-q2 u3) (<= gad7-q3 u3) (<= gad7-q4 u3)
                   (<= gad7-q5 u3) (<= gad7-q6 u3) (<= gad7-q7 u3)) ERR-INVALID-INPUT)

    ;; Calculate total scores
    (let ((phq9-total (+ phq9-q1 phq9-q2 phq9-q3 phq9-q4 phq9-q5 phq9-q6 phq9-q7 phq9-q8 phq9-q9))
          (gad7-total (+ gad7-q1 gad7-q2 gad7-q3 gad7-q4 gad7-q5 gad7-q6 gad7-q7)))

      ;; Store the screening result
      (var-set screening-result (some (tuple (phq9-score phq9-total) (gad7-score gad7-total))))

      (ok true))))

;; Read-only function to get the screening result
(define-read-only (get-screening-result)
  (var-get screening-result))

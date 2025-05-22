;; Anonymization Contract
;; This contract manages the process of removing identifying information

(define-data-var admin principal tx-sender)

;; Map to track anonymized data
(define-map anonymized-data
  { original-hash: (buff 32) }
  { anonymized-hash: (buff 32),
    anonymization-method: (string-utf8 100),
    timestamp: uint })

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-already-anonymized (err u101))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Register anonymized data
(define-public (register-anonymized-data
                (original-hash (buff 32))
                (anonymized-hash (buff 32))
                (anonymization-method (string-utf8 100)))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-none (map-get? anonymized-data { original-hash: original-hash })) err-already-anonymized)
    (ok (map-set anonymized-data
                { original-hash: original-hash }
                { anonymized-hash: anonymized-hash,
                  anonymization-method: anonymization-method,
                  timestamp: block-height }))))

;; Verify if data has been anonymized
(define-read-only (is-anonymized (original-hash (buff 32)))
  (is-some (map-get? anonymized-data { original-hash: original-hash })))

;; Get anonymization details
(define-read-only (get-anonymization-details (original-hash (buff 32)))
  (map-get? anonymized-data { original-hash: original-hash }))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))

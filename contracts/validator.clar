;; Validator Contract

;; Define data structures
(define-map validators
  { validator-id: principal }
  { stake: uint, is-active: bool }
)

(define-map verified-transactions
  { transfer-id: uint }
  { is-verified: bool }
)

;; Error codes
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u403))

;; Register validator
(define-public (register-validator (stake uint))
  (let
    (
      (validator-info (default-to { stake: u0, is-active: false } (map-get? validators { validator-id: tx-sender })))
    )
    (map-set validators
      { validator-id: tx-sender }
      { stake: (+ (get stake validator-info) stake), is-active: true }
    )
    (ok true)
  )
)

;; Verify transaction
(define-public (verify-transaction (transfer-id uint))
  (let
    (
      (validator-info (unwrap! (map-get? validators { validator-id: tx-sender }) err-unauthorized))
    )
    (asserts! (get is-active validator-info) err-unauthorized)
    (map-set verified-transactions
      { transfer-id: transfer-id }
      { is-verified: true }
    )
    (ok true)
  )
)

;; Check if transaction is verified
(define-read-only (is-transaction-verified (transfer-id uint))
  (default-to
    { is-verified: false }
    (map-get? verified-transactions { transfer-id: transfer-id })
  )
)

;; Get validator info
(define-read-only (get-validator-info (validator-id principal))
  (map-get? validators { validator-id: validator-id })
)


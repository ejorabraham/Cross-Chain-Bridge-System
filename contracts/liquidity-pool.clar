;; Liquidity Pool Contract

;; Define fungible token for liquidity
(define-fungible-token liquidity-token)

;; Define data structures
(define-map pools
  { asset-id: uint }
  { balance: uint }
)

;; Error codes
(define-constant err-insufficient-liquidity (err u100))

;; Add liquidity
(define-public (add-liquidity (asset-id uint) (amount uint))
  (let
    (
      (pool (default-to { balance: u0 } (map-get? pools { asset-id: asset-id })))
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set pools
      { asset-id: asset-id }
      { balance: (+ (get balance pool) amount) }
    )
    (ft-mint? liquidity-token amount tx-sender)
  )
)

;; Remove liquidity
(define-public (remove-liquidity (asset-id uint) (amount uint))
  (let
    (
      (pool (unwrap! (map-get? pools { asset-id: asset-id }) err-insufficient-liquidity))
    )
    (asserts! (<= amount (get balance pool)) err-insufficient-liquidity)
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (map-set pools
      { asset-id: asset-id }
      { balance: (- (get balance pool) amount) }
    )
    (ft-burn? liquidity-token amount tx-sender)
  )
)

;; Get pool balance
(define-read-only (get-pool-balance (asset-id uint))
  (default-to { balance: u0 } (map-get? pools { asset-id: asset-id }))
)


;; Governance Contract

;; Define data structures
(define-map proposals
  { proposal-id: uint }
  { description: (string-ascii 256), votes-for: uint, votes-against: uint, is-active: bool }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { amount: uint }
)

(define-data-var next-proposal-id uint u0)

;; Error codes
(define-constant err-proposal-not-found (err u404))
(define-constant err-proposal-not-active (err u400))

;; Create proposal
(define-public (create-proposal (description (string-ascii 256)))
  (let
    (
      (proposal-id (var-get next-proposal-id))
    )
    (map-set proposals
      { proposal-id: proposal-id }
      { description: description, votes-for: u0, votes-against: u0, is-active: true }
    )
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

;; Vote on proposal
(define-public (vote (proposal-id uint) (vote-for bool) (amount uint))
  (let
    (
      (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) err-proposal-not-found))
    )
    (asserts! (get is-active proposal) err-proposal-not-active)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set votes
      { proposal-id: proposal-id, voter: tx-sender }
      { amount: amount }
    )
    (if vote-for
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-for: (+ (get votes-for proposal) amount) })
      )
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-against: (+ (get votes-against proposal) amount) })
      )
    )
    (ok true)
  )
)

;; Get proposal details
(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id })
)

;; Get vote details
(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)


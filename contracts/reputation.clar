;; Reputation Contract

(define-map reputation-scores
  { did: (string-ascii 64) }
  { score: int }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))

(define-public (update-reputation (did (string-ascii 64)) (change int))
  (let
    (
      (current-score (default-to { score: 0 } (map-get? reputation-scores { did: did })))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set reputation-scores
      { did: did }
      { score: (+ (get score current-score) change) }
    )
    (ok true)
  )
)

(define-read-only (get-reputation (did (string-ascii 64)))
  (default-to { score: 0 } (map-get? reputation-scores { did: did }))
)


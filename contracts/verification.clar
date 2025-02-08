;; Verification Contract

(define-map verifications
  { verification-id: uint }
  {
    verifier: principal,
    credential-hash: (buff 32),
    result: bool,
    timestamp: uint
  }
)

(define-data-var verification-nonce uint u0)

(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

(define-public (verify-credential (credential-hash (buff 32)))
  (let
    (
      (verifier tx-sender)
      (verification-id (+ (var-get verification-nonce) u1))
    )
    (map-set verifications
      { verification-id: verification-id }
      {
        verifier: verifier,
        credential-hash: credential-hash,
        result: true,
        timestamp: block-height
      }
    )
    (var-set verification-nonce verification-id)
    (ok verification-id)
  )
)

(define-read-only (get-verification (verification-id uint))
  (map-get? verifications { verification-id: verification-id })
)


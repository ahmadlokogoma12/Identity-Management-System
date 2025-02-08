;; Credential Issuance Contract

(define-map credentials
  { credential-id: uint }
  {
    issuer: principal,
    holder: (string-ascii 64),
    type: (string-ascii 64),
    data: (string-utf8 1024),
    issued-at: uint,
    expiration: uint
  }
)

(define-map credential-types
  { type: (string-ascii 64) }
  { issuer: principal }
)

(define-data-var credential-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

(define-public (register-credential-type (type (string-ascii 64)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set credential-types
      { type: type }
      { issuer: tx-sender }
    )
    (ok true)
  )
)

(define-public (issue-credential (holder (string-ascii 64)) (type (string-ascii 64)) (data (string-utf8 1024)) (expiration uint))
  (let
    (
      (issuer tx-sender)
      (credential-type (unwrap! (map-get? credential-types { type: type }) ERR_NOT_FOUND))
      (credential-id (+ (var-get credential-nonce) u1))
    )
    (asserts! (is-eq issuer (get issuer credential-type)) ERR_UNAUTHORIZED)
    (map-set credentials
      { credential-id: credential-id }
      {
        issuer: issuer,
        holder: holder,
        type: type,
        data: data,
        issued-at: block-height,
        expiration: expiration
      }
    )
    (var-set credential-nonce credential-id)
    (ok credential-id)
  )
)

(define-read-only (get-credential (credential-id uint))
  (map-get? credentials { credential-id: credential-id })
)


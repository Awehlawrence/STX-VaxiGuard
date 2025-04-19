;; Vaccine Tracking Smart Contract
;; Contract Owner Management
(define-data-var vaccine-contract-owner principal tx-sender)

;; Error Codes
(define-constant ERROR-NOT-AUTHORIZED (err u100))
(define-constant ERROR-INVALID-BATCH (err u101))
(define-constant ERROR-BATCH-EXISTS (err u102))
(define-constant ERROR-BATCH-NOT-FOUND (err u103))
(define-constant ERROR-INSUFFICIENT-VACCINE-QUANTITY (err u104))
(define-constant ERROR-INVALID-PATIENT-ID (err u105))
(define-constant ERROR-PATIENT-ALREADY-VACCINATED (err u106))
(define-constant ERROR-TEMPERATURE-OUT-OF-RANGE (err u107))
(define-constant ERROR-VACCINE-BATCH-EXPIRED (err u108))
(define-constant ERROR-INVALID-VACCINATION-LOCATION (err u109))
(define-constant ERROR-MAXIMUM-DOSES-REACHED (err u110))
(define-constant ERROR-MINIMUM-DOSE-INTERVAL-NOT-MET (err u111))
(define-constant ERROR-CONTRACT-OWNER-ONLY (err u112))
(define-constant ERROR-INVALID-INPUT (err u113))
(define-constant ERROR-INVALID-EXPIRY-DATE (err u114))
(define-constant ERROR-INVALID-STORAGE-CAPACITY (err u115))

;; Constants
(define-constant MINIMUM-STORAGE-TEMPERATURE (- 70))
(define-constant MAXIMUM_STORAGE_TEMPERATURE 8)
(define-constant MINIMUM-DAYS-BETWEEN-DOSES u21) ;; 21 days minimum between doses
(define-constant MAXIMUM-DOSES-PER-PATIENT u4)
(define-constant MINIMUM_STRING_LENGTH u1)
(define-constant CURRENT_BLOCK stacks-block-height)

;; Data Maps
(define-map vaccine-batches
    { vaccine-batch-id: (string-ascii 32) }
    {
        vaccine-manufacturer: (string-ascii 50),
        vaccine-name: (string-ascii 50),
        manufacturing-date: uint,
        batch-expiry-date: uint,
        available-doses: uint,
        storage-temperature: int,
        batch-status: (string-ascii 20),
        temperature-breach-count: uint,
        storage-facility: (string-ascii 100),
        additional-batch-notes: (string-ascii 500)
    }
)

(define-map patient-vaccination-records
    { patient-identifier: (string-ascii 32) }
    {
        vaccination-history: (list 10 {
            vaccine-batch-id: (string-ascii 32),
            administration-date: uint,
            vaccine-type: (string-ascii 50),
            dose-sequence-number: uint,
            healthcare-provider: principal,
            vaccination-site: (string-ascii 100),
            next-vaccination-date: (optional uint)
        }),
        completed-doses: uint,
        reported-side-effects: (list 5 (string-ascii 200)),
        vaccination-exemption-reason: (optional (string-ascii 200))
    }
)

(define-map healthcare-providers 
    principal 
    {
        provider-role: (string-ascii 20),
        healthcare-facility: (string-ascii 100),
        credentials-expiry-date: uint
    }
)

(define-map vaccine-storage-facilities
    (string-ascii 100)
    {
        facility-address: (string-ascii 200),
        maximum-storage-capacity: uint,
        current-inventory: uint,
        facility-temperature-history: (list 100 {
            reading-timestamp: uint,
            recorded-temperature: int
        })
    }
)

;; Private Functions
(define-private (is-vaccine-contract-owner)
    (is-eq tx-sender (var-get vaccine-contract-owner))
)

;; Updated validate-string functions for different string lengths
(define-private (validate-string-32 (input (string-ascii 32)))
    (> (len input) MINIMUM_STRING_LENGTH)
)

(define-private (validate-string-50 (input (string-ascii 50)))
    (> (len input) MINIMUM_STRING_LENGTH)
)

(define-private (validate-string-100 (input (string-ascii 100)))
    (> (len input) MINIMUM_STRING_LENGTH)
)

(define-private (validate-string-200 (input (string-ascii 200)))
    (> (len input) MINIMUM_STRING_LENGTH)
)

(define-private (validate-future-date (date uint))
    (> date CURRENT_BLOCK)
)

(define-private (validate-storage-capacity (capacity uint))
    (> capacity u0)
)

;; Read-only Functions
(define-read-only (get-vaccine-contract-owner)
    (ok (var-get vaccine-contract-owner))
)

(define-read-only (is-provider-authorized (provider-address principal))
    (match (map-get? healthcare-providers provider-address)
        provider-info (>= (get credentials-expiry-date provider-info) CURRENT_BLOCK)
        false
    )
)

;; Public Functions
(define-public (transfer-contract-ownership (new-contract-owner principal))
    (begin
        (asserts! (is-vaccine-contract-owner) ERROR-CONTRACT-OWNER-ONLY)
        (ok (var-set vaccine-contract-owner new-contract-owner))
    )
)

(define-public (register-healthcare-provider 
    (provider-address principal)
    (provider-role (string-ascii 20))
    (healthcare-facility (string-ascii 100))
    (credentials-expiry-date uint))
    (begin
        (asserts! (is-vaccine-contract-owner) ERROR-NOT-AUTHORIZED)
        (asserts! (validate-string-20 provider-role) ERROR-INVALID-INPUT)
        (asserts! (validate-string-100 healthcare-facility) ERROR-INVALID-INPUT)
        (asserts! (validate-future-date credentials-expiry-date) ERROR-INVALID-EXPIRY-DATE)
        (ok (map-set healthcare-providers 
            provider-address 
            {
                provider-role: provider-role,
                healthcare-facility: healthcare-facility,
                credentials-expiry-date: credentials-expiry-date
            }))
    )
)

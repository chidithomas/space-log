;; Space Mission Logs Contract
;; Record satellite and space probe data on-chain

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var mission-counter uint u0)

;; Data Maps
(define-map missions
    uint
    {
        mission-name: (string-ascii 50),
        spacecraft-id: (string-ascii 30),
        mission-type: (string-ascii 20),
        launch-date: uint,
        status: (string-ascii 20),
        operator: principal,
        created-at: uint
    }
)

(define-map mission-logs
    {mission-id: uint, log-id: uint}
    {
        timestamp: uint,
        telemetry-data: (string-ascii 200),
        latitude: int,
        longitude: int,
        altitude: uint,
        speed: uint,
        temperature: int,
        logged-by: principal
    }
)

(define-map mission-log-counter
    uint
    uint
)

(define-map mission-operators
    {mission-id: uint, operator: principal}
    bool
)

;; Read-only functions

(define-read-only (get-mission (mission-id uint))
    (map-get? missions mission-id)
)

(define-read-only (get-mission-log (mission-id uint) (log-id uint))
    (map-get? mission-logs {mission-id: mission-id, log-id: log-id})
)

(define-read-only (get-mission-log-count (mission-id uint))
    (default-to u0 (map-get? mission-log-counter mission-id))
)

(define-read-only (get-total-missions)
    (var-get mission-counter)
)

(define-read-only (is-mission-operator (mission-id uint) (operator principal))
    (default-to false (map-get? mission-operators {mission-id: mission-id, operator: operator}))
)

;; Public functions

(define-public (create-mission
    (mission-name (string-ascii 50))
    (spacecraft-id (string-ascii 30))
    (mission-type (string-ascii 20))
    (launch-date uint)
    (status (string-ascii 20)))
    (let
        (
            (new-mission-id (+ (var-get mission-counter) u1))
        )
        (map-set missions new-mission-id
            {
                mission-name: mission-name,
                spacecraft-id: spacecraft-id,
                mission-type: mission-type,
                launch-date: launch-date,
                status: status,
                operator: tx-sender,
                created-at: block-height
            }
        )
        (map-set mission-operators {mission-id: new-mission-id, operator: tx-sender} true)
        (map-set mission-log-counter new-mission-id u0)
        (var-set mission-counter new-mission-id)
        (ok new-mission-id)
    )
)

(define-public (add-mission-log
    (mission-id uint)
    (telemetry-data (string-ascii 200))
    (latitude int)
    (longitude int)
    (altitude uint)
    (speed uint)
    (temperature int))
    (let
        (
            (mission (unwrap! (map-get? missions mission-id) err-not-found))
            (current-log-count (default-to u0 (map-get? mission-log-counter mission-id)))
            (new-log-id (+ current-log-count u1))
        )
        ;; Check if caller is authorized operator
        (asserts! (is-mission-operator mission-id tx-sender) err-unauthorized)

        (map-set mission-logs {mission-id: mission-id, log-id: new-log-id}
            {
                timestamp: block-height,
                telemetry-data: telemetry-data,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                speed: speed,
                temperature: temperature,
                logged-by: tx-sender
            }
        )
        (map-set mission-log-counter mission-id new-log-id)
        (ok new-log-id)
    )
)

(define-public (update-mission-status
    (mission-id uint)
    (new-status (string-ascii 20)))
    (let
        (
            (mission (unwrap! (map-get? missions mission-id) err-not-found))
        )
        ;; Check if caller is authorized operator
        (asserts! (is-mission-operator mission-id tx-sender) err-unauthorized)

        (map-set missions mission-id
            (merge mission {status: new-status})
        )
        (ok true)
    )
)

(define-public (add-mission-operator
    (mission-id uint)
    (new-operator principal))
    (let
        (
            (mission (unwrap! (map-get? missions mission-id) err-not-found))
        )
        ;; Check if caller is the original operator
        (asserts! (is-eq tx-sender (get operator mission)) err-unauthorized)

        (map-set mission-operators {mission-id: mission-id, operator: new-operator} true)
        (ok true)
    )
)

(define-public (remove-mission-operator
    (mission-id uint)
    (operator-to-remove principal))
    (let
        (
            (mission (unwrap! (map-get? missions mission-id) err-not-found))
        )
        ;; Check if caller is the original operator
        (asserts! (is-eq tx-sender (get operator mission)) err-unauthorized)
        ;; Cannot remove the original operator
        (asserts! (not (is-eq operator-to-remove (get operator mission))) err-unauthorized)

        (map-delete mission-operators {mission-id: mission-id, operator: operator-to-remove})
        (ok true)
    )
)

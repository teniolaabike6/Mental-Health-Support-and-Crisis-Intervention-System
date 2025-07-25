;; Therapy Session Scheduling Contract
;; Manages therapy appointments and treatment tracking

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-INVALID-INPUT (err u301))
(define-constant ERR-SESSION-NOT-FOUND (err u302))
(define-constant ERR-THERAPIST-NOT-AVAILABLE (err u303))
(define-constant ERR-TIME-SLOT-TAKEN (err u304))

;; Data Variables
(define-data-var next-session-id uint u1)
(define-data-var total-sessions uint u0)
(define-data-var active-therapists uint u0)

;; Data Maps
(define-map therapy-sessions
  { session-id: uint }
  {
    patient-id: principal,
    therapist-id: principal,
    session-type: (string-ascii 50),
    scheduled-time: uint,
    duration-minutes: uint,
    status: (string-ascii 20),
    session-notes: (optional (string-ascii 1000)),
    outcome-rating: (optional uint),
    created-at: uint,
    completed-at: (optional uint)
  }
)

(define-map therapists
  { therapist-id: principal }
  {
    name: (string-ascii 100),
    specialization: (string-ascii 200),
    license-number: (string-ascii 50),
    available: bool,
    hourly-rate: uint,
    total-sessions: uint,
    rating: uint
  }
)

(define-map therapist-availability
  { therapist-id: principal, time-slot: uint }
  { available: bool }
)

(define-map patient-treatment-plans
  { patient-id: principal }
  {
    treatment-goals: (string-ascii 500),
    session-frequency: uint,
    total-sessions-planned: uint,
    sessions-completed: uint,
    last-session-date: (optional uint),
    next-session-id: (optional uint)
  }
)

;; Therapist Management
(define-public (register-therapist
  (therapist-id principal)
  (name (string-ascii 100))
  (specialization (string-ascii 200))
  (license-number (string-ascii 50))
  (hourly-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> hourly-rate u0) ERR-INVALID-INPUT)

    (map-set therapists
      { therapist-id: therapist-id }
      {
        name: name,
        specialization: specialization,
        license-number: license-number,
        available: true,
        hourly-rate: hourly-rate,
        total-sessions: u0,
        rating: u5
      }
    )

    (var-set active-therapists (+ (var-get active-therapists) u1))
    (ok true)
  )
)

(define-public (set-therapist-availability
  (time-slot uint)
  (available bool))
  (begin
    ;; Verify therapist is registered
    (asserts! (is-some (map-get? therapists { therapist-id: tx-sender })) ERR-NOT-AUTHORIZED)

    (map-set therapist-availability
      { therapist-id: tx-sender, time-slot: time-slot }
      { available: available }
    )
    (ok true)
  )
)

;; Session Booking
(define-public (book-session
  (therapist-id principal)
  (session-type (string-ascii 50))
  (scheduled-time uint)
  (duration-minutes uint))
  (let
    (
      (session-id (var-get next-session-id))
    )
    ;; Validate inputs
    (asserts! (> duration-minutes u0) ERR-INVALID-INPUT)
    (asserts! (> scheduled-time block-height) ERR-INVALID-INPUT)

    ;; Check therapist exists and is available
    (asserts! (is-some (map-get? therapists { therapist-id: therapist-id })) ERR-NOT-AUTHORIZED)
    (asserts! (is-therapist-available therapist-id scheduled-time) ERR-THERAPIST-NOT-AVAILABLE)

    ;; Create session
    (map-set therapy-sessions
      { session-id: session-id }
      {
        patient-id: tx-sender,
        therapist-id: therapist-id,
        session-type: session-type,
        scheduled-time: scheduled-time,
        duration-minutes: duration-minutes,
        status: "scheduled",
        session-notes: none,
        outcome-rating: none,
        created-at: block-height,
        completed-at: none
      }
    )

    ;; Mark time slot as taken
    (map-set therapist-availability
      { therapist-id: therapist-id, time-slot: scheduled-time }
      { available: false }
    )

    ;; Update treatment plan
    (update-treatment-plan tx-sender session-id)

    ;; Update counters
    (var-set next-session-id (+ session-id u1))
    (var-set total-sessions (+ (var-get total-sessions) u1))

    (ok session-id)
  )
)

;; Treatment Plan Management
(define-public (create-treatment-plan
  (treatment-goals (string-ascii 500))
  (session-frequency uint)
  (total-sessions-planned uint))
  (begin
    (asserts! (> session-frequency u0) ERR-INVALID-INPUT)
    (asserts! (> total-sessions-planned u0) ERR-INVALID-INPUT)

    (map-set patient-treatment-plans
      { patient-id: tx-sender }
      {
        treatment-goals: treatment-goals,
        session-frequency: session-frequency,
        total-sessions-planned: total-sessions-planned,
        sessions-completed: u0,
        last-session-date: none,
        next-session-id: none
      }
    )
    (ok true)
  )
)

(define-private (update-treatment-plan (patient-id principal) (session-id uint))
  (match (map-get? patient-treatment-plans { patient-id: patient-id })
    plan-data
    (map-set patient-treatment-plans
      { patient-id: patient-id }
      (merge plan-data { next-session-id: (some session-id) })
    )
    ;; Create basic treatment plan if none exists
    (map-set patient-treatment-plans
      { patient-id: patient-id }
      {
        treatment-goals: "General mental health support",
        session-frequency: u1,
        total-sessions-planned: u10,
        sessions-completed: u0,
        last-session-date: none,
        next-session-id: (some session-id)
      }
    )
  )
)

;; Session Management
(define-public (complete-session
  (session-id uint)
  (session-notes (string-ascii 1000))
  (outcome-rating uint))
  (match (map-get? therapy-sessions { session-id: session-id })
    session-data
    (begin
      (asserts! (is-eq tx-sender (get therapist-id session-data)) ERR-NOT-AUTHORIZED)
      (asserts! (<= outcome-rating u10) ERR-INVALID-INPUT)

      ;; Update session
      (map-set therapy-sessions
        { session-id: session-id }
        (merge session-data
          {
            status: "completed",
            session-notes: (some session-notes),
            outcome-rating: (some outcome-rating),
            completed-at: (some block-height)
          }
        )
      )

      ;; Update therapist stats
      (match (map-get? therapists { therapist-id: (get therapist-id session-data) })
        therapist-data
        (map-set therapists
          { therapist-id: (get therapist-id session-data) }
          (merge therapist-data
            { total-sessions: (+ (get total-sessions therapist-data) u1) }
          )
        )
        false
      )

      ;; Update treatment plan
      (match (map-get? patient-treatment-plans { patient-id: (get patient-id session-data) })
        plan-data
        (map-set patient-treatment-plans
          { patient-id: (get patient-id session-data) }
          (merge plan-data
            {
              sessions-completed: (+ (get sessions-completed plan-data) u1),
              last-session-date: (some block-height),
              next-session-id: none
            }
          )
        )
        false
      )

      (ok true)
    )
    ERR-SESSION-NOT-FOUND
  )
)

(define-public (cancel-session (session-id uint))
  (match (map-get? therapy-sessions { session-id: session-id })
    session-data
    (begin
      (asserts! (or (is-eq tx-sender (get patient-id session-data))
                    (is-eq tx-sender (get therapist-id session-data))) ERR-NOT-AUTHORIZED)

      ;; Update session status
      (map-set therapy-sessions
        { session-id: session-id }
        (merge session-data { status: "cancelled" })
      )

      ;; Free up the time slot
      (map-set therapist-availability
        { therapist-id: (get therapist-id session-data), time-slot: (get scheduled-time session-data) }
        { available: true }
      )

      (ok true)
    )
    ERR-SESSION-NOT-FOUND
  )
)

;; Query Functions
(define-read-only (get-session (session-id uint))
  (map-get? therapy-sessions { session-id: session-id })
)

(define-read-only (get-therapist-info (therapist-id principal))
  (map-get? therapists { therapist-id: therapist-id })
)

(define-read-only (get-treatment-plan (patient-id principal))
  (map-get? patient-treatment-plans { patient-id: patient-id })
)

(define-read-only (is-therapist-available (therapist-id principal) (time-slot uint))
  (default-to true (get available (map-get? therapist-availability { therapist-id: therapist-id, time-slot: time-slot })))
)

(define-read-only (get-total-sessions)
  (var-get total-sessions)
)

(define-read-only (get-active-therapists)
  (var-get active-therapists)
)

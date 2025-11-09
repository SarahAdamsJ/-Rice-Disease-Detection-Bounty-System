(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-INSUFFICIENT-FUNDS (err u104))
(define-constant ERR-ALREADY-VOTED (err u105))
(define-constant ERR-UNAUTHORIZED (err u106))
(define-constant ERR-REPORT-CLOSED (err u107))
(define-constant ERR-INVALID-STATUS (err u108))
(define-constant ERR-CONTRACT-PAUSED (err u109))
(define-constant ERR-APPEAL-FEE-REQUIRED (err u110))
(define-constant ERR-NOT-REJECTED (err u111))
(define-constant ERR-ALREADY-APPEALED (err u112))
(define-constant ERR-REPORT-EXPIRED (err u113))

(define-data-var next-report-id uint u1)
(define-data-var reward-amount uint u1000)
(define-data-var min-votes-required uint u3)
(define-data-var verification-threshold uint u70)
(define-data-var contract-paused bool false)
(define-data-var appeal-fee uint u100)
(define-data-var report-expiry-blocks uint u1440)

(define-map reports
  uint 
  {
    reporter: principal,
    location: (string-ascii 100),
    disease-type: (string-ascii 50),
    severity: uint,
    photo-hash: (string-ascii 64),
    timestamp: uint,
    status: (string-ascii 20),
    votes-for: uint,
    votes-against: uint,
    reward-claimed: bool,
    appealed: bool
  }
)

(define-map user-balances principal uint)

(define-map report-votes 
  {report-id: uint, voter: principal}
  bool
)

(define-map verified-reporters principal bool)

(define-map disease-stats
  (string-ascii 50)
  {
    total-reports: uint,
    verified-reports: uint,
    last-reported: uint
  }
)

(define-private (get-user-balance (user principal))
  (default-to u0 (map-get? user-balances user))
)

(define-private (set-user-balance (user principal) (amount uint))
  (map-set user-balances user amount)
)

(define-private (calculate-approval-rate (report-id uint))
  (match (map-get? reports report-id)
    report-data 
    (let ((total-votes (+ (get votes-for report-data) (get votes-against report-data))))
      (if (> total-votes u0)
        (* (/ (get votes-for report-data) total-votes) u100)
        u0))
    u0)
)

(define-private (is-report-verified (report-id uint))
  (let ((approval-rate (calculate-approval-rate report-id)))
    (>= approval-rate (var-get verification-threshold)))
)

(define-private (is-report-expired (report-id uint))
  (match (map-get? reports report-id)
    report-data
    (> (- stacks-block-height (get timestamp report-data)) (var-get report-expiry-blocks))
    false)
)

(define-private (update-disease-stats (disease-type (string-ascii 50)) (is-verified bool))
  (let ((current-stats (default-to {total-reports: u0, verified-reports: u0, last-reported: u0} 
                                  (map-get? disease-stats disease-type))))
    (map-set disease-stats disease-type {
      total-reports: (+ (get total-reports current-stats) u1),
      verified-reports: (if is-verified 
                         (+ (get verified-reports current-stats) u1)
                         (get verified-reports current-stats)),
      last-reported: stacks-block-height
    }))
)

(define-public (submit-report (location (string-ascii 100))
                              (disease-type (string-ascii 50))
                              (severity uint)
                              (photo-hash (string-ascii 64)))
   (let ((report-id (var-get next-report-id)))
     (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
     (asserts! (<= severity u10) ERR-INVALID-AMOUNT)
     (asserts! (> (len location) u0) ERR-INVALID-AMOUNT)
     (asserts! (> (len disease-type) u0) ERR-INVALID-AMOUNT)
     (asserts! (> (len photo-hash) u0) ERR-INVALID-AMOUNT)
    
    (map-set reports report-id {
      reporter: tx-sender,
      location: location,
      disease-type: disease-type,
      severity: severity,
      photo-hash: photo-hash,
      timestamp: stacks-block-height,
      status: "pending",
      votes-for: u0,
      votes-against: u0,
      reward-claimed: false,
      appealed: false
    })
    
    (var-set next-report-id (+ report-id u1))
    (update-disease-stats disease-type false)
    (ok report-id)
  )
)

(define-public (vote-on-report (report-id uint) (approve bool))
   (let ((report-data (unwrap! (map-get? reports report-id) ERR-NOT-FOUND))
         (vote-key {report-id: report-id, voter: tx-sender}))

     (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
     (asserts! (is-none (map-get? report-votes vote-key)) ERR-ALREADY-VOTED)
    (asserts! (is-eq (get status report-data) "pending") ERR-REPORT-CLOSED)
    (asserts! (not (is-eq (get reporter report-data) tx-sender)) ERR-UNAUTHORIZED)
    (asserts! (not (is-report-expired report-id)) ERR-REPORT-EXPIRED)
    
    (map-set report-votes vote-key approve)
    
    (if approve
      (map-set reports report-id (merge report-data {votes-for: (+ (get votes-for report-data) u1)}))
      (map-set reports report-id (merge report-data {votes-against: (+ (get votes-against report-data) u1)})))
    
    (match (map-get? reports report-id)
      updated-report
      (let ((total-votes (+ (get votes-for updated-report) (get votes-against updated-report))))
        (if (>= total-votes (var-get min-votes-required))
          (if (is-report-verified report-id)
            (begin
              (map-set reports report-id (merge updated-report {status: "verified"}))
              (update-disease-stats (get disease-type updated-report) true)
              (map-set verified-reporters (get reporter updated-report) true)
              (ok true))
            (begin
              (map-set reports report-id (merge updated-report {status: "rejected"}))
              (ok true)))
          (ok true)))
      ERR-NOT-FOUND)
  )
)

(define-public (claim-reward (report-id uint))
   (let ((report-data (unwrap! (map-get? reports report-id) ERR-NOT-FOUND)))
     (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
     (asserts! (is-eq (get reporter report-data) tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status report-data) "verified") ERR-INVALID-STATUS)
    (asserts! (not (get reward-claimed report-data)) ERR-ALREADY-EXISTS)
    
    (let ((current-balance (get-user-balance tx-sender))
          (reward (var-get reward-amount)))
      (set-user-balance tx-sender (+ current-balance reward))
      (map-set reports report-id (merge report-data {reward-claimed: true}))
      (ok reward)
    )
  )
)

(define-public (add-funds (amount uint))
   (begin
     (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
     (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (let ((current-balance (get-user-balance tx-sender)))
      (set-user-balance tx-sender (+ current-balance amount))
      (ok amount)
    )
  )
)

(define-public (withdraw-funds (amount uint))
   (let ((current-balance (get-user-balance tx-sender)))
     (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
     (asserts! (>= current-balance amount) ERR-INSUFFICIENT-FUNDS)
    (set-user-balance tx-sender (- current-balance amount))
    (ok amount)
  )
)

(define-public (set-reward-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (> new-amount u0) ERR-INVALID-AMOUNT)
    (var-set reward-amount new-amount)
    (ok new-amount)
  )
)

(define-public (set-min-votes (new-min uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (> new-min u0) ERR-INVALID-AMOUNT)
    (var-set min-votes-required new-min)
    (ok new-min)
  )
)

(define-public (pause-contract)
   (begin
     (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
     (var-set contract-paused true)
     (ok true)
   )
)

(define-public (unpause-contract)
   (begin
     (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
     (var-set contract-paused false)
     (ok true)
   )
)

(define-public (set-verification-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (<= new-threshold u100) ERR-INVALID-AMOUNT)
    (var-set verification-threshold new-threshold)
    (ok new-threshold)
  )
)

(define-read-only (get-report (report-id uint))
  (map-get? reports report-id)
)

(define-read-only (get-balance (user principal))
  (get-user-balance user)
)

(define-read-only (get-report-vote (report-id uint) (voter principal))
  (map-get? report-votes {report-id: report-id, voter: voter})
)

(define-read-only (is-verified-reporter (reporter principal))
  (default-to false (map-get? verified-reporters reporter))
)

(define-read-only (get-disease-statistics (disease-type (string-ascii 50)))
  (map-get? disease-stats disease-type)
)

(define-read-only (get-next-report-id)
  (var-get next-report-id)
)

(define-read-only (get-current-reward)
  (var-get reward-amount)
)

(define-read-only (get-verification-settings)
  {
    min-votes: (var-get min-votes-required),
    threshold: (var-get verification-threshold),
    reward: (var-get reward-amount)
  }
)

(define-read-only (get-contract-owner)
   CONTRACT-OWNER
)

(define-read-only (is-contract-paused)
    (var-get contract-paused)
)

(define-public (appeal-report (report-id uint))
  (let ((report-data (unwrap! (map-get? reports report-id) ERR-NOT-FOUND))
        (current-balance (get-user-balance tx-sender))
        (fee (var-get appeal-fee)))
    (asserts! (not (var-get contract-paused)) ERR-CONTRACT-PAUSED)
    (asserts! (is-eq (get reporter report-data) tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status report-data) "rejected") ERR-NOT-REJECTED)
    (asserts! (not (get appealed report-data)) ERR-ALREADY-APPEALED)
    (asserts! (>= current-balance fee) ERR-APPEAL-FEE-REQUIRED)
    (set-user-balance tx-sender (- current-balance fee))
    (map-set reports report-id (merge report-data {status: "pending", appealed: true, votes-for: u0, votes-against: u0}))
    (ok true)
  )
)

(define-public (set-appeal-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (> new-fee u0) ERR-INVALID-AMOUNT)
    (var-set appeal-fee new-fee)
    (ok new-fee)
  )
)

(define-public (set-report-expiry-blocks (new-expiry uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (> new-expiry u0) ERR-INVALID-AMOUNT)
    (var-set report-expiry-blocks new-expiry)
    (ok new-expiry)
  )
)

(define-read-only (get-appeal-fee)
  (var-get appeal-fee)
)

(define-read-only (get-report-expiry-blocks)
  (var-get report-expiry-blocks)
)

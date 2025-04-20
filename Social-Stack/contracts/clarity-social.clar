;; DecentraConnect: A Decentralized Social Network Platform
;; This smart contract enables a fully decentralized social media platform with user profiles,
;; content sharing, moderation features, and community governance.

;; Define the platform token
(define-fungible-token decentra-connect-token)

;; Define the contract administrator
(define-constant contract-admin tx-sender)

;; Error codes with descriptive names
(define-constant ERR-PROFILE-EXISTS u1)
(define-constant ERR-PROFILE-NOT-FOUND u3)
(define-constant ERR-TARGET-PROFILE-NOT-FOUND u4)
(define-constant ERR-FOLLOWING-LIMIT-REACHED u5)
(define-constant ERR-FOLLOWING-APPEND-FAILED u6)
(define-constant ERR-FOLLOWERS-APPEND-FAILED u7)
(define-constant ERR-COMMENT-APPEND-FAILED u9)
(define-constant ERR-POST-NOT-FOUND u10)
(define-constant ERR-USERNAME-EMPTY u11)
(define-constant ERR-CONTENT-EMPTY u12)
(define-constant ERR-POST-UNAVAILABLE u13)
(define-constant ERR-SELF-FOLLOW-PROHIBITED u14)
(define-constant ERR-COMMENT-CONTENT-EMPTY u15)
(define-constant ERR-COMMENT-POST-NOT-FOUND u16)
(define-constant ERR-BIO-INVALID u17)
(define-constant ERR-POST-FLAG-NOT-FOUND u18)
(define-constant ERR-COMMENT-FLAG-NOT-FOUND u19)
(define-constant ERR-ADMIN-PROFILE-NOT-FOUND u20)
(define-constant ERR-ADMIN-ACCESS-REQUIRED u21)
(define-constant ERR-REMOVAL-POST-NOT-FOUND u22)
(define-constant ERR-ADMIN-COMMENT-NOT-FOUND u23)
(define-constant ERR-ADMIN-PRIVILEGES-REQUIRED u24)
(define-constant ERR-REMOVAL-COMMENT-NOT-FOUND u25)
(define-constant ERR-OWNER-ACCESS-REQUIRED u26)
(define-constant ERR-ADMIN-USER-NOT-FOUND u27)
(define-constant ERR-OWNER-PRIVILEGES-REQUIRED u28)
(define-constant ERR-REMOVE-ADMIN-NOT-FOUND u29)
(define-constant ERR-USER-NOT-ADMIN u36)

;; User profile data structure
(define-map user-data principal
    {
        display-name: (string-utf8 30),
        profile-description: (string-utf8 160),
        user-posts: (list 100 uint),
        user-followers: (list 1000 principal),
        user-following: (list 1000 principal),
        account-balance: uint,
        admin-status: bool
    })

;; Post data structure
(define-map content-posts uint 
    {
        creator: principal,
        post-text: (string-utf8 280),
        creation-time: uint,
        appreciation-count: uint,
        post-comments: (list 100 uint),
        moderation-flag: bool,
        report-count: uint
    })

;; Post ID tracker
(define-data-var next-post-id uint u0)

;; Comment data structure
(define-map content-comments uint 
    {
        creator: principal,
        parent-post-id: uint,
        comment-text: (string-utf8 280),
        creation-time: uint,
        moderation-flag: bool,
        report-count: uint
    })

;; Comment ID tracker
(define-data-var next-comment-id uint u0)

;; ========== USER MANAGEMENT FUNCTIONS ==========

;; Register a new user profile
(define-public (register-user-profile (display-name (string-utf8 30)) (profile-description (string-utf8 160)))
    (let ((current-user tx-sender))
        (asserts! (is-none (map-get? user-data current-user)) (err ERR-PROFILE-EXISTS))
        (asserts! (>= (len display-name) u1) (err ERR-USERNAME-EMPTY))
        (asserts! (>= (len profile-description) u0) (err ERR-BIO-INVALID))
        (ok (map-set user-data current-user {
            display-name: display-name,
            profile-description: profile-description,
            user-posts: (list),
            user-followers: (list),
            user-following: (list),
            account-balance: u0,
            admin-status: false
        }))
    )
)

;; Retrieve user profile information
(define-read-only (get-user-profile (user-address principal))
    (map-get? user-data user-address)
)

;; Follow another user
(define-public (follow-user-account (target-user principal))
    (let (
        (current-user tx-sender)
        (current-user-profile (unwrap! (map-get? user-data current-user) (err ERR-PROFILE-NOT-FOUND)))
        (target-user-profile (unwrap! (map-get? user-data target-user) (err ERR-TARGET-PROFILE-NOT-FOUND)))
    )
        (asserts! (not (is-eq current-user target-user)) (err ERR-SELF-FOLLOW-PROHIBITED))
        (asserts! (< (len (get user-following current-user-profile)) u1000) (err ERR-FOLLOWING-LIMIT-REACHED))
        (let (
            (updated-following (unwrap! (as-max-len? (append (get user-following current-user-profile) target-user) u1000) (err ERR-FOLLOWING-APPEND-FAILED)))
            (updated-followers (unwrap! (as-max-len? (append (get user-followers target-user-profile) current-user) u1000) (err ERR-FOLLOWERS-APPEND-FAILED)))
        )
            (map-set user-data current-user (merge current-user-profile {user-following: updated-following}))
            (ok (map-set user-data target-user (merge target-user-profile {user-followers: updated-followers})))
        )
    )
)

;; ========== CONTENT MANAGEMENT FUNCTIONS ==========

;; Create a new post
(define-public (publish-new-post (post-text (string-utf8 280)))
    (let (
        (current-user tx-sender)
        (post-id (+ (var-get next-post-id) u1))
    )
        (asserts! (>= (len post-text) u1) (err ERR-CONTENT-EMPTY))
        (var-set next-post-id post-id)
        (ok (map-set content-posts post-id {
            creator: current-user,
            post-text: post-text,
            creation-time: block-height,
            appreciation-count: u0,
            post-comments: (list),
            moderation-flag: false,
            report-count: u0
        }))
    )
)

;; Add like/appreciation to a post
(define-public (appreciate-post (post-id uint))
    (match (map-get? content-posts post-id)
        post (ok (map-set content-posts post-id (merge post {appreciation-count: (+ (get appreciation-count post) u1)})))
        (err ERR-POST-UNAVAILABLE)
    )
)

;; Get post details
(define-read-only (get-post-details (post-id uint))
    (map-get? content-posts post-id)
)

;; Add a comment to a post
(define-public (create-post-comment (post-id uint) (comment-text (string-utf8 280)))
    (let (
        (current-user tx-sender)
        (comment-id (+ (var-get next-comment-id) u1))
    )
        (asserts! (>= (len comment-text) u1) (err ERR-COMMENT-CONTENT-EMPTY))
        (match (map-get? content-posts post-id)
            post (begin
                (var-set next-comment-id comment-id)
                (map-set content-comments comment-id {
                    creator: current-user,
                    parent-post-id: post-id,
                    comment-text: comment-text,
                    creation-time: block-height,
                    moderation-flag: false,
                    report-count: u0
                })
                (let ((updated-comments (unwrap! (as-max-len? (append (get post-comments post) comment-id) u100) (err ERR-COMMENT-APPEND-FAILED))))
                    (ok (map-set content-posts post-id (merge post {post-comments: updated-comments})))
                )
            )
            (err ERR-COMMENT-POST-NOT-FOUND)
        )
    )
)

;; Get comment details
(define-read-only (get-comment-details (comment-id uint))
    (map-get? content-comments comment-id)
)

;; Get all comments for a specific post
(define-read-only (get-all-post-comments (post-id uint))
    (match (map-get? content-posts post-id)
        post (ok (map get-comment-details (get post-comments post)))
        (err ERR-POST-NOT-FOUND)
    )
)

;; ========== MODERATION FUNCTIONS ==========

;; Report/flag a post
(define-public (report-inappropriate-post (post-id uint))
    (match (map-get? content-posts post-id)
        post (let (
            (updated-report-count (+ (get report-count post) u1))
            (updated-post (merge post {
                report-count: updated-report-count,
                moderation-flag: (> updated-report-count u5)
            }))
        )
            (ok (map-set content-posts post-id updated-post))
        )
        (err ERR-POST-FLAG-NOT-FOUND)
    )
)

;; Report/flag a comment
(define-public (report-inappropriate-comment (comment-id uint))
    (match (map-get? content-comments comment-id)
        comment (let (
            (updated-report-count (+ (get report-count comment) u1))
            (updated-comment (merge comment {
                report-count: updated-report-count,
                moderation-flag: (> updated-report-count u5)
            }))
        )
            (ok (map-set content-comments comment-id updated-comment))
        )
        (err ERR-COMMENT-FLAG-NOT-FOUND)
    )
)

;; ========== ADMIN FUNCTIONS ==========

;; Remove a flagged post (admin only)
(define-public (moderate-flagged-post (post-id uint))
    (let (
        (current-user tx-sender)
        (admin-profile (unwrap! (map-get? user-data current-user) (err ERR-ADMIN-PROFILE-NOT-FOUND)))
    )
        (asserts! (get admin-status admin-profile) (err ERR-ADMIN-ACCESS-REQUIRED))
        (match (map-get? content-posts post-id)
            post (begin
                (map-delete content-posts post-id)
                (ok true)
            )
            (err ERR-REMOVAL-POST-NOT-FOUND)
        )
    )
)

;; Remove a flagged comment (admin only)
(define-public (moderate-flagged-comment (comment-id uint))
    (let (
        (current-user tx-sender)
        (admin-profile (unwrap! (map-get? user-data current-user) (err ERR-ADMIN-COMMENT-NOT-FOUND)))
    )
        (asserts! (get admin-status admin-profile) (err ERR-ADMIN-PRIVILEGES-REQUIRED))
        (match (map-get? content-comments comment-id)
            comment (begin
                (map-delete content-comments comment-id)
                (ok true)
            )
            (err ERR-REMOVAL-COMMENT-NOT-FOUND)
        )
    )
)

;; Grant admin privileges to a user (only contract admin can do this)
(define-public (grant-admin-privileges (user-address principal))
    (let (
        (current-user tx-sender)
    )
        (asserts! (is-eq current-user contract-admin) (err ERR-OWNER-ACCESS-REQUIRED))
        (match (map-get? user-data user-address)
            profile (ok (map-set user-data user-address (merge profile {admin-status: true})))
            (err ERR-ADMIN-USER-NOT-FOUND)
        )
    )
)

;; Revoke admin privileges from a user (only contract admin can do this)
(define-public (revoke-admin-privileges (user-address principal))
    (let (
        (current-user tx-sender)
    )
        (asserts! (is-eq current-user contract-admin) (err ERR-OWNER-PRIVILEGES-REQUIRED))
        (match (map-get? user-data user-address)
            profile (begin
                (asserts! (get admin-status profile) (err ERR-USER-NOT-ADMIN))
                (ok (map-set user-data user-address (merge profile {admin-status: false})))
            )
            (err ERR-REMOVE-ADMIN-NOT-FOUND)
        )
    )
)

;; Check if a user has admin privileges
(define-read-only (check-admin-status (user-address principal))
    (match (map-get? user-data user-address)
        profile (get admin-status profile)
        false
    )
)
# DecentraConnect Smart Contract Documentation

## Overview

DecentraConnect is a fully decentralized social network platform built on the Stacks blockchain. This smart contract enables censorship-resistant social networking with the following core capabilities:

- User profile creation and management
- Content publishing and engagement
- Community-driven moderation
- Decentralized governance

## Features

### User Management
- Create personalized profiles with custom display names and descriptions
- Follow other users to build a network (up to 1000 connections)
- View user profiles, followers, and following relationships

### Content Creation
- Publish posts (up to 280 characters)
- Comment on posts from any user
- Show appreciation for content through likes
- View content engagement metrics

### Moderation System
- Community-based content flagging
- Automatic flagging threshold (content is flagged after 5 reports)
- Admin-level content moderation for policy violations
- Transparent moderation actions

### Administration
- Decentralized admin privileges system
- Contract owner can grant/revoke admin status
- Admins can moderate flagged content

## Smart Contract Functions

### User Profile Management
- `register-user-profile`: Create a new user profile with custom name and bio
- `get-user-profile`: View profile information for any user
- `follow-user-account`: Follow another user to see their content

### Content Management
- `publish-new-post`: Create a new post on the platform
- `appreciate-post`: Like a post to show support
- `get-post-details`: View detailed information about a post
- `create-post-comment`: Comment on an existing post
- `get-comment-details`: View information about a specific comment
- `get-all-post-comments`: See all comments on a particular post

### Moderation System
- `report-inappropriate-post`: Flag a post that violates community standards
- `report-inappropriate-comment`: Flag an inappropriate comment
- `moderate-flagged-post`: Remove a flagged post (admin only)
- `moderate-flagged-comment`: Remove a flagged comment (admin only)

### Admin Functions
- `grant-admin-privileges`: Assign admin status to a user (contract owner only)
- `revoke-admin-privileges`: Remove admin status from a user (contract owner only)
- `check-admin-status`: Verify if a user has admin privileges

## Data Structures

### User Profile
```
{
    display-name: (string-utf8 30),
    profile-description: (string-utf8 160),
    user-posts: (list 100 uint),
    user-followers: (list 1000 principal),
    user-following: (list 1000 principal),
    account-balance: uint,
    admin-status: bool
}
```

### Post
```
{
    creator: principal,
    post-text: (string-utf8 280),
    creation-time: uint,
    appreciation-count: uint,
    post-comments: (list 100 uint),
    moderation-flag: bool,
    report-count: uint
}
```

### Comment
```
{
    creator: principal,
    parent-post-id: uint,
    comment-text: (string-utf8 280),
    creation-time: uint,
    moderation-flag: bool,
    report-count: uint
}
```

## Platform Token

DecentraConnect includes a fungible token system (`decentra-connect-token`) that can be used for:
- Rewarding content creators
- Incentivizing positive participation
- Future governance mechanisms

## Error Handling

The contract implements comprehensive error handling with descriptive error codes:

| Error Code | Description |
|------------|-------------|
| ERR-PROFILE-EXISTS | Attempt to create a duplicate profile |
| ERR-PROFILE-NOT-FOUND | Referenced profile does not exist |
| ERR-TARGET-PROFILE-NOT-FOUND | Target user profile not found when following |
| ERR-FOLLOWING-LIMIT-REACHED | Maximum following limit reached (1000) |
| ERR-FOLLOWING-APPEND-FAILED | Failed to append to following list |
| ERR-FOLLOWERS-APPEND-FAILED | Failed to append to followers list |
| ERR-COMMENT-APPEND-FAILED | Failed to append comment to post |
| ERR-POST-NOT-FOUND | Referenced post does not exist |
| ERR-USERNAME-EMPTY | Username cannot be empty |
| ERR-CONTENT-EMPTY | Attempt to create empty content |
| ERR-POST-UNAVAILABLE | Post is not available |
| ERR-SELF-FOLLOW-PROHIBITED | Users cannot follow themselves |
| ERR-COMMENT-CONTENT-EMPTY | Comment content cannot be empty |
| ERR-COMMENT-POST-NOT-FOUND | Post for comment not found |
| ERR-BIO-INVALID | Profile bio is invalid |
| ERR-POST-FLAG-NOT-FOUND | Post to flag not found |
| ERR-COMMENT-FLAG-NOT-FOUND | Comment to flag not found |
| ERR-ADMIN-PROFILE-NOT-FOUND | Admin profile not found |
| ERR-ADMIN-ACCESS-REQUIRED | Operation requires admin privileges |
| ERR-REMOVAL-POST-NOT-FOUND | Post for removal not found |
| ERR-ADMIN-COMMENT-NOT-FOUND | Admin for comment not found |
| ERR-ADMIN-PRIVILEGES-REQUIRED | Operation requires admin privileges |
| ERR-REMOVAL-COMMENT-NOT-FOUND | Comment for removal not found |
| ERR-OWNER-ACCESS-REQUIRED | Operation requires contract owner privileges |
| ERR-ADMIN-USER-NOT-FOUND | User to grant admin status not found |
| ERR-OWNER-PRIVILEGES-REQUIRED | Operation requires contract owner privileges |
| ERR-REMOVE-ADMIN-NOT-FOUND | Admin to remove not found |
| ERR-USER-NOT-ADMIN | User does not have admin status |

## Implementation Guidelines

### Deployment
1. Deploy the smart contract to the Stacks blockchain
2. The deploying address automatically becomes the contract administrator
3. The administrator can grant admin privileges to other users as needed

### Limitations
- Post content limited to 280 characters
- Bio description limited to 160 characters
- Display names limited to 30 characters
- Maximum 100 posts tracked per user profile
- Maximum 100 comments per post
- Maximum 1000 following/followers relationships

### Security Considerations
- User validation through blockchain transaction signatures
- Content moderation thresholds to prevent abuse
- Restricted admin privileges with owner oversight

## Getting Started

1. Deploy the contract to your Stacks blockchain environment
2. Register a user profile using the `register-user-profile` function
3. Start posting content and engaging with other users
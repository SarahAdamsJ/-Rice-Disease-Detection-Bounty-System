A decentralized bounty system for crowdsourced rice disease detection built on Stacks blockchain using Clarity smart contracts.

## 🎯 Problem & Solution

**Problem:** Crop diseases spread quickly because detection is slow and centralized.

**Solution:** A decentralized bounty system where anyone can submit verified disease outbreak reports with photo proof to earn tokens.

## ⭐ Key Features

- 🔍 **Crowdsourced Disease Reporting** - Submit disease reports with location, severity, and photo proof
- 🗳️ **Community Verification** - Democratic voting system to verify report authenticity  
- 🎁 **Token Rewards** - Earn tokens for verified disease reports
- 📊 **Disease Statistics** - Track disease patterns and outbreak trends
- 🏆 **Verified Reporter Status** - Build reputation through successful reports

## 🚀 How It Works

1. **Submit Report** 📝 - Users submit rice disease reports with photo evidence
2. **Community Votes** 🗳️ - Other users vote to verify or reject reports
3. **Automatic Verification** ✅ - Reports with sufficient positive votes get verified
4. **Claim Rewards** 💰 - Verified reporters claim token rewards
5. **Disease Tracking** 📈 - System tracks disease statistics for early warnings

## 💻 Usage Instructions

### Submit a Disease Report
```clarity
(contract-call? .Rice-Disease-Detection-Bounty-System submit-report 
  "Farm GPS: 14.5995° N, 120.9842° E" 
  "brown-spot" 
  u7 
  "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco")
```

### Vote on Reports
```clarity
;; Vote to approve a report
(contract-call? .Rice-Disease-Detection-Bounty-System vote-on-report u1 true)

;; Vote to reject a report  
(contract-call? .Rice-Disease-Detection-Bounty-System vote-on-report u1 false)
```

### Claim Rewards
```clarity
(contract-call? .Rice-Disease-Detection-Bounty-System claim-reward u1)
```

### Check Your Balance
```clarity
(contract-call? .Rice-Disease-Detection-Bounty-System get-balance tx-sender)
```

## 🛠️ Admin Functions

### Set Reward Amount
```clarity
(contract-call? .Rice-Disease-Detection-Bounty-System set-reward-amount u2000)
```

### Configure Verification Settings
```clarity
;; Set minimum votes required
(contract-call? .Rice-Disease-Detection-Bounty-System set-min-votes u5)

;; Set verification threshold (percentage)
(contract-call? .Rice-Disease-Detection-Bounty-System set-verification-threshold u75)
```

## 📖 Read-Only Functions

- `get-report` - Get report details by ID
- `get-balance` - Check user's token balance
- `get-disease-statistics` - View disease outbreak statistics
- `is-verified-reporter` - Check if user is a verified reporter
- `get-verification-settings` - View current system settings

## 🏗️ Contract Structure

### Data Maps
- **reports** - Stores all disease reports with metadata
- **user-balances** - Tracks token balances for users
- **report-votes** - Records community votes on reports
- **verified-reporters** - Maintains list of trusted reporters
- **disease-stats** - Aggregates disease outbreak statistics

### Key Constants
- **Reward Amount**: 1000 tokens (configurable)
- **Min Votes Required**: 3 votes (configurable)
- **Verification Threshold**: 70% approval (configurable)

## 🔒 Security Features

- Owner-only admin functions
- Duplicate vote prevention
- Report status validation
- Balance overflow protection
- Input validation for all parameters

## 🚀 Getting Started

1. Deploy the contract to Stacks testnet/mainnet
2. Configure initial reward amounts and voting thresholds
3. Start submitting disease reports
4. Build community participation through voting
5. Earn tokens for verified contributions

## 📊 Report Status Flow

```
Submitted → Pending → Voting → Verified/Rejected → Reward Claimed
```

## 🌍 Impact

Help farmers detect and respond to rice diseases faster through:
- Early warning systems
- Crowdsourced monitoring
- Incentivized reporting
- Community-verified data
- Real-time disease tracking

---

Built with ❤️ for the farming community using Stacks blockchain and Clarity smart contracts.

## 🚨 Emergency Pause Functionality

- **Pause Contract**: Allows the contract owner to halt all critical operations instantly in case of security threats.
- **Unpause Contract**: Restores normal functionality once the issue is resolved.
- **Check Pause Status**: Read-only function to verify if the contract is currently paused.

### Usage

```clarity
;; Pause the contract (owner only)
(contract-call? .Rice-Disease-Detection-Bounty-System pause-contract)

;; Unpause the contract (owner only)
(contract-call? .Rice-Disease-Detection-Bounty-System unpause-contract)

;; Check if paused
(contract-call? .Rice-Disease-Detection-Bounty-System is-contract-paused)
```

This feature enhances security by providing a rapid response mechanism to potential vulnerabilities, ensuring user funds and data integrity. #Security #Blockchain #SmartContracts

### Appeal Rejected Reports
```clarity
;; Appeal a rejected report (requires appeal fee)
(contract-call? .Rice-Disease-Detection-Bounty-System appeal-report u1)
```

### Set Appeal Fee
```clarity
;; Set new appeal fee (owner only)
(contract-call? .Rice-Disease-Detection-Bounty-System set-appeal-fee u200)
```

### Check Appeal Fee
```clarity
;; Get current appeal fee
(contract-call? .Rice-Disease-Detection-Bounty-System get-appeal-fee)
```

## 🔄 Report Appeal Mechanism

- **Appeal Rejected Reports**: Reporters can appeal rejected reports by paying a configurable fee, resetting the report to pending status for re-voting.
- **Fee-Based Appeals**: Appeals require payment of an appeal fee to prevent spam and ensure commitment.
- **Re-Voting Process**: Appealed reports return to pending status with votes reset, allowing community to re-evaluate.
- **One-Time Appeals**: Each report can only be appealed once to maintain system integrity.

### Appeal Flow
```
Rejected → Appeal (Pay Fee) → Pending → Re-Voting → Verified/Rejected
```

## ⏰ Report Expiration Mechanism

- **Automatic Expiration**: Reports automatically expire after a configurable number of blocks, preventing stale data from lingering in the system.
- **Configurable Duration**: Contract owner can adjust the expiration period to balance timeliness and community participation.
- **Voting Protection**: Expired reports cannot receive new votes, ensuring only current and relevant reports are evaluated.
- **System Efficiency**: Reduces storage overhead by naturally pruning outdated reports through expiration.

### Usage

```clarity
;; Set report expiry duration (owner only)
(contract-call? .Rice-Disease-Detection-Bounty-System set-report-expiry-blocks u2880)

;; Get current expiry setting
(contract-call? .Rice-Disease-Detection-Bounty-System get-report-expiry-blocks)
```

### Expiration Flow

```
Report Submitted → Active for Voting → Expires After Time Limit → No Further Voting Allowed
```

This feature ensures data freshness and system performance by automatically managing report lifecycle, keeping the platform focused on current disease detection needs. #DataFreshness #SystemEfficiency #BlockchainOptimization
This mechanism empowers reporters to challenge incorrect rejections, fostering fairness and encouraging accurate reporting through community consensus. #Fairness #CommunityGovernance #BlockchainTransparency

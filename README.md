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

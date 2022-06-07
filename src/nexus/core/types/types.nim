type
  # Format environment variables enum
  FormatEnvVar* = enum
    NoFormat = 0,
    Dollar,
    DollarWithBraces


const
  # Account User.Subscription Status
  SubscriptionStatusFree* = 'F'
  SubscriptionStatusTrial* = 'T'
  SubscriptionStatusPaid* = 'P'

  # DocUI Error Codes
  LoginFailedAccountNotVerified* = "LFANV"

  # Error messages
  AccountNotVerifiedByEmail* = "Account not verified by email."


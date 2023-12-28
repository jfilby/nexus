import options
import db_connector/db_postgres


type
  Account* = ref object of RootObj
    accountId*: string
    account_name*: string
    created_userId*: string
    trial_period_start*: string
    trial_period_end*: string
    created*: string


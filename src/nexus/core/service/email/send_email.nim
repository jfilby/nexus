import chronicles, os, smtp, strutils


# Forward declarations
proc skipEmail(
       email: string,
       emailSkipDomains: string): bool


# Code
proc sendEmail*(toAddress: string,
                subject: string,
                body: string) =

  # Define vars
  let
    emailFromAddress = getEnv("EMAIL_FROM_ADDRESS")
    emailSmtpServer = getEnv("EMAIL_FROM_SMTP_SERVER")
    emailSmtpPort = getEnv("EMAIL_FROM_PORT")
    emailUsername = getEnv("EMAIL_FROM_USERNAME")
    emailPassword = getEnv("EMAIL_FROM_PASSWORD")
    emailSsl = getEnv("EMAIL_USE_SSL")
    emailSkipDomains = getEnv("EMAIL_SKIP_DOMAINS")

  # Skip if in EMAIL_SKIP_DOMAINS comma-delimited list
  if skipEmail(
       toAddress,
       emailSkipDomains) == true:

    return

  # If no from address is set then email sending is not enabled (local testing)
  if email_from_address == "":
    warn "sendEmail(): Nexus email settings not set; no email will be sent"

    return

  # Determine whether to use ssl or not
  var sslEnabled = false

  if emailSsl != "":
    sslEnabled = true

  let
    msg = createMessage(subject,
                        body)

    smtpConn = newSmtp(useSsl = sslEnabled,
                       debug = true)

  # Verify emailSmtpPort (if not set then sending is not enabled; local testing)
  if emailSmtpPort == "":
    return

  # Send email
  smtpConn.connect(emailSmtpServer,
                   Port parseInt(emailSmtpPort))

  if emailUsername != "":
    smtpConn.auth(emailUsername,
                  emailPassword)

  smtpConn.sendmail(emailFromAddress,
                    @[ toAddress ],
                    $msg)


proc skipEmail(
       email: string,
       emailSkipDomains: string): bool =

  # Validate
  if emailSkipDomains == "":
    return false

  # Get list of domains
  let
    domains =
      split(
        toLowerAscii(emailSkipDomains),
        ",")

    atPos =
      find(email,
           "@")

  if atPos < 0 or atPos + 1 > len(email) - 1:
    return false

  let emailDomain =
        toLowerAscii(email[atPos + 1 .. len(email) - 1])

  # Check each domain against the email
  for domain in domains:

    if find(emailDomain,
            domain) >= 0:

      return true

  # Else not found
  return false


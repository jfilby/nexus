import chronicles, times, timezones
import nexus/core_extras/data_access/country_timezone_data
import nexus/core_extras/types/model_types


proc loadTimezones*(
       dbContext: NexusCoreExtrasDbContext,
       path: string) =

  # The path must point to a JSON timezones file in the format expected by the
  # timezones package.

  # Load timezone JSON data
  let tzData = loadTzDb(path)

  # Truncate the countryTimezone table
  truncateCountryTimezone(
    dbContext,
    cascade = false)

  # Get all tz names
  let tzNames = tzNames(tzData)

  # Iterate JSON data and create records
  for tzName in tzNames:

    let tz = tzInfo(tzName)

    debug "loadTimezones",
      tzName = tzName,
      tz = $tz

    for countryCode in tz.countries:

      discard createCountryTimezone(
                dbContext,
                countryCode,
                tzName,
                now())


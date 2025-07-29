import ballerina/time;

// Convert time:Utc to MySQL datetime format (YYYY-MM-DD HH:MM:SS)
public function utcToMySQLDatetime(time:Utc utcTime) returns string {
    time:Civil civilTime = time:utcToCivil(utcTime);
    
    // Handle the optional second field properly
    decimal secondValue = civilTime.second ?: 0.0;
    int secondInt = <int>secondValue;
    
    // Format datetime string with proper zero padding
    string monthStr = civilTime.month < 10 ? string `0${civilTime.month}` : civilTime.month.toString();
    string dayStr = civilTime.day < 10 ? string `0${civilTime.day}` : civilTime.day.toString();
    string hourStr = civilTime.hour < 10 ? string `0${civilTime.hour}` : civilTime.hour.toString();
    string minuteStr = civilTime.minute < 10 ? string `0${civilTime.minute}` : civilTime.minute.toString();
    string secondStr = secondInt < 10 ? string `0${secondInt}` : secondInt.toString();
    
    return string `${civilTime.year}-${monthStr}-${dayStr} ${hourStr}:${minuteStr}:${secondStr}`;
}

// Parse MySQL datetime string to time:Utc
public function parseMySQLDatetime(string datetimeStr) returns time:Utc|error {
    // Expected format: YYYY-MM-DD HH:MM:SS
    if datetimeStr.length() < 19 {
        return error("Invalid datetime format");
    }
    
    // Parse date part (YYYY-MM-DD)
    string dateStr = datetimeStr.substring(0, 10);
    string yearStr = dateStr.substring(0, 4);
    string monthStr = dateStr.substring(5, 7);
    string dayStr = dateStr.substring(8, 10);
    
    // Parse time part (HH:MM:SS)
    string timeStr = datetimeStr.substring(11, 19);
    string hourStr = timeStr.substring(0, 2);
    string minuteStr = timeStr.substring(3, 5);
    string secondStr = timeStr.substring(6, 8);
    
    // Convert strings to integers
    int year = check int:fromString(yearStr);
    int month = check int:fromString(monthStr);
    int day = check int:fromString(dayStr);
    int hour = check int:fromString(hourStr);
    int minute = check int:fromString(minuteStr);
    decimal second = check decimal:fromString(secondStr);
    
    // Create Civil time
    time:Civil civilTime = {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        utcOffset: {hours: 0, minutes: 0}
    };
    
    // Convert to UTC
    return time:utcFromCivil(civilTime);
}

// Format time:Utc for display purposes
public function formatDisplayDatetime(time:Utc utcTime) returns string {
    time:Civil displayTime = time:utcToCivil(utcTime);
    decimal secondValue = displayTime.second ?: 0.0;
    int secondInt = <int>secondValue;
    
    string monthStr = displayTime.month < 10 ? string `0${displayTime.month}` : displayTime.month.toString();
    string dayStr = displayTime.day < 10 ? string `0${displayTime.day}` : displayTime.day.toString();
    string hourStr = displayTime.hour < 10 ? string `0${displayTime.hour}` : displayTime.hour.toString();
    string minuteStr = displayTime.minute < 10 ? string `0${displayTime.minute}` : displayTime.minute.toString();
    string secondStr = secondInt < 10 ? string `0${secondInt}` : secondInt.toString();
    
    return string `${displayTime.year}-${monthStr}-${dayStr} ${hourStr}:${minuteStr}:${secondStr}`;
}

// Get individual date components from time:Utc for display
public function getDateTimeComponents(time:Utc utcTime) returns record {|int year; int month; int day; int hour; int minute; int second;|} {
    time:Civil displayTime = time:utcToCivil(utcTime);
    decimal secondValue = displayTime.second ?: 0.0;
    int secondInt = <int>secondValue;
    
    return {
        year: displayTime.year,
        month: displayTime.month,
        day: displayTime.day,
        hour: displayTime.hour,
        minute: displayTime.minute,
        second: secondInt
    };
}
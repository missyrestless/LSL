// Convert Unix Time to SLT, identifying whether it is currently PST or PDT (i.e. Daylight Saving aware)
//
// Example:
//
// default
// {
//     state_entry()
//     {
//         llOwnerSay( Unix2SLT(llGetUnixTime()));
//     }
// }

string mInt2mStr(string monthInt) {
    list months=["","January","February","March", "April","May","June", "July",
                    "August","September", "October","November","December"];
    return llList2String(months, (integer)monthInt);
}

string ConvertToAmPm(string time24) {
    // Expected input format: "HH:MM" (e.g., "15:30")
    integer hours = (integer)llGetSubString(time24, 0, 1);
    string minutes = llGetSubString(time24, 2, -1); // Includes the leading ":"

    string suffix = " AM";
    if (hours >= 12) {
        suffix = " PM";
    }

    integer h12 = hours % 12;
    if (h12 == 0) h12 = 12; // Handle midnight and noon

    return (string)h12 + minutes + suffix;
}

// This leap year test is correct for all years from 1901 to 2099 and hence is quite adequate for Unix Time computations
integer LeapYear(integer year)
{
    return !(year & 3);
}

integer DaysPerMonth(integer year, integer month)
{
    if (month == 2)      return 28 + LeapYear(year);
    return 30 + ( (month + (month > 7) ) & 1);           // Odd months up to July, and even months after July, have 31 days
}

string Convert(integer insecs)
{
    integer w; integer month; integer daysinyear;
    integer mins = insecs / 60;
    integer secs = insecs % 60;
    integer hours = mins / 60;
    mins = mins % 60;
    integer days = hours / 24;
    hours = hours % 24;
    integer DayOfWeek = (days + 4) % 7;    // 0=Sun thru 6=Sat

    integer years = 1970 +  4 * (days / 1461);
    days = days % 1461;                  // number of days into a 4-year cycle

    @loop;
    daysinyear = 365 + LeapYear(years);
    if (days >= daysinyear)
    {
        days -= daysinyear;
        ++years;
        jump loop;
    }
    ++days;

    for (w = month = 0; days > w; )
    {
        days -= w;
        w = DaysPerMonth(years, ++month);
    }
    string str =  ((string) years + "-" + llGetSubString ("0" + (string) month, -2, -1) + "-" + llGetSubString ("0" + (string) days, -2, -1) + " " +
	llGetSubString ("0" + (string) hours, -2, -1) + ":" + llGetSubString ("0" + (string) mins, -2, -1) );

    integer LastSunday = days - DayOfWeek;
    string PST_PDT = " PST";                  // start by assuming Pacific Standard Time
    // Up to 2006, PDT is from the first Sunday in April to the last Sunday in October
    // After 2006, PDT is from the 2nd Sunday in March to the first Sunday in November
    if (years > 2006 && month == 3  && LastSunday >  7)     PST_PDT = " PDT";
    if (month > 3)                                          PST_PDT = " PDT";
    if (month > 10)                                         PST_PDT = " PST";
    if (years < 2007 && month == 10 && LastSunday > 24)     PST_PDT = " PST";
    string yearPart = llGetSubString(str, 0, 3);
    string monthPart = llGetSubString(str, 5, 6);
    string dayPart = llGetSubString(str, 8, 9);
    string timePart = llGetSubString(str, -5, -1);
    list weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return (llList2String(weekdays, DayOfWeek) + ", " +
                          mInt2mStr(monthPart) + " " +
                          dayPart + ", " + yearPart + ", " +
                          ConvertToAmPm(timePart) + PST_PDT);
}

// Convert Unix Time to SLT, identifying whether it is currently PST or PDT (i.e. Daylight Saving aware)
string Unix2SLT(integer insecs)
{
    string str = Convert(insecs - (3600 * 8) );   // PST is 8 hours behind GMT
    if (llGetSubString(str, -3, -1) == "PDT")     // if the result indicates Daylight Saving Time ...
        str = Convert(insecs - (3600 * 7) );      // ... Recompute at 1 hour later
    if (llGetSubString(str, -3, -1) == "PDT") {
        str = llReplaceSubString(str, "PDT", "SLT", -1);
    } else {
        str = llReplaceSubString(str, "PST", "SLT", -1);
    }
    return str;
}


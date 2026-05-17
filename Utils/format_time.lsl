  /*
  *  Submitted Opensource under GPL 3.0
  *  2010 Fire Centaur
  *  Description: 
  *  
  *  Input number of seconds, function will return a string with Days, Hours, Minutes, Seconds
  *  Corrections by Traven Sachs to Display Correct Output allowing for 0 seconds or more than 1 day 
  *     and improve readability with whitespace 19-Feb-2011
  */

string getTime(integer secs)
{
    string timeStr;
    integer days;
    integer hours;
    integer minutes;
 
    if (secs>=86400)
    {
        days=llFloor(secs/86400);
        secs=secs%86400;
        timeStr+=(string)days+" day";
        if (days>1) 
        {
            timeStr+="s";
        }
        if(secs>0) 
        {
            timeStr+=", ";
        }
    }
    if(secs>=3600)
    {
        hours=llFloor(secs/3600);
        secs=secs%3600;
        timeStr+=(string)hours+" hour";
        if(hours!=1)
        {
            timeStr+="s";
        }
        if(secs>0)
        {
            timeStr+=", ";
        }
    }
    if(secs>=60)
    {
        minutes=llFloor(secs/60);
        secs=secs%60;
        timeStr+=(string)minutes+" minute";
        if(minutes!=1)
        {
            timeStr+="s";
        }
        if(secs>0)
        {
            timeStr+=", ";
        }
    }
    if (secs>0)
    {
        timeStr+=(string)secs+" second";
        if(secs!=1)
        {
            timeStr+="s";
        }
    }
    return timeStr;
}
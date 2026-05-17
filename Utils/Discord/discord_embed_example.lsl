string slurl(key AvatarID)
{
    string regionname = llGetRegionName();
    vector pos = llList2Vector(llGetObjectDetails(AvatarID, [ OBJECT_POS ]), 0);
 
    return "http://maps.secondlife.com/secondlife/"
        + llEscapeURL(regionname) + "/"
        + (string)llRound(pos.x) + "/"
        + (string)llRound(pos.y) + "/"
        + (string)llRound(pos.z) + "/";
}
key PostToDiscord(key AvatarID, string Message)
{
    string SLURL = slurl(AvatarID); // call another function to get the slurl
    string user  = llKey2Name( AvatarID );
    list json    = [ 
        "username", llGetObjectName() + "",
        "embeds", 
            llList2Json(JSON_ARRAY,
            [
            llList2Json(JSON_OBJECT,
                [
                    "color", "100000",
                    "title", "Server Location",
                    "url", SLURL,
                    "description",  "\nSender's Profile: http://my.secondlife.com/" +
                      llGetUsername(AvatarID)  + "\n \nMsg from " +
                      llGetUsername(AvatarID) + ": \n" + Message + "\n \n.",
                   
                    "author", llList2Json(JSON_OBJECT, 
                    [ 
                        "name",  user,
                        "icon_url", "https://my-secondlife-agni.akamaized.net/users/" +
                         llGetUsername(AvatarID) + "/sl_image.png"                               
                    ]),
                    "footer", llList2Json(JSON_OBJECT, 
                    [ 
                        "icon_url", "https://my-secondlife-agni.akamaized.net/users/" +
                         llGetUsername(AvatarID) + "/sl_image.png",
                        "text", "XMODS Discord Embedder"
                    ])                
                ])
             ]),
            "avatar_url",  "https://my-secondlife-agni.akamaized.net/users/" +
                            llGetUsername(AvatarID) + "/thumb_sl_image.png"
    ];
   
    return llHTTPRequest( WEBHOOK_URL ,
    [   HTTP_METHOD,          "POST", 
        HTTP_MIMETYPE,        "application/json",
        HTTP_VERIFY_CERT,      TRUE,
        HTTP_VERBOSE_THROTTLE, TRUE,
        HTTP_PRAGMA_NO_CACHE,  TRUE ],
          llList2Json(JSON_OBJECT, json) );
}

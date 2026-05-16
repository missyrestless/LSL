string WEBHOOK_URL = "YOUR_DISCORD_WEBHOOK_URL_HERE";

sendDiscordEmbed() {
    // Construct JSON payload for Discord
    string jsonPayload = 
        "{ \"embeds\": [ " +
            "{ " +
                "\"title\": \"Hyperlink in Title!\", " +
                "\"url\": \"https://example.com\", " +
                "\"description\": \"Click the title above, or use this [Example Link](https://example.com) in the text.\", " +
                "\"color\": 16711680 " + // Integer representing hex color (e.g., #FF0000)
            "} " +
        "] }";

    // Send the POST request
    llHttpRequest(WEBHOOK_URL, [
        HTTP_METHOD, "POST",
        HTTP_MIMETYPE, "application/json"
    ], jsonPayload);
}

default {
    state_entry() {
        llOwnerSay("Touch to send embed to Discord.");
    }

    touch_start(integer total_number) {
        sendDiscordEmbed();
        llOwnerSay("Message sent!");
    }
    
    http_response(key request_id, integer status, list metadata, string body) {
        if (status == 200) {
            llOwnerSay("Success!");
        } else {
            llOwnerSay("Error: " + body);
        }
    }
}
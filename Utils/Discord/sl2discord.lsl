// Replace this with your copied Discord Webhook URL
string WEBHOOK_URL = "YOUR_DISCORD_WEBHOOK_URL_HERE";

// Function to send the message to Discord
sendToDiscord(string message) {
    // Create the JSON payload
    string json = llList2Json(JSON_OBJECT, [
        "username", "Second Life Bot", 
        "content", message
    ]);

    // Make the HTTP request to the Discord Webhook
    llHTTPRequest(WEBHOOK_URL, [
        HTTP_METHOD, "POST", 
        HTTP_MIMETYPE, "application/json"
    ], json);
}

default {
    state_entry() {
        llOwnerSay("Script ready. Touch the prim to send a test message.");
    }

    touch_start(integer total_number) {
        // Send a message when the prim is clicked
        string msg = "Hello from Second Life! The time is " + llGetTimestamp() + ".";
        sendToDiscord(msg);
    }
    
    http_response(key request_id, integer status, list metadata, string body) {
        if(status == 200) {
            llOwnerSay("Message sent to Discord successfully!");
        } else {
            llOwnerSay("Failed to send message. Error Code: " + (string)status);
        }
    }
}
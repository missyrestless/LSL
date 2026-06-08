// --- Configuration ---
string OLLAMA_URL = "http://YOUR_LOCAL_IP:11434/api/generate";
string MODEL_NAME = "llama3.2"; // Replace with your downloaded model (e.g., mistral, deepseek-r1)
string CORRADE_URL = "http://YOUR_CORRADE_IP:8080"; 
string GROUP_NAME = "Your Group Name";
string GROUP_PASSWORD = "Your Group Password";

// --- Runtime Variables ---
key http_request_id;
key ai_request_id;
string last_speaker_id;

default
{
    state_entry()
    {
        // Request an HTTP IN URL to receive callbacks from Corrade
        llRequestURL();
    }

    http_request(key id, string method, string body)
    {
        if (method == URL_REQUEST_GRANTED)
        {
            llOwnerSay("Bot AI Proxy ready. URL: " + body);
            // Instruct Corrade to notify this URL on Local Chat events
            // (You can also do this in the Corrade.ini)
            sendCorradeCommand("notify", ["type", "local", "URL", body]);
        }
        else if (method == "POST")
        {
            // Acknowledge the callback immediately so Corrade does not timeout
            llHTTPResponse(id, 200, "OK");
            
            // Parse Corrade event (Corrade passes data linearly as a list of strings)
            // We assume the message contains the agent's name, UUID, and message.
            string message = extractCorradeValue(body, "message");
            string speakerName = extractCorradeValue(body, "firstname") + " " + extractCorradeValue(body, "lastname");
            last_speaker_id = extractCorradeValue(body, "agentuuid");

            // Ignore messages from the bot itself to prevent infinite loops
            if (message != "" && speakerName != " ")
            {
                // Send the prompt to Ollama
                llOwnerSay("Generating response for: " + message);
                askOllama(message);
            }
        }
    }

    // Helper: Send a command to Corrade
    sendCorradeCommand(string command, list parameters)
    {
        list payload = [
            "command", command,
            "group", GROUP_NAME,
            "password", GROUP_PASSWORD
        ] + parameters;
        
        llHTTPRequest(CORRADE_URL, [HTTP_METHOD, "POST"], wasKeyValueEncode(payload));
    }

    // Helper: Parse Corrade HTTP POST variables
    string extractCorradeValue(string body, string key)
    {
        list parsed = llParseString2List(body, ["&"], []);
        integer i;
        for (i = 0; i < llGetListLength(parsed); ++i)
        {
            list kv = llParseString2List(llList2String(parsed, i), ["="], []);
            if (llList2String(kv, 0) == key)
            {
                return llUnescapeURL(llList2String(kv, 1));
            }
        }
        return "";
    }

    // Send query to local Ollama server
    askOllama(string prompt)
    {
        string json = llList2Json(JSON_OBJECT, [
            "model", MODEL_NAME,
            "prompt", prompt,
            "stream", FALSE
        ]);
        
        ai_request_id = llHTTPRequest(OLLAMA_URL, [
            HTTP_METHOD, "POST",
            HTTP_MIMETYPE, "application/json"
        ], json);
    }

    http_response(key id, integer status, list meta, string body)
    {
        if (id == ai_request_id)
        {
            if (status == 200)
            {
                // Ollama returns a JSON with an attribute "response"
                string ai_response = llJsonValueByPath(body, ["response"]);
                
                // Strip quotes from JSON output
                ai_response = llGetSubString(ai_response, 1, -2); 

                // Send the response back through the Corrade bot
                sendCorradeCommand("instantmessage", [
                    "agent", last_speaker_id,
                    "message", ai_response
                ]);
            }
            else
            {
                llOwnerSay("Error connecting to Ollama. Status: " + (string)status);
            }
        }
    }
}

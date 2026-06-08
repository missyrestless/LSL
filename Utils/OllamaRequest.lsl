string OLLAMA_URL = "http://YOUR_LOCAL_IP:11434/api/chat";
string MODEL_NAME = "llama3.2"; // Change to the model you have installed

default
{
    state_entry()
    {
        // Listen on channel 0 (Public Chat) to capture user input
        llListen(0, "", llGetOwner(), "");
        llOwnerSay("Ollama connector ready. Type your prompt in local chat.");
    }

    listen(integer channel, string name, key id, string message)
    {
        // Only respond to the owner for now, avoiding spam
        if (id == llGetOwner())
        {
            llOwnerSay("Sending message to Ollama: " + message);
            
            // Construct the JSON payload for Ollama
            // {"model": "llama3.2", "messages": [{"role": "user", "content": "..."}]}
            string jsonPayload = llList2Json(JSON_OBJECT, [
                "model", MODEL_NAME,
                "messages", llList2Json(JSON_ARRAY, [
                    llList2Json(JSON_OBJECT, [
                        "role", "user",
                        "content", message
                    ])
                ]),
                "stream", FALSE // We will process the full response at once
            ]);

            // Send the HTTP request to your local Ollama server
            llHTTPRequest(OLLAMA_URL, [
                HTTP_METHOD, "POST",
                HTTP_MIMETYPE, "application/json"
            ], jsonPayload);
        }
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (status == 200)
        {
            // Parse the returned JSON response
            // The AI's message is nested under message -> content
            string aiMessage = llJsonGetValue(body, ["message", "content"]);
            
            if (aiMessage != JSON_INVALID)
            {
                llOwnerSay("AI: " + aiMessage);
            }
            else
            {
                llOwnerSay("Error parsing response body.");
            }
        }
        else
        {
            llOwnerSay("Error connecting to Ollama. HTTP Status: " + (string)status);
        }
    }
}

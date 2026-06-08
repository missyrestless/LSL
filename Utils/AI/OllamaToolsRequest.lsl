string OLLAMA_URL = "http://your-local-ip:11434/api/chat";

default {
    state_entry() {
        string jsonPayload = llList2Json(JSON_OBJECT, [
            "model", "llama3.1",
            "messages", llList2Json(JSON_ARRAY, [
                llList2Json(JSON_OBJECT, ["role", "user", "content", "Weather in NYC?"])
            ]),
            "tools", llList2Json(JSON_ARRAY, [
                llList2Json(JSON_OBJECT, [
                    "type", "function",
                    "function", llList2Json(JSON_OBJECT, [
                        "name", "get_current_weather",
                        "parameters", llList2Json(JSON_OBJECT, [
                            "type", "object",
                            "properties", llList2Json(JSON_OBJECT, [
                                "city", llList2Json(JSON_OBJECT, ["type", "string"])
                            ]),
                            "required", llList2Json(JSON_ARRAY, ["city"])
                        ])
                    ])
                ])
            ])
        ]);
        llHTTPRequest(OLLAMA_URL, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json"], jsonPayload);
    }

    http_response(key id, integer status, list meta, string body) {
        if (status == 200) {
            string toolCalls = llJsonGetValue(body, ["message", "tool_calls"]);
            if (toolCalls != JSON_INVALID && toolCalls != "EMPTY") {
                llOwnerSay("Tool call: " + toolCalls);
            } else {
                llOwnerSay("AI: " + llJsonGetValue(body, ["message", "content"]));
            }
        }
    }
}

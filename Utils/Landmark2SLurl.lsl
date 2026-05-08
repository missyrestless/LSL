// Click to print SLURL for every landmark in inventory.
//     Uses llRequestInventoryData() to get coordinates
//     Uses http://wiki.secondlife.com/wiki/Linden_Lab_Official:Map_API_Reference#Region_name_from_global_coordinates to get region name
integer landmarkIndex;
vector  landmarkCoords;
string  landmarkRegion;
string  landmarkSlurl;
key inventoryRequestId;
key mapRequestId;

requestLandmarkInfo(integer inventoryIndex) {
    if (inventoryIndex >= llGetInventoryNumber(INVENTORY_LANDMARK)) return;
    landmarkIndex = inventoryIndex;
    string landmarkName = llGetInventoryName(INVENTORY_LANDMARK, landmarkIndex);
    inventoryRequestId = llRequestInventoryData(landmarkName);
}

default {
    touch_start(integer count) {
        requestLandmarkInfo(0);
    }

    dataserver(key requestId, string data) {
        if (requestId != inventoryRequestId) return;
        if ((vector)data == ZERO_VECTOR) return;
        // landmark request
        landmarkCoords = llGetRegionCorner() + (vector)data;
        // http://wiki.secondlife.com/wiki/Linden_Lab_Official:Map_API_Reference#Region_name_from_global_coordinates
        mapRequestId = llHTTPRequest(
            "https://cap.secondlife.com/cap/0/b713fe80-283b-4585-af4d-a3b7d9a32492?var=region"
            + "&grid_x=" + (string)((integer)landmarkCoords.x / 256)
            + "&grid_y=" + (string)((integer)landmarkCoords.y / 256), [], "");
    }

    http_response(key requestId, integer status, list metadata, string body) {
        if (requestId != mapRequestId) return;
        landmarkRegion = llList2String(llParseString2List(body, ["var region='", "';"], []), 0);
        landmarkSlurl = "http://maps.secondlife.com/secondlife/" + llEscapeURL(landmarkRegion) +
            "/" + (string)((integer)landmarkCoords.x % 256) +
            "/" + (string)((integer)landmarkCoords.y % 256) +
            "/" + (string)((integer)landmarkCoords.z);
        llOwnerSay(llGetInventoryName(INVENTORY_LANDMARK, landmarkIndex) + ": "
            + landmarkSlurl + " <nolink>" + landmarkSlurl + "</nolink>");
        requestLandmarkInfo(landmarkIndex + 1);
    }
}
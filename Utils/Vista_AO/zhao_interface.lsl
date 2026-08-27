// The Vista animation overriders in Second Life are based on the ZHAO-II engine
// (by Ziggy Puff, mod by Marcus Gray, Johann Ehrler and Moeka Kohime) and the
// Vista AOs that were tested contain the ZHAO-II-core MGJEmod 1.1.9 script.
//
// Even though the Vista animation creator does not disclose the GPLv2 source,
// the header of the ZHAO-II-core MGJEmod 1.1.9 script mentions the following:

// ZHAO-II-core - Ziggy Puff, 07/07
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Main engine script - receives link messages from any interface script. Handles the core AO work
//
// Interface definition: The following link_message commands are handled by this script. All of 
// these are sent in the string field. All other fields are ignored
//
// ZHAO_RESET                          Reset script
// ZHAO_LOAD|<notecardName>            Load specified notecard
// ZHAO_NEXTSTAND                      Switch to next stand
// ZHAO_STANDTIME|<time>               Time between stands. Specified in seconds, expects an integer.
//                                     0 turns it off
// ZHAO_AOON                           AO On
// ZHAO_AOOFF                          AO Off
// ZHAO_SITON                          Sit On
// ZHAO_SITOFF                         Sit Off
// ZHAO_RANDOMSTANDS                   Stands cycle randomly
// ZHAO_SEQUENTIALSTANDS               Stands cycle sequentially
// ZHAO_SETTINGS                       Prints status
// ZHAO_SITS                           Select a sit
// ZHAO_GROUNDSITS                     Select a ground sit
// ZHAO_WALKS                          Select a walk
//
// ZHAO_SITANYWHERE_ON                 Sit Anywhere mod On 
// ZHAO_SITANYWHERE_OFF                Sit Anywhere mod Off 
//
// ZHAO_TYPE_ON                        Typing AO On 
// ZHAO_TYPE_OFF                       Typing AO Off 
//
// ZHAO_TYPEKILL_ON                    Typing Killer On 
// ZHAO_TYPEKILL_OFF                   Typing Killer Off 
//
// So, to send a command to the ZHAO-II engine, send a linked message:
//
//   llMessageLinked(LINK_SET, 0, "ZHAO_AOON", NULL_KEY);
//
// This script uses a listener on channel -91234. If other scripts are added to the ZHAO, make sure 
// they don't use the same channel

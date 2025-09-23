# Corrade HUD

This is a control Heads-Up Display (HUD) for the Corrade scripted agent featuring some of the more common movement controls that allow you to control Corrade as a drone. The HUD is designed for the bleeding-edge (most recent version of Corrade) such that you will need a Corrade progressive scripted agent installed.

The configured group should have the following permissions enabled:

- movement
- grooming
- notifications
- interact

and the following notifications:

- permission - dialog

enabled using the bundled Configurator program for Corrade.

Note that the HUD is not exhaustive in functions - currently Corrade features an application programmer interface (API) spanning a few hundred commands. Instead, the HUD is provided as a template for programmers as a reference on how to create scripts for Corrade. The HUD also generally focuses on "movement" actions such as: sit, walk, patrol, teleport, etc… With a a few exceptions. In any case, we hope that the scripts within the HUD provide a good starting point for scripters to make their own scripts and create other items based on them.

The scripts in the `Corrade` directory are modified enhanced versions of
scripts distributed under an Open Source license found at:

https://grimore.org/secondlife/scripted_agents/corrade/projects/in_world/movmement_heads-up_display

## Marketplace Item

[Corrade Movement Heads-Up Display (Drone)](https://marketplace.secondlife.com/p/WaS-Corrade-Movement-Heads-Up-Display-Drone-HUD/8809096)

## Setting Up

After receiving the item from Marketplace, right-click the object and attach it to your HUD. You will end up with a single icon on your screen featuring a zeppelin. Right-click and edit the icon and then go to the "Contents" tab on the pop-up edit pane. Inside you will find a "configuration" notecard. Double-click the notecard and configure the settings to your liking. Note that the options:

- "corrade"
- "group"
- "password"

have to be set in order for the HUD to work with your Corrade and should correspond with the settings you have made using the Configurator and present in the Corrade.ini file. All the other options should be safe as they are.

## Usage

Once you save the "configuration" notecard, the main HUD script should restart and pick-up the changes you have made. In case your Corrade bot is online, and given that the configuration you have made is correct, you should be able to click the zeppelin icon in order to have the other icons unfold on your screen. If you touch the zeppelin icon and the other icons do not unfold then it means that there was a problem connecting to your Corrade bot and you should check your settings or contact support for help.

Every icon on the HUD except the icon with the zeppelin logo represents an action that you can make Corrade perform. Please see the attached screenshot, or the project's page, for a short explanation on what function each icon performs.

The HUD will fold once Corrade is not online anymore - you can also click the zeppelin icon to hide all the other buttons from view and then press the icon again to reveal them. In case you have activated buttons, you can still fold the other icons on the HUD and they will still work in the background such that it is not necessary to always have all the buttons showing on your screen.

### Making the HUD Shut Up

Since this is a developer's item, all the debug messages are turned on such that the HUD will be very chatty on local chat. In order to make the HUD silent, you will have to edit the scripts and remove the debug information. In order to do that, for all icons, open the script and then find lines similar to the following:

```
// DEBUG 
llOwnerSay ... etc ...
```

and delete or comment out those two lines for every script.

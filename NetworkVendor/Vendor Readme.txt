Restless Studio Vendor v2
=========================

(c)2008 Ilobmirt Tenk
(c)2011 Missy Restless

=====
INDEX
=====

1) Changes Since v0.5

2) Scripts

3) Setting Up the Restless Studio Vending System

4) Networking the Restless Studio Vending System

5) Configuring the Restless Studio Vending System

6) Configurable Variables (CLIENT_SETTINGS)

7) Configurable Variables (SERVER_SETTINGS)

8) Configurable Variables (LINK_SETTINGS)

9) Setting Up Inventory

10) Verbal Commands (Vendor)

11) Verbal Commands (Server)

=====================
1| Changes Since v0.5
=====================

    This Version of the Fossl Vending System underwent a major redesign.
    This adds new features to the system, making it more flexible for the
    vendor to configure. This current version by request and for the purposes
    of prototyping the features of later releases of the vending system has
    been made for in-world networking only. So as for this version, there will 
    be no databases to keep track of sales and vendors. It's impractical with what
    limited memory lsl gives programmers to use on top of the reliability of how 
    permanent in-world data is.

    But as an upside for now. This vending system can either be standalone or 
    networked with a central server that has been rezzed in a supposedly permanent
    location. Also, it is possible now for others to re-sell your content.
    And communication in-world can be kept safer from exploitation using a shared key
    for encrypting messages between vendor and server.

==========
2| Scripts
==========

    This version of the Fossl Vending system contains 6 lsl scripts
    The following scripts are...

        VendorMainClient - This script manages the state of the vendor in general as well as keep track of the
                                Vendor index and update the displays.

        VendorProductDatabase - This script contains all of the inventory for your products within an inventory buffer.
                                     Scripts can make out queries in its database using product category and subcategory index.
                                     If the query isn't within the product buffer, this script will search the product notecard
                                     for the requested item. The result of searching in the notecard will then be added to the buffer
                                     for quicker access.

        VendorLink - This script when clicked notifies the Vendor to move to a certain
                          product index. If specified, the script will also register itself
                          into VendorMainClient as a display to show its associated 
                          product.

        VendorBuy - This script when paid a specified amount, will notify VendorMainClient
                         that a sale has been made. It will also get messages from VendorMainClient
                         to change the amount one has to pay to get a product.

        VendorInfo - This Script when clicked, will notify VendorMainClient that a person requests
                          an information notecard.

        VendorMainServer - This script will help keep all the client vendors updated with the uuid of
                                the products notecard. It will also give inventory to a specified uuid upon request.

        VendorEmailAgent - This script will offload the 20 second script delay penalty from either
                                VendorMainClient or VendorMainServer.

======================================
3| Setting Up the Restless Studio Vending System
======================================

    1) Design your own vending system, or use a pre-existing design. This vending system requires at least 1 prim.

    2) You need a place to have the VendorMainClient script in. Wherever youre placing it, you also need a 
       notecard called "CLIENT_SETTINGS" to configure it.

    3) You need a place to keep track of inventory. Find a logical place to put VendorProductDatabase in.
       I tend to prefer placing it within the same prim as VendorMainClient.

    4) You need a place to show your products or move the vendor index around. For each prim that does that, add
       the VendorLink script in along with its configuration notecard "LINK_SETTINGS".

    5) For all prims that an avatar might pay in, add the script VendorBuy in it.

    6) For all prims that you want to have request for an information notecard, insert the script VendorInfo.

    7) If you haven't already, configure the "CLIENT_SETTINGS" and the "LINK_SETTINGS" notecards.

    8) If the vendor is standalone, add a products notecard in the same prim containing the VendorClient
       script. Its name should be "PRODUCTS_LIST" by default unless configured in the "CLIENT_SETTINGS"
       notecard. If the vendor is networked, proceed to the next section.

======================================
4| Networking the Restless Studio Vending System
======================================

    1) Rezz an empty prim

    2) Insert the VendorMainServer script along with its configuration notecard "SERVER_SETTINGS".

    3) Add a products notecard ("PRODUCTS_LIST" by default) to the server.

    4) by now, you should have recieved a uuid from the server. Copy this UUID for later.

    5) In the vendor client, edit "CLIENT_SETTINGS" so that the variable "server" is equal to the server uuid.
   
    (optional)
    6) To eliminate the 20 second delay involved with llEmail, add the VendorEmailAgent script to both the server
       and client vendor object. Configure the "CLIENT_SETTINGS" and "SERVER_SETTINGS" notecard so that
       the "email agents" variable is equal to 1 (TRUE).

=======================================
5| Configuring the Restless Studio Vending System
=======================================

    The scripts that compose the vending system contain variables that one can change via, a notecard.
    The notecard name may be different depending upon the script that uses it, but the general mechanics are
    the same. Each line is like an equation. Whatever's on the left of the "=" is a variable name.
    Whatever's to the right of the "=" is its value. The scripts will read the notecards from top to bottom
    so lines with the same variable later in the notecard will overwrite values defined earlier in the notecard.
    Variable names don't take into account the capitalization of the name or how far it is away from the "=" character.
    Variable values do take into account the capitalization, but dont care how far it is away from the "=" character.
    Variable values for "TRUE" or "FALSE" can't be transfered to an interger. Instead, try using "1" for "TRUE" and
    "0" for "FALSE".

=================================================
6| Configurable Variables (CLIENT_SETTINGS)
=================================================

    loading texture - (DEFAULT: 56617727-a972-f7d2-a730-484644a1fcb7 )
    Whenever vendor is retrieving item data for display, vendor will change the display to this
    texture uuid to represent that the product for this index is being retrieved.

    offline texture - (DEFAULT: b8426d53-221d-9fc2-5b29-3ef16e2bd7a3 )
    If the vendor is configured to be networked and that the server it has been configured to contact might not be online or if 
    the vendor's owner requested it to become offline,the vendor will use this texture uuid on all displays to signify that the vendor is unusable.

    nothing texture - (DEFAULT: 93481f65-67ff-f166-cc64-e6fe1069c1c1 )
    When no product is found for a certain index, the vendor will use this texture uuid to show that no product is available
    for that index.

    product card - (DEFAULT: "PRODUCTS_LIST" )
    Vendor will use this notecard to load its products that the owner wants to sell

    info card - (DEFAULT: "INFO" )
    Whenever information has been requested, give the person who requested it a notecard of that name.

    comm channel - (DEFAULT: 45 )
    Vendor owner will use this channel to give the vendor certain commands that it should act out.

    buffer - (DEFAULT: 0 )
    Vendor will not load the complete list of products into an array as other vendors normally do.
    To conserve script memory, the vendor will keep a list of products in a list of a certain size.
    The size of this list is as large as the number of displays used to show products plus the value
    of the buffer. Increasing this value will reduce the chance that the vendor will retrieve the product
    from a notecard slowing the vendor down. Having a buffer that is too large will however cause the script to
    produce a stack heap collision.

    server - (DEFAULT: NULL_KEY )
    When set to a key value other than NULL_KEY, vendor will try to network with that uuid in a networked mode instead of
    relying on its own inventory in a standalone mode.

    key - (DEFAULT: "" )
    When set to a value other than "", vendor will encrypt its communications between itself and the server using this shared key.

    refresh - (DEFAULT: 3,600 seconds = 1 hour )
    Whenever vendor is in a networked mode, vendor will try to clear its inventory out and obtain the latest product card uuid ensuring
    the vendor has the latest product line.

    timeout - (DEFAULT: 60 seconds = 1 minute )
    The server may not reply the the vendor immediately. Give the server this long to repond to the requests of this vendor.
    If server didn't repond to the requests of the vendor in this time, chances are, server might not exist. Vendor will go offline
    after the timeout has occured.

    email agents - (DEFAULT: 0 )
    If vendor is networked and there are dedicated e-mail scripts to offload the 20 second script sleep penalty, setting this value to 1
    will make the vendor use the dedicated script keeping the vendor active instead of running into the 20 second e-mail penalty.

    marketplace - (DEFAULT: none)
    If set, the marketplace URL will be IM'd to the avatar clicking the Product Info button along with the product's information notecard.

=================================================
7| Configurable Variables (SERVER_SETTINGS)
=================================================

    comm channel - (DEFAULT: 54 )
    Server owner will use this channel to give the server certain commands that it should act out.

    product card - (DEFAULT: "PRODUCTS_LIST" )
    Vendor will use this notecard to load its products that the owner wants to sell. Server will give the uuid of this card out to 
    the vendors that request it.
    
    email agents - (DEFAULT: 0 )
    If server has a dedicated e-mail script to offload the 20 second script sleep penalty, setting this value to 1
    will make the server use the dedicated script keeping the server active instead of running into the 20 second e-mail penalty.

    key - (DEFAULT: "" )
    When set to a value other than "", server will encrypt its communications between itself and the vendor using this shared key.

    anon access - (DEFAULT: 0 )
    When set to 1, server will accept requests from in-world objects owned by all people. Otherwise, server will only resond to requests
    that come from in-world objects of the same owner.

    outside access - (DEFAULT: 0 )
    When set to 1, server wil accept requests that came from outside Secondlife. Otherwise, requests are limited to in-world objects.
    To make use of this variable, "anon access" must be set to 1.

===============================================
8| Configurable Variables (LINK_SETTINGS)
===============================================

    images - (DEFAULT: 0 )
    When set to 1, the containing prim will be used to show a product with associated index.

    absolute category - (DEFAULT: 0)
    When set to 1, the assigned Category index will not change as vendor index changes

    category - (DEFAULT: 0 )
    This sets the category index of the link. When containing prim is clicked, this well tell the vendor to move the category either to that index,
    or relative by that index. This depends on whether or not the category is absolute or relative.

    absolute subcategory - (DEFAULT: 0)
    When set to 1, the assigned subCategory index will not change as vendor index changes

    subcategory - (DEFAULT: 0 )
    This sets the subcategory index of the link. When containing prim is clicked, this well tell the vendor to move the subcategory either to that index,
    or relative by that index. This depends on whether or not the subcategory is absolute or relative.

=======================
9| Setting Up Inventory
=======================

    Notecard configuration of vendor products is different than that of setting up a configuration card for vendor scripts.
    Each line of this notecard contains a variable length record of the inventory to be sold. Record structure is as follows...

    (Category)#(SubCategory)#(Price)#(Inventory Name)#(Texture UUID)

    When one creates a list of records, one must make sure that there are no spaces between elements separated by the "#" character.
    If one doesn't know the uuid of the texture, the option to copy the uuid of their own images can be found when right clicking on them in inventory.

============================
10| Verbal Commands (Vendor)
============================

    online - When vendor is in an offline mode, attempts to return functioning status to the vendor.

    offline - When vendor is functioning, takes the vendor into an offline mode.

    reset - Resets vending system scripts.

    debug - As the vendor operates, vendor will give its owner an indication of its current processes through verbose output.

    count - Returns the number of information notecard requests from this vendor

    memory - Returns the number of bytes that are free within the vendor

============================
11| Verbal Commands (Server)
============================

    debug - As the server operates, server will give its owner an indication of its current processes through verbose output.

    id - returns the uuid used by the containing object. Use it for configuring the vendors in networked mode.

    reset - Resets server system scripts.


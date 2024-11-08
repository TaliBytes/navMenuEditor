# Navigation Menu Editor

This navigation menu editor utilizes TSQL procedures, functions, and tables to store and modify menus and its menu items. Javascript is used to enable drag and drop style editing and submits the drag and drop information to the server. The server handles the request using ECPages to pass the information to SQL.

ECPages is also used to generate previews of the navigation menus while editing. (Rendering of the menu is excluded but is normally done using tb_menuItems which requires access rights for the user/empployee, to only show what they are allowed to access).

### Note

The ecreport_navMenus.ecs file doesn't have access rights/filtering included in it. Normally it would.

## Instructions For Use of Editor

### Move Item to Top / Bottom / Into Category

Dragging any item onto "Move item to top/bottom" will move that item to the very top or very bottom of the "root level" of the menu. Ie, root items don't have parents and are referred to as "categories."

Dragging any item onto "Move item into category" will nest that item under the category. This is primary used for moving root level items (category headers) into other categories (see why in FILL ME IN).

### Drag Drop One Item To Another On The Same Level

All items are assigned a "level." Level 0 (or null) is the root level. Level 1 is nested under a root level item. Level 2 is nested under a level 1 item. Etc.

Dragging an item of level x onto another item of level x will directly swap their positions (but not nested items).

Here is an example. Take the following menu tree and drag "Options" onto "Miscellaneous"

```
Miscellaneous
  Misc 1
  Misc 2

Options
  Option 1
    Option 1 A
    Option 1 B
  Option 2
```

and the result is

```
Options
  Option 1
    Option 1 A
    Option 1 B
  Option 2

Miscellaneous
  Misc 1
  Misc 2
```

*(Note, this is why the "Move Item Into Category" drop zone exists... is to nest root level items, such as Miscellaneous, under other root level items such as Options. Nested items can also be dragged onto "Move Item Into Category" to quickly move that item into the category without swapping it.)*

now drag "Misc 1" onto "Option 1" and the result is

```
Options
  Misc 1
  Option 2

Miscellaneous
  Option 1
    Option 1 A
    Option 1 B
  Misc 2
```

then drag Misc 2" onto "Option 1" and the result is

```
Options
  Misc 1
  Option 2

Miscellaneous
  Misc 2
  Option 1
    Option 1 A
    Option 1 B
```

### Drag Drop One Item To Another On A Different Level

Dragging an item of level x onto an item of level y will nest the dragged item under the item it was dropped onto.

Here is an example. Take the following menu tree and drag "Option 1 A" onto "Option 2"

```
Options
  Option 1
    Option 1 A
    Option 1 B
  Option 2

Miscellaneous
  Misc 1
  Misc 2
```

and the result is

```
Options
  Option 1
    Option 1 B
  Option 2
    Option 1 A

Miscellaneous
  Misc 1
  Misc 2
```

### Adding, Editing, Removing Menu Items

Clicking the "New Menu Item" button (under options) will create a new root level menu item.

Clicking the "+" icon on an existing menu item will create a new nested menu item.

Clicking the pencil icon on an existing menu items brings up a dialog to edit that item.

Click the "x" icon on an existing menu item will delete that item *and every nested item, item nested under the nested items, etc...*

#### Required Data Makeup For Menu Items

Every menu item has certain data associated with it. The "Description" is a brief title/name/description for that menu item. Such as "Products." The "Goes To LTID" is the destination LTID and "Goes to XID" is the destination XID. An icon URL is also generated from LTID/XID using fn_entityImage.

Destination URL is an override for LTID/XID and can point to anywhere on the website or anywhere on the web. If Desintation URL is provided, don't provide LTID/XID. If LTID/XID is provided, don't provide Destination URL.

Icon URL is an override for the icon provided by LTID/XID, or a way to provide an icon if Destination URL is used. It is simply a URL pointing to an image anywhere on the site or anywhere on the web.

### Adding, Editing, Deleting Menus

Each menu has a name/title and owner. The owner is the websiteID that owns the menu. The title is simply a brief description of what the menu is used for. Clicking the pencil icon, next to the heading "Navigation Menu" will bring up a dialog to edit the menu name and owner.

Next to the pencil icon there are two more icons. One is "X". This deletes the menu and all menu items. The other is a "list" sort of icon. This navigates to a view of all the menus.

In this view, there is a "+" button in place of the pencil, delete, and list buttons. Clicking this button brings up a dialog to create a new menu.

## Technical Information

### Files

* dragDrop.js - includes necessary javascript to handle drag and drop and ajaxRequests to server
* ecreport_navMenus.ecs - includes server side script to list menus, list a menu and its items, and dialog boxes for the editor
* .sql files - includes procedures to add, edit, and delete menus; procedures to add, edit, and delete menu items; a procedure that handles all the swapping/moving of menu items logic; create table scripts for menu and menu items; table valued functions to retrieve menu items (_full version shows all menu items where as the other shows menu items based on filtering for access rights); and a function to determine a menu item's level.

### HTML/JS/ECS Configuration

For items that are draggable, add class "draggable"; also include "fromLTID" and "fromXID". Optionally include "fromGenericID" for more generic processing.

For items that can be dropped onto (drag targets), add class "dragTarget"; also include "toLTID" and "toXID". Optionally, include "toGenericID" for more generic processing.

When a "draggable" item is dropped onto a "dragTarget" item, an ajax request is sent to the server with the following information:

* draggable item attributes
  * fromLTID
  * fromXID
  * fromGenericID
  * loader
  * ecid
* dragTarget attributes
  * toLTID
  * toXID
  * toGenericID
  * act

### .ecs File Breakdown:

* dt_navMenus \- queries database for list of menus.
* obj_navMenus \- list of menus that exist.
* obj_navMenu \- the current nav menu and its items (this is where reordering occurs).
* obj_navMenu_dragReorder \- handler to pass reordering requests, of every kind, to the SQL server.
* obj_navMenu_new \- create a new nav menu, accessible from list view
* obj_navMenu_edit \- edit an existing nav menu, accessible from record view
* obj_navMenu_delete \- delete an existing nav menu, accessible from record view
* obj_menuItem_new \- create a new item in the menu... handles both root level and nested level
* obj_menuItem_edit \- edit an existing menu item
* obj_menuItem_delete \- delete a menu item
* .js scriptlet - reinitialize dragDrop-ability whenever the items are refreshed on the page
* function contents - what content should be included on the page and when
* function related - what options should appear in the related/options menu and when

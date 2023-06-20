# **Echeveria**

# **A Note on Permissions**

## **Overview**

### **_General_**

At any given time the Realm has a list of subscriptions that signal what information should be downloaded (or synced) from the cloud database. Individual objects within the app are able to then query the realm (which should have all objects that meet subscription criteria), to narrow down what is being put in specific arrays / objects

Subscriptions have a name, a query, and an object Type to retrieve.

As of **06/19/23** the subscriptions need to handle `EcheveriaProfile, EcheveriaGroup`, and `EcheveriaGame` The profiles handle the name and userName of a user, and can appear in the previews of groups and games. The games are needed only on User and Group Profiles. Groups are needed in separate Group windows and profiles

### **_Limitations_**

The process to add a generic subscription is asynchronous, and cannot easily be invoked at any time in the UI.

When adding a subscription, the new query always overrides the current under the same name. There doesn't seem to be a way around this, unless non-realm objects store certain queries themselves, and add them when submitting new subscriptions.

Especially with `EcheveriaGame` profiles will have a lot of data, so downloading all of it at once, and stalling the UI while waiting for that download, is a bad idea. Instead there should be a system to require certain data to be downloaded, wait on that, and throw errors / download requests anytime there is a missing object problem. (currently everything in the UI is force unwrapping with the expectation that its downloaded)

### **_Technologies_**

- `AsyncLoaders` Are `SwiftUI` Views that can be thrown in any View Hierarchy. They perform am async `.task` whenever they appear on screen, and perform another async `.task` when they disappear.

  This is good for updating many subscriptions, especially simple ones that only download the current Users data. Depending on the context (if they can receive an `EcheveriaGroup` or `EcheveriaGame`) they can make more general purpose subscriptions.

  These struggle however, with adding individual subscriptions, A. because it overrides the current subscription, which are often still relevant (ie. keeping your own data), and B. because they have to be called when a View loads, which can be tricky / inconvenient to trigger

- Basic `await` calls. These are good for running the code throughout non-View code, but still struggle with adding individual subscriptions

## **Solutions**

### **_Current Solution_**

For now, each View in the app has its own subscription needs, so each view with a unique set of subscriptions view will get an 'asyncLoader.'

There is potential for making a protocol that forces the views that need special permissions to declare the queries for profiles, groups, and games, that they require.

These permissions for each page are documented below.
There could be mistakes in the permissions needed

### **_ProfileView_**

#### _Profile_

- currentUser
- the profile thats being observed (can be different to currenUser if you're looking at someone elses profile)
- Any user that has won a game in a group that this user is a part of (they appear in the game preview)

#### _Group_

- currentUser's owned Groups
- currentUser's participated in groups (these are automatically stored in that users profile however)

#### _Game_

- currentUser's game

### **_GroupView_**

The search successfully manages itself as of now

#### _Profile_

- currentUser
- On just the list page, group owner Profiles (they will be displayed on the preview)
- On GroupView page, all the members of that group

#### _Group_

- currentUser's owned Groups
- currentUser's participated in groups (these are automatically stored in that users profile however)

#### _Game_

- on GroupView page, All of the games, part of that group, from all its members (don't download every game from every members )

### **_GameView_**

#### _Profile_

- currentUser
- All users in the game's players

#### _Group_

- currentUser's owned Groups
- The group that the game belongs to

#### _Game_

- currentUser's game
- current Game

#### _Misc Thoughts_

it may be possible to detect when a user has requested access to certain information, and simply check that against what is allowed on a current screen. From that add the permission if they're allowed it, or cancel that specific View

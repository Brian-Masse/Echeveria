# **Echeveria**

### **Product Description**
Echeveria is a social platform where friends can create groups to log and share statistics about the games they play together. It is designed to keep track of wins and losses, among other social, ‘bragging right’ data points for groups of friends. 

The core loop of the app revolves around logging game data: after finishing a game with a group of friends (ie. spikeball, super smash bros. etc), someone in the group will record the win, players, and other game-specific data. This is automatically uploaded to the group for everyone to view and is included in a variety of intractable  data visualizations to view the group’s full data. Users also have individual profiles, which allow them to manage their groups,  add friends, and view game data aggregated across all their groups. There are many additional customizations to tailer the app / logging experience for specific social groups and people.

### **Development Process & problem identification**
Echeveria was created as both a social and empirical alternative to other ways of keeping track of game data. Having spent much time playing competitive games with my friends, the question of ‘who exactly was best’ proved evasive, and while tools like excel spreadsheets were great for logging simple statistical representations of skill, they lacked both the nuance to describe game victories and the social dimension of easily viewing that data with friends. Echeveria, like excel, offers the tools to objectively record, view, and gain insights from game data, while still allowing the flexibility to describe game experience and other relevant, non-empirical measures. Layering these features over the framework of a social networking platform makes this unique game logging experience inherently collaborative and social.

### **System Design & Technologies**
Echeveria is built from Swift and SwiftUI on the front end and MongoDB and Realm DeviceSync on the back end. The app follows the MVVM model for all of its object modeling and app flow structuring, however, it uses many features from DeviceSync to extend that design to the backend as well. This means that the app is fully reactionary and automatically syncs all user data across devices. User sign in and authentication is the combination of MongoDB account registration and userDefaults local storage on iPhone. The app  provides basic account control, including account modification and deletion. The social network  is based off a permissioning system that fetches and downloads the correct data from other users / groups at the right time so users can view data not directly owned by them, but cannot read, write, or access that data otherwise. All other work, including visualization computations / interactions, are done on device in native swift. 

## **Chnage log**

### **Version 1.1.2**

#### **Fixes**

- Fixed an issue that caused realm not to load, forcing users to reinstall the app

  

### **Change log for 1.1.0**

#### **New Features**

Added an 'auto fill from last log' to make the game logging process easier

Added a 'Win Rate' display in group data views

#### **Changes**

can no longer view the search page when viewing other user's profiles

any member in a group can edit it

certain text field only bring up a number pad keyboard

All textfields now dynamically respond to the keyboard, making them visible when entering text

#### **Fixes**

fixed an issue that caused a player's winstreak to increase despite them not playing ina game

fixed an issue that prevented games logged within the past 24HR day to display on the game count charts

fixed an issue with the accent color system that displayed the wrong accent across the UI

fixed an issue that showed the 'leave group' button when viewing other user's profiles

fixed an issue that prevented all search results from displaying


### **Version 1.0.0**
Initial Release


## **Important Links**

[Product Page](https://apps.apple.com/us/app/echeveria/id6451054692)

[Privacy Policy Notice](https://doc-hosting.flycricket.io/echeveria-privacy-policy/76379ed8-adfc-4db1-bb39-53691e822eee/privacy)

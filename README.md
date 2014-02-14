#hxgk for HaxeFlixel

The options for integrating Game Center into HaxeFlixel projects are not great. The original HxGK project seems to have largely disappeared from the Internet and NMEX, while full of great features, is an absolute pain to get running in its current state. This project should, hopefully, make basic Game Center integration (leaderboards and achievements) much simpler.

##Instructions

* Install hxgk into a directory:
```git
git clone git@github.com:prestia/hxgk-flixel.git DESTINATION-FOLDER
```
* Add the following to your Project.xml file:
```xml
<include path="DESTINATION-FOLDER" if="ios" />
<dependency name="GameKit.framework" if="ios"/>
```
* Remember to include `import hxgk.Hxgk;` in your .hx files!

##To-Do

This is a ~~brand new~~ hack of a seemingly abandoned extension and not very well tested. It works on my project, but I'm eager for feedback from others. There is now a sample program in the repo, but I haven't had a chance to fully test it.

##WARNING

When testing Game Center apps, there is a bug with the sandboxed Game Center since iOS 7. You can read more about it [here](http://openradar.appspot.com/radar?id=5904850961301504). Essentially, if you hit "Cancel" at Game Center login 3 or more times, the device (hardware or simulated) will automatically cancel all future login requests. This is not a bug with hxgk-flixel. To fix this, you must wipe the device settings, which can be done through the settings app on iOS devices or "Reset Content and Settings..." in the iOS Simulator menu.

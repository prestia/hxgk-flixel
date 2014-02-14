#hxgk for HaxeFlixel

The options for integrating Game Center into HaxeFlixel projects are not great. The original HxGK project seems to have largely disappeared from the Internet and NMEX, while full of great features, is an absolute pain to get running in its current state. This project should, hopefully, make simple Game Center integration (leaderboards and achievements) much simpler.

##Instructions

* Install hxgk into a directory:<br/>```git
git clone git@github.com:prestia/hxgk-flixel.git DESTINATION-FOLDER
```
* Add the following to your Project.xml file:<br/>```xml
<include path="DESTINATION-FOLDER" if="ios" />
<dependency name="GameKit.framework" if="ios"/>
```
* Remember to include `import hxgk.Hxgk;` in your .hx files!

##To-Do

This is a brand new library and not very well tested. It works on my project, but I'm eager for feedback from others. I'd also like to put together some sample projects to help people get up and running.
#hxgk for HaxeFlixel

The options for integrating Game Center into HaxeFlixel projects are not great. The original HxGK project seems to have largely disappeared from the Internet and NMEX, while full of great features, is an absolute pain to get running in its current state. This project should, hopefully, make simple Game Center integration (leaderboards and achievements) much simpler.

##Instructions

<pre>1.</pre> Install hxgk into a directory:
```git
git clone git@github.com:prestia/hxgk-flixel.git DESTINATION-FOLDER
```
<pre>2.</pre> Add the following to your Project.xml file:
```xml
<include path="DESTINATION-FOLDER" if="ios" />
<dependency name="GameKit.framework" if="ios"/>
```
<pre>3.</pre> Remember to include `import hxgk.Hxgk;` in your .hx files!

##To-Do

This is a brand new library and not very well tested. It works on my project, but I'm eager for feedback from others. I'd also like to put together some sample projects to help people get up and running.
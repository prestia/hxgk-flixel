package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 40, FlxG.width, "hxgk-flixel sample");
		t.setFormat(null, 32, FlxColor.WHITE, "center", FlxColor.GRAY, true);
		add(t);
		
		t = new FlxText(0, FlxG.height - 30, FlxG.width, "tap to start");
		t.setFormat(null, 16, FlxColor.WHITE, "center", FlxColor.GRAY, true);
		add(t);

		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (FlxG.mouse.justReleased)
		{
			FlxG.switchState(new PlayState());
		}
	}	
}
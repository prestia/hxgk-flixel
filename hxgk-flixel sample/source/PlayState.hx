/*
 *
 * IMPORTANT: THIS SAMPLE PROGRAM IS NOT YET COMPLETE. IT WILL PROVIDE SOME GUIDANCE, BUT IS FAR FROM PERFECT.
 *
 */

package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/*
 * Don't forget to import hxgk-flixel!
 */
import hxgk.Hxgk;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/*
	 * Definitions
	 */

	/*
	 * Leaderboard Category (You set this when setting up game Center in iTunes Connect)
	 */
	private static inline var LEADERBOARD_CATEGORY:String="1";

	/*
	 * Achievement Id
	 */
	private static inline var ACHIEVEMENT_ID:String="1_Tap";

	/*
	 * Instance Variables
	 */

	/*
	 * Score Text
	 */
	private var txtScore:FlxText;

	/*
	 * UI Offset
	 */
	private var uiOffset:Float;

	/*
	 * Initial Auth Button
	 */
	private var btnAuth:FlxButton;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		Reg.score = 0;
		trace("Sample initialized.  Attempting Game Center Connection.");
		var gcAvailable:Bool=Hxgk.init();
		if (!gcAvailable)
		{
			trace("Game Center not available on this device.");
			return;
		}
		btnAuth = new FlxButton( 20, FlxG.height - 60, "AUTHORIZE", onTryAuthorize );
		add(btnAuth);
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
		super.update();
	}

	/*
	 * Implementation
	 */

	/*
	 * Create UI
	 */
	private function createUI():Void
	{
		txtScore=new FlxText(10, 10, 500, "SCORE: " + Reg.score);
		add(txtScore);
		
		uiOffset=txtScore.y+txtScore.height;
		addButton("Increase Score",onIncreaseScore);
		addButton("Submit Score",onSubmitScore);
		addButton("Show Leaderboard",onShowLeaderboard);
		addButton("Win Achievement",onWinAchievement);
		addButton("Show Achievements",onShowAchievements);
		addButton("Reset Achievements",onResetAchievements);
	}

	/*
	 * Add Button
	 */
	private function addButton(label:String,cb:Void->Void):Void
	{
		var btn:FlxButton=new FlxButton(label,cb);
		btn.y=uiOffset;
		uiOffset+=(btn.height*1.5);
		add(btn);
	}

	//
	// Events
	//

	/** On Auth Changed */
	private function onAuthChanged(authorized:Bool):Void
	{
		trace("AUTH STATE CHANGED: " + authorized);
		if (authorized && btnAuth != null)
		{
			FlxG.safeDestroy(btnAuth);
			createUI();
		}
	}	

	/** On Try Authorize */
	private function onTryAuthorize():Void
	{
		Hxgk.authenticateLocalUser(onAuthChanged);
	}

	/** On Increase Score */
	private function onIncreaseScore():Void
	{
		Reg.score++;
		txtScore.text="SCORE: "+ Reg.score;
	}

	/** On Show Achievements */
	private function onShowAchievements():Void
	{
		Hxgk.showAchievements();
	}

	/** On Show Leaderboard */
	private function onShowLeaderboard():Void
	{
		Hxgk.showLeaderboardForCategory(LEADERBOARD_CATEGORY);
	}

	/** On Submit Score */
	private function onSubmitScore():Void
	{
		Hxgk.reportScoreForCategory(Reg.score,LEADERBOARD_CATEGORY);
	}

	/** On Win Achievement */
	private function onWinAchievement():Void
	{
		Hxgk.reportAchievement(ACHIEVEMENT_ID,100.0);
	}

	/** On Reset */
	private function onResetAchievements():Void
	{
		Hxgk.resetAchievements();
	}
}
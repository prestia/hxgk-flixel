/**
 * Copyright (c) 2011 Milkman Games, LLC <http://www.milkmangames.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

package hxgk;

import flash.Lib;

/** Hxgk */
class Hxgk 
{
	//
	// Definitions
	//

	/** Event IDs */
	private static inline var AUTH_SUCCEEDED:Int=1;
	private static inline var AUTH_FAILED:Int=2;
	private static inline var LEADERBOARD_VIEW_OPENED:Int=3;
	private static inline var LEADERBOARD_VIEW_CLOSED:Int=4;
	private static inline var ACHIEVEMENTS_VIEW_OPENED:Int=5;
	private static inline var ACHIEVEMENTS_VIEW_CLOSED:Int=6;
	private static inline var SCORE_REPORT_SUCCEEDED:Int=7;
	private static inline var SCORE_REPORT_FAILED:Int=8;
	private static inline var ACHIEVEMENT_REPORT_SUCCEEDED:Int=9;
	private static inline var ACHIEVEMENT_REPORT_FAILED:Int=10;
	private static inline var ACHIEVEMENT_RESET_SUCCEEDED:Int=11;
	private static inline var ACHIEVEMENT_RESET_FAILED:Int=12;

	//
	// Static Variables
	//
	
	/** On Ready Callback */
	private static var _onAuthCallback:Dynamic;
	
	/** Initialization State */
	private static var initState:Bool;

	//
	// Public Methods
	//
	
	/**
	 * Initialize HxGK.  You must call this before using other methods.
	 * 
	 * @return	true if Game Center is available on the device, and 
	 * initialized successfully.
	 */
	public static function init():Bool
	{
		if (initState==true)
		{
			throw "HxGK already initialized.";
			return false;
		}
		var result:Bool=untyped hxgk_init_game_kit(hxgk_event_callback);

		initState=result;
		return result;
	}
	
	/**
	 * Attempt to Authenticate the player with the Game Center server.
	 * You should call this after initialization, and wait for the callback
	 * with a positive auth state before using other methods.  If the auth
	 * callback returns false, the user declined to sign in or no network
	 * connection was available.
	 * 
	 * You may wantt to check isuserAuthenticated() before making calls
	 * to display leaderboard or achievement views later, and prompt for 
	 * authentication again before continuing/show a message to this effect.
	 * 
	 * @param	onAuthCallback	a method with the signature Bool->Void that
	 * will be called upon a change in authorization state; 'true' if user
	 * is logged in, 'false' if not.  Authentication state can change over
	 * the lifecycle of your app, so you should be prepared to respond
	 * appropriately even after your initial call.
	 * 
	 */
	public static function authenticateLocalUser(onAuthCallback:Bool->Void):Void
	{
		assertInit();
		_onAuthCallback=onAuthCallback;
		untyped hxgk_authenticate_local_user();
	}

	/**
	 * Checks to see if user is authenticated.
	 */
	public static function isUserAuthenticated():Bool
	{
		var authenticated:Bool=untyped hxgk_is_user_authenticated();
		return authenticated;
	}	

	/**
	 * Shows the standard iOS Achievements View.
	 */
	public static function showAchievements():Void
	{
		assertInit();
		untyped hxgk_show_achievements();
	}
	
	/**
	 * Shows the standard iOS LeaderBoard View for a given category.
	 * 
	 * @param	category	The category ID of the leaderboard you wish to show.
	 * This is set in iTunes Connect.
	 */
	public static function showLeaderboardForCategory(category:String):Void
	{
		assertInit();
		untyped hxgk_show_leaderboard_for_category(category);
	}
	
	/**
	 * Report a score to the Game Center server, for a given category.
	 * 
	 * @param	score	Int value of the score you wish to post.
	 * @param	category	The category ID of the leaderboard you wish to
	 * post a score to.  This is set in iTunes connect.
	 */
	public static function reportScoreForCategory(score:Int,category:String):Void
	{
		assertInit();
		untyped hxgk_report_score_for_category(score,category);
	}
	
	/**
	 * Report achievement progress to the Game Center server.
	 * 
	 * @param	achievementId	The ID of the achievement you want to post.  This is
	 * set in iTunes connect.
	 * @param	completion	The percent completion you wish to post to Game Center for
	 * this award.  Note that this is a float percentage value from 0.0-100.0.  To win
	 * the award now, just post 100.0.  Note that iOS presents no standard UI when an
	 * achievement is awarded so it is up to you to display it to the user.
	 */
	public static function reportAchievement(achievementId:String,completion:Float):Void
	{
		assertInit();
		untyped hxgk_report_achievement(achievementId,completion);
	}
	
	/**
	 * Reset achievements for this user on the server.  No confirmation will be
	 * displayed to the user by iOS, so it's up to you to confirm they really
	 * want to reset their progress.
	 */
	public static function resetAchievements():Void
	{
		assertInit();
		untyped hxgk_reset_achievements();
	}
	
	//
	// Implementation
	//

	/** Callback from CFFI */
	private static function hxgk_event_callback(eventId:Int):Void
	{
		if (eventId == LEADERBOARD_VIEW_CLOSED || eventId == ACHIEVEMENTS_VIEW_CLOSED) {
			trace ('resuming with Lib.resume()');
			Lib.resume();
		}
		trace("HX: received event: "+eventId);
		// TODO: dispatch other events, and callbacks for score/achiev failure
		if (eventId==AUTH_FAILED || eventId==AUTH_SUCCEEDED)
		{
			if (_onAuthCallback!=null)
			{
			trace("call auth");
				_onAuthCallback(eventId==AUTH_SUCCEEDED);
			}
		}
	}
	
	/** Ensure Initialization state */
	private static function assertInit():Void
	{
		if (initState==false)
		{
			throw "Initialize HxGK with Hxgk.init() first.";
		}
	}
	
	// CFFI
	private static var hxgk_is_game_center_available=cpp.Lib.load("hxgk","is_game_center_available",0);
	private static var hxgk_authenticate_local_user=cpp.Lib.load("hxgk","authenticate_local_user",0);
	private static var hxgk_init_game_kit=cpp.Lib.load("hxgk","init_game_kit",1);
	private static var hxgk_show_achievements=cpp.Lib.load("hxgk","show_achievements",0);
	private static var hxgk_show_leaderboard_for_category=cpp.Lib.load("hxgk","show_leaderboard_for_category",1);
	private static var hxgk_report_score_for_category=cpp.Lib.load("hxgk","report_score_for_category",2);
	private static var hxgk_report_achievement=cpp.Lib.load("hxgk","report_achievement",2);
	private static var hxgk_reset_achievements=cpp.Lib.load("hxgk","reset_achievements",0);

	private static var hxgk_is_user_authenticated=cpp.Lib.load("hxgk","is_user_authenticated",0);
	
}
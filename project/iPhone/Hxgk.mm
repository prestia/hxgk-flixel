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

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <GameKit/GameKit.h>
#include <ctype.h>

/** ViewDelegate Objective-C Wrappers
 *
 * As far as I can tell it is not possible to let a vanilla c function
 * take a delegate callback, so we need to create these obj-c objects
 * to wrap the callbacks in.
 *
 */
typedef void (*FunctionType)();

@interface GKViewDelegate : NSObject <GKAchievementViewControllerDelegate,GKLeaderboardViewControllerDelegate>  
{
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

@property (nonatomic) FunctionType onAchievementFinished;
@property (nonatomic) FunctionType onLeaderboardFinished;

@end
	
@implementation GKViewDelegate

@synthesize onAchievementFinished;
@synthesize onLeaderboardFinished;

- (id)init 
{
    self = [super init];
    return self;
}

- (void)dealloc 
{
    [super dealloc];
}

- (void) removeSubviewsAboveIndexZero // <--PLEASE REVISE, IT'S ONLY A HACK
{
	printf("*****running remover \n");
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		
	while([[window subviews] count] > 1) {
		printf("SUBVIEW REMOVED \n");
		[[[window subviews] objectAtIndex:1] removeFromSuperview];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[viewController dismissViewControllerAnimated:YES completion:^(void)
    {
        [viewController.view removeFromSuperview];
		[viewController release];
		[self removeSubviewsAboveIndexZero];
		printf("Hxgk CPP: achievementViewControllerDidFinish, delegate called \n");
		onAchievementFinished();
    }];
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:^(void)
    {
        [viewController.view removeFromSuperview];
		[viewController release];
		[self removeSubviewsAboveIndexZero];
		printf("Hxgk CPP: leaderboardViewControllerDidFinish, delegate called \n");
		onLeaderboardFinished();
    }];
}


@end

namespace hxgk 
{
	//
	// Definitions
	//
	
	/** Event IDs */
	const int AUTH_SUCCEEDED=1;
	const int AUTH_FAILED=2;
	const int LEADERBOARD_VIEW_OPENED=3;
	const int LEADERBOARD_VIEW_CLOSED=4;
	const int ACHIEVEMENTS_VIEW_OPENED=5;
	const int ACHIEVEMENTS_VIEW_CLOSED=6;
	const int SCORE_REPORT_SUCCEEDED=7;
	const int SCORE_REPORT_FAILED=8;
	const int ACHIEVEMENT_REPORT_SUCCEEDED=9;
	const int ACHIEVEMENT_REPORT_FAILED=10;
	const int ACHIEVEMENT_RESET_SUCCEEDED=11;
	const int ACHIEVEMENT_RESET_FAILED=12;
	
	//
	// Function Definitions
	//
	
	bool hxInitGameKit();
	bool hxIsGameCenterAvailable();
	bool hxIsUserAuthenticated();
	void hxAuthenticateLocalUser();
	void registerForAuthenticationNotification();
	void hxShowAchievements();
	void hxResetAchievements();
	void hxReportScoreForCategory(int score, const char *category);
	void hxReportAchievement(const char *achievementId, float percent);
	void hxShowLeaderBoardForCategory(const char *category);
	static void authenticationChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
	void achievementViewDismissed();
	void leaderboardViewDismissed();
	void dispatchHaxeEvent(int eventId);
	extern "C" void hxgk_send_event(int eventId);
	
	//
	// Variables
	//
	
	/** Initialization State */
	static int isInitialized=0;
	
	/** View Delegate */
	GKViewDelegate *ViewDelegate;
	
	//
	// Public Methods
	//
	
	/** Initialize Haxe GK.  Return true if success, false otherwise. */
	bool hxInitGameKit()
	{
		// don't create twice.
		if(isInitialized==1)
		{
			return false;
		}
		
		if (hxIsGameCenterAvailable())
		{
			// create the GameCenter object, and get user.
			printf("CPP hxInitGameKit() got 'yes' from hxIsGameCenterAvailable\n");
			printf("CPP initializing callback delegate\n");
			ViewDelegate=[[GKViewDelegate alloc] init];
			ViewDelegate.onAchievementFinished=&achievementViewDismissed;
			ViewDelegate.onLeaderboardFinished=&leaderboardViewDismissed;
			isInitialized=1;
			return true;
		}
		
		printf("CPP hxInitGameKit() got 'no' from hxIsGameCenterAvailable\n");
		return false;
	}
	
	/** Check if Game Center is available on this device. */
	bool hxIsGameCenterAvailable()
	{
		// Check for presence of GKLocalPlayer API.   
		Class gcClass = (NSClassFromString(@"GKLocalPlayer"));   
		
		// The device must be running running iOS 4.1 or later.   
		NSString *reqSysVer = @"4.1";   
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];   
		BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);   
		
		return (gcClass && osVersionSupported);
	}

	/** Attempt Authentication of the Player */
	void hxAuthenticateLocalUser() 
	{
		printf("CPP HxgK: Auth user\n");
		if(!hxIsGameCenterAvailable())
		{
			printf("CPP Hxgk: game center not available; exiting. \n");
			return;
		}
		
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {      
			if (error == nil)
			{
				registerForAuthenticationNotification();
				printf("CPP Hxgk: You are logged in to game center!! TODO: dispatch event to haxe \n");
				dispatchHaxeEvent(AUTH_SUCCEEDED);
				
			}
			else
			{
				printf("CPP Hxgk: Error occurred logging into gamecenter-\n");
				NSLog(@"  %@", [error userInfo]);
				dispatchHaxeEvent(AUTH_FAILED);
			}
		}];
	}
	
	/** Return true if the local player is logged in */
	bool hxIsUserAuthenticated()
	{
		if ([GKLocalPlayer localPlayer].isAuthenticated)
		{      
			printf("CPP Hxgk:isUserAuthenticated: You are logged in to game center!!\n");
			return true;
		}

		printf("CPP Hxgk:isUserAuthenticated: You are NOT logged in to game center!!\n");
		return false;
	}
	
	/** Report a score to the server for a given category. */
	void hxReportScoreForCategory(int score, const char *category)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *strCategory = [[NSString alloc] initWithUTF8String:category];
		
		GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:strCategory] autorelease];
		if(scoreReporter)
		{
			scoreReporter.value = score;
			
			[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) 
			{   
				if (error != nil)
				{
					printf("CPP Hxgk: Error occurred reporting score-\n");
					NSLog(@"  %@", [error userInfo]);
					dispatchHaxeEvent(SCORE_REPORT_FAILED);
				}
				else 
				{
					printf("CPP Hxgk: Score was successfully sent\n");
					dispatchHaxeEvent(SCORE_REPORT_SUCCEEDED);
				}

			}];   
		}
		[strCategory release];
		[pool drain];
	}
	
	/** Show the Default iOS UI Leaderboard for a given category. */
	void hxShowLeaderBoardForCategory(const char *category)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *strCategory = [[NSString alloc] initWithUTF8String:category];
		
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];  
		UIViewController *glView2 = [[UIViewController alloc] init];
		if (leaderboardController != nil) 
		{
			leaderboardController.category=strCategory;
			leaderboardController.leaderboardDelegate = ViewDelegate;
			[window addSubview: glView2.view];
			[glView2 presentModalViewController: leaderboardController animated: YES];
		}
		//[glView2 release];
		[strCategory release];
		[pool drain];
	}
	
	/** Report achievement progress to the server */
	void hxReportAchievement(const char *achievementId, float percent)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *strAchievement = [[NSString alloc] initWithUTF8String:achievementId];
		
		GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: strAchievement] autorelease];   
		if (achievement)
		{      
			achievement.percentComplete = percent;    
			[achievement reportAchievementWithCompletionHandler:^(NSError *error)
			{
				if (error != nil)
				{
					printf("CPP Hxgk: Error occurred reporting achievement-\n");
					NSLog(@"  %@", [error userInfo]);
					dispatchHaxeEvent(ACHIEVEMENT_REPORT_FAILED);
				}
				else 
				{
					printf("CPP Hxgk: Achievement report successfully sent\n");
					dispatchHaxeEvent(ACHIEVEMENT_REPORT_SUCCEEDED);
				}

			}];
		}
		else 
		{
			printf("CPP Hxgk: Invalid achievement id-\n");
			//TODO: making this callback before function end means it is possible to get in a bad state if you're doing nested calls
			dispatchHaxeEvent(ACHIEVEMENT_REPORT_FAILED);
		}

		
		[strAchievement release];
		[pool drain];
	}
	
	/** Get the available achievements */
	void hxGetAchievements()
	{
		// TODO: will need to alloc and populate a list in a haxe format and return via another callback
	}
	
	/** Show Achievements with Default UI */
	void hxShowAchievements()
	{
		printf("Hxgk CPP: hxShowAchievements() \n");
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];   
		if (achievements != nil)
		{
			printf("Hxgk CPP: achievement view controller created \n");
			achievements.achievementDelegate = ViewDelegate;
			UIViewController *glView2 = [[UIViewController alloc] init];
			[window addSubview: glView2.view];
			[glView2 presentModalViewController: achievements animated: YES];
			// TODO: can we get the delegate to invoke a method properly timed for this event?
			dispatchHaxeEvent(ACHIEVEMENTS_VIEW_OPENED);
		}
	}
	
	/** Reset achievements */
	void hxResetAchievements()
	{
		[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
		 {
			 if (error != nil)
			 {
				 printf("CPP Hxgk: Error occurred resetting achievements-\n");
				 NSLog(@"  %@", [error userInfo]);
				 dispatchHaxeEvent(ACHIEVEMENT_RESET_FAILED);
			 }
			 else 
			 {
				 printf("CPP Hxgk: Achievements successfully reset\n");
				 dispatchHaxeEvent(ACHIEVEMENT_RESET_SUCCEEDED);
			 }
			 
		 }];
	}
	
	
	//
	// Implementation
	//
	
	/** Listen for Authentication Callback */
	void registerForAuthenticationNotification()
	{
		// TODO: need to REMOVE OBSERVER on dispose
		CFNotificationCenterAddObserver
		(
			CFNotificationCenterGetLocalCenter(),
			NULL,
			&authenticationChanged,
			(CFStringRef)GKPlayerAuthenticationDidChangeNotificationName,
			NULL,
			CFNotificationSuspensionBehaviorDeliverImmediately
		 );
	}
	
	/** Notify haXe of an Event */
	void dispatchHaxeEvent(int eventId)
	{
		hxgk_send_event(eventId);
	}
	
	//
	// Callbacks
	//
	
	/** Callback When Achievement View is Closed */
	void achievementViewDismissed()
	{
		printf("CPP Hxgk: achievementViewDismissed()\n");
		dispatchHaxeEvent(ACHIEVEMENTS_VIEW_CLOSED);
	}
	
	/** Callback When Leaderboard View is Closed */
	void leaderboardViewDismissed()
	{
		printf("CPP Hxgk: leaderBoardViewDismissed()\n");
		dispatchHaxeEvent(LEADERBOARD_VIEW_CLOSED);
	}
	
	/** Callback When Authentication Status Has Changed */
	void authenticationChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
	{
		if(!hxIsGameCenterAvailable())
		{
			return;
		}
		
		if ([GKLocalPlayer localPlayer].isAuthenticated)
		{      
			printf("CPP Hxgk: You are logged in to game center:onAuthChanged \n");
		}
		else
		{
			printf("CPP Hxgk: You are NOT logged in to game center!:onAuthChanged \n");
		}
	}
	
}



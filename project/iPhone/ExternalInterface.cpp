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

#include <stdio.h>
#include <hx/CFFI.h>
#include "Hxgk.h"

#define NULL_VAL null()

extern "C" void hxgk_main()
{
	printf("hxgk_main()\n");
}

DEFINE_ENTRY_POINT(hxgk_main);

using namespace hxgk;

AutoGCRoot *hxEventCallback=0;

/** Initialize GameCenter */
static value init_game_kit(value onEvent)
{
	printf("CPP: hx_init_game_kit\n");
	// TODO: do we need to delete this on dispose?
	hxEventCallback=new AutoGCRoot(onEvent);
	return alloc_bool(hxInitGameKit());
}
DEFINE_PRIM(init_game_kit,1);

/** Authenticate Local User */
static value authenticate_local_user()
{
	printf("CPP: hx_authenticate_local_user\n");
	hxAuthenticateLocalUser();
	return alloc_null();
}
DEFINE_PRIM(authenticate_local_user,0);

/** Check if GameCenter is available on the device */
static value is_game_center_available()
{
	printf("CPP: Checking 'is_game_center_available\n");
	return alloc_bool(hxIsGameCenterAvailable());
}
DEFINE_PRIM(is_game_center_available,0);

/** Check if User Is Authenticated */
static value is_user_authenticated()
{
	printf("CPP: Checking 'is_user_authenticated\n");
	return alloc_bool(hxIsUserAuthenticated());
}
DEFINE_PRIM(is_user_authenticated,0);

/** Show The Default iOS Achievement View */
static value show_achievements()
{
	printf("CPP: show_achievements() calling hxShowAchievements()\n");
	hxShowAchievements();
	return alloc_null();
}
DEFINE_PRIM(show_achievements,0);

/** Show Leaderboards For Category */
static value show_leaderboard_for_category(value category)
{
	printf("CPP:show_leaderboard_for_category calling hxShowLeaderBoardForCategory()\n");
	hxShowLeaderBoardForCategory(val_string(category));
	return alloc_null();
}
DEFINE_PRIM(show_leaderboard_for_category,1);

/** Report Score For Category */
static value report_score_for_category(value score, value category)
{
	printf("CPPreport_score_for_category calling hxReportScoreForCategory()\n");
	hxReportScoreForCategory(val_int(score),val_string(category));
	return alloc_null();
}
DEFINE_PRIM(report_score_for_category,2);

/** Report Achievement */
static value report_achievement(value achievementId, value percent)
{
	printf("CPP:report_achievement calling hxReportAchievement()\n");
	hxReportAchievement(val_string(achievementId),val_float(percent));
	return alloc_null();
}
DEFINE_PRIM(report_achievement,2);

/** Reset Achievements */
static value reset_achievements()
{
	printf("CPP reset_achievements calling hxResetAchievements()\n");
	hxResetAchievements();
	return alloc_null();
}
DEFINE_PRIM(reset_achievements,0);

extern "C" 
{
	int hxgk_register_prims()
	{
		printf("CPP: hxgk_register_prims()\n");
		hxgk_main();
		return 0;
	}
	
	void hxgk_send_event(int eventId)
	{
		printf("Send Event: %i\n",eventId);
		val_call1(hxEventCallback->get(),alloc_int(eventId));
	}
}
//
//  MatchPadPopupManager.h
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "BasePadViewController.h"

#import "BasePadPopupManager.h"

@class MatchPadStatsViewController;
@class MatchPadReplaysViewController;
@class TeamStatsViewController;

//@class MatchPadHelpViewController;
//@class MatchPadMasterMenuViewController;

// View types
enum MatchPadPopupViewTypes
{
	MP_POPUP_NONE_ = POPUP_NONE_,
	MP_STATS_POPUP_,
	MP_REPLAYS_POPUP_,
	MP_HELP_POPUP_,
	MP_MASTER_MENU_POPUP_,
	MP_TEAM_STATS_POPUP_,
	MP_BALL_STATS_POPUP_,
	MP_POSSESSION_STATS_POPUP_,
	MP_PITCH_STATS_POPUP_,
};
	
// View alignment

// View alignment
enum MatchPadPopupMenuZones
{
	MP_ZONE_NONE_ = POPUP_ZONE_NONE_,
	MP_ZONE_ALL_ = POPUP_ZONE_ALL_,
	MP_ZONE_BOTTOM_ = 0x1,
	MP_ZONE_TOP_ = 0x2,
	MP_ZONE_CENTRE_ = 0x4,
};


//////////////////////////////////////////////////////////////////////
//  Main window popups

@interface MatchPadMasterMenuManager : BasePadPopupManager
{
}

+(MatchPadMasterMenuManager *)Instance;

@end

@interface MatchPadStatsManager : BasePadPopupManager
{
}

+(MatchPadStatsManager *)Instance;

@end

@interface MatchPadReplaysManager : BasePadPopupManager
{
}

+(MatchPadReplaysManager *)Instance;

@end

@interface MatchPadHelpManager : BasePadPopupManager
{
}

+(MatchPadHelpManager *)Instance;

@end

//////////////////////////////////////////////////////////////////////
//  Stats popups

@interface MatchPadTeamStatsManager : BasePadPopupManager
{
}

+(MatchPadTeamStatsManager *)Instance;

@end

@interface MatchPadBallStatsManager : BasePadPopupManager
{
}

+(MatchPadBallStatsManager *)Instance;

@end

@interface MatchPadPossessionStatsManager : BasePadPopupManager
{
}

+(MatchPadPossessionStatsManager *)Instance;

@end

@interface MatchPadPitchStatsManager : BasePadPopupManager
{
}

+(MatchPadPitchStatsManager *)Instance;

@end


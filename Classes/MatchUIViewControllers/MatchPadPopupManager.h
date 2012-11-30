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
};
	
// View alignment

// View alignment
enum MatchPadPopupMenuZones
{
	MP_ZONE_NONE_ = POPUP_ZONE_NONE_,
	MP_ZONE_ALL_ = POPUP_ZONE_ALL_,
	MP_ZONE_BOTTOM_ = 0x1,
	MP_ZONE_TOP_ = 0x2,
};


@interface MatchPadMasterMenuManager : BasePadPopupManager
{
	id viewController;
	//MatchPadMasterMenuViewController * viewController;
}

+(MatchPadMasterMenuManager *)Instance;

@end

@interface MatchPadStatsManager : BasePadPopupManager
{
	MatchPadStatsViewController * viewController;
}

+(MatchPadStatsManager *)Instance;

@end

@interface MatchPadReplaysManager : BasePadPopupManager
{
	MatchPadReplaysViewController * viewController;
}

+(MatchPadReplaysManager *)Instance;

@end

@interface MatchPadHelpManager : BasePadPopupManager
{
	id viewController;
	//MatchPadHelpViewController * viewController;
}

+(MatchPadHelpManager *)Instance;

@end

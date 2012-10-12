//
//  MidasPopupManager.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "BasePadViewController.h"

#import "BasePadPopupManager.h"

@class MidasMasterMenuViewController;
@class MidasStandingsViewController;
@class MidasCircuitViewController;
@class MidasFollowDriverViewController;
@class MidasCameraViewController;
@class MidasHeadToHeadViewController;
@class MidasMyTeamViewController;
@class MidasVIPViewController;
@class MidasAlertsViewController;
@class MidasSocialController;
@class MidasTwitterViewController;
@class MidasFacebookViewController;
@class MidasChatViewController;
@class MidasSocialViewController;
@class MidasHelpViewController;

// View types
enum MidasPopupViewTypes
{
	MIDAS_POPUP_NONE_ = POPUP_NONE_,
	MIDAS_STANDINGS_POPUP_,
	MIDAS_CIRCUIT_POPUP_,
	MIDAS_FOLLOW_DRIVER_POPUP_,
	MIDAS_CAMERA_POPUP_,
	MIDAS_HEAD_TO_HEAD_POPUP_,
	MIDAS_VIP_POPUP_,
	MIDAS_MY_TEAM_POPUP_,
	MIDAS_ALERTS_POPUP_,
	MIDAS_SOCIAL_MEDIA_POPUP_,
	MIDAS_HELP_POPUP_,
	MIDAS_CHAT_POPUP_,
	MIDAS_MASTER_MENU_POPUP_,
};
	
// View alignment

// View alignment
enum MidasPopupMenuZones
{
	MIDAS_POPUP_ZONE_NONE_ = POPUP_ZONE_NONE_,
	MIDAS_POPUP_ZONE_ALL_ = POPUP_ZONE_ALL_,
	MIDAS_POPUP_ZONE_BOTTOM_ = 0x1,
	MIDAS_POPUP_ZONE_TOP_ = 0x2,
	MIDAS_POPUP_ZONE_SOCIAL_MEDIA_ = 0x4,
	MIDAS_POPUP_ZONE_DATA_AREA_ = 0x8,
	MIDAS_POPUP_ZONE_MY_AREA_ = 0x10,
};


@interface MidasMasterMenuManager : BasePadPopupManager
{
	MidasMasterMenuViewController * viewController;
}

+(MidasMasterMenuManager *)Instance;

@end

@interface MidasStandingsManager : BasePadPopupManager
{
	MidasStandingsViewController * viewController;
}

+(MidasStandingsManager *)Instance;

@end

@interface MidasCircuitViewManager : BasePadPopupManager
{
	MidasCircuitViewController * viewController;
}

+(MidasCircuitViewManager *)Instance;

@end

@interface MidasFollowDriverManager : BasePadPopupManager
{
	MidasFollowDriverViewController * viewController;
}

+(MidasFollowDriverManager *)Instance;

@end

@interface MidasCameraManager : BasePadPopupManager
{
	MidasCameraViewController * viewController;
}

+(MidasCameraManager *)Instance;

@end

@interface MidasHeadToHeadManager : BasePadPopupManager
{
	MidasHeadToHeadViewController * viewController;
}

+(MidasHeadToHeadManager *)Instance;

@end

@interface MidasMyTeamManager : BasePadPopupManager
{
	MidasMyTeamViewController * viewController;
}

+(MidasMyTeamManager *)Instance;

@end

@interface MidasVIPManager : BasePadPopupManager
{
	MidasVIPViewController * viewController;
}

+(MidasVIPManager *)Instance;

@end

@interface MidasHelpManager : BasePadPopupManager
{
	MidasHelpViewController * viewController;
}

+(MidasHelpManager *)Instance;

@end

@interface MidasAlertsManager : BasePadPopupManager
{
	MidasAlertsViewController * viewController;
}

+(MidasAlertsManager *)Instance;

@end

@interface MidasSocialMediaManager : BasePadPopupManager
{
	MidasSocialViewController * viewController;
}

+(MidasSocialMediaManager *)Instance;

@end

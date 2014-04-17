//
//  MatchPadPopupManager.m
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadPopupManager.h"

#import "MatchPadCoordinator.h"
#import "MatchPadStatsViewController.h"
#import "MatchPadReplaysViewController.h"
#import "MatchPadCodingViewController.h"
#import "TeamStatsViewController.h"
#import "PlayerStatsController.h"
#import "PhysicalStatsController.h"
#import "BallViewController.h"
#import "PossessionViewController.h"
#import "PitchViewController.h"
//#import "MatchPadHelpViewController.h"
//#import "MatchPadMasterMenuViewController.h"

#import "BasePadViewController.h"


//////////////////////////////////////////////////////////////////////
//  Main window popups

@implementation MatchPadMasterMenuManager

static MatchPadMasterMenuManager * masterMenuInstance_ = nil;

+(MatchPadMasterMenuManager *)Instance
{
	if(!masterMenuInstance_)
		masterMenuInstance_ = [[MatchPadMasterMenuManager alloc] init];
	
	return masterMenuInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		id viewController = nil;//[MatchPadMasterMenuViewController new];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_MASTER_MENU_POPUP_];
		[self setManagedExclusionZone:MP_ZONE_ALL_];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}

@end

@implementation MatchPadStatsManager

static MatchPadStatsManager * statsInstance_ = nil;

+(MatchPadStatsManager *)Instance
{
	if(!statsInstance_)
		statsInstance_ = [[MatchPadStatsManager alloc] init];
	
	return statsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		MatchPadStatsViewController * viewController = [[MatchPadStatsViewController alloc] initWithNibName:@"MatchPadStatsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_STATS_POPUP_];
		[self setManagedExclusionZone:MP_ZONE_ALL_];
		[self setShowHeadingAtStart:true];
		[managedViewController setAssociatedManager:self];
		[viewController release];
	}
	
	return self;
}

@end

@implementation MatchPadHighlightsManager

static MatchPadHighlightsManager * highlightsInstance_ = nil;

+(MatchPadHighlightsManager *)Instance
{
	if(!highlightsInstance_)
		highlightsInstance_ = [[MatchPadHighlightsManager alloc] init];
	
	return highlightsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		MatchPadReplaysViewController * viewController = [[MatchPadReplaysViewController alloc] initWithNibName:@"MatchPadHighlightsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_HIGHLIGHTS_POPUP_];
		[self setManagedExclusionZone:MP_ZONE_ALL_];
		[self setShowHeadingAtStart:true];
		[managedViewController setAssociatedManager:self];
		[viewController release];
	}
	
	return self;
}

@end

@implementation MatchPadReplaysManager

static MatchPadReplaysManager * replaysInstance_ = nil;

+(MatchPadReplaysManager *)Instance
{
	if(!replaysInstance_)
		replaysInstance_ = [[MatchPadReplaysManager alloc] init];
	
	return replaysInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		MatchPadReplaysViewController * viewController = [[MatchPadReplaysViewController alloc] initWithNibName:@"MatchPadReplaysView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_REPLAYS_POPUP_];
		[self setManagedExclusionZone:MP_ZONE_ALL_];
		[self setShowHeadingAtStart:true];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}

@end

@implementation MatchPadCodingManager

static MatchPadCodingManager * codingInstance_ = nil;

+(MatchPadCodingManager *)Instance
{
	if(!codingInstance_)
		codingInstance_ = [[MatchPadCodingManager alloc] init];
	
	return codingInstance_;
}

-(id)init
{
	if(self = [super init])
	{
		MatchPadCodingViewController * viewController = [[MatchPadCodingViewController alloc] initWithNibName:@"MatchPadCodingView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_CODING_POPUP_];
		[self setManagedExclusionZone:MP_ZONE_ALL_];
		[self setShowHeadingAtStart:true];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}

@end

@implementation MatchPadHelpManager

static MatchPadHelpManager * helpInstance_ = nil;

+(MatchPadHelpManager *)Instance
{
	if(!helpInstance_)
		helpInstance_ = [[MatchPadHelpManager alloc] init];
	
	return helpInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		id viewController = nil;//[MatchPadHelpViewController new];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_HELP_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_ALL_)];
		[self setShowHeadingAtStart:true];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}


@end

@implementation MatchPadSettingsManager

static MatchPadSettingsManager * settingsInstance_ = nil;

+(MatchPadSettingsManager *)Instance
{
	if(!settingsInstance_)
		settingsInstance_ = [[MatchPadSettingsManager alloc] init];
	
	return settingsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		SettingsViewController * viewController = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_SETTINGS_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_CENTRE_)];
		[self setAppearStyle:POPUP_FADE_];
		[self setDismissStyle:POPUP_FADE_];
		[self setShowHeadingAtStart:false];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}


@end


//////////////////////////////////////////////////////////////////////
//  Stats popups

@implementation MatchPadTeamStatsManager

static MatchPadTeamStatsManager * teamStatsInstance_ = nil;

+(MatchPadTeamStatsManager *)Instance
{
	if(!teamStatsInstance_)
		teamStatsInstance_ = [[MatchPadTeamStatsManager alloc] init];
	
	return teamStatsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		TeamStatsViewController * viewController = [[TeamStatsViewController alloc] initWithNibName:@"TeamStatsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_TEAM_STATS_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_CENTRE_)];
		[self setShowHeadingAtStart:false];
		[self setAppearStyle:POPUP_FADE_];
		[self setDismissStyle:POPUP_FADE_];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}


@end

@implementation MatchPadPlayerStatsManager

static MatchPadPlayerStatsManager * playerStatsInstance_ = nil;

+(MatchPadPlayerStatsManager *)Instance
{
	if(!playerStatsInstance_)
		playerStatsInstance_ = [[MatchPadPlayerStatsManager alloc] init];
	
	return playerStatsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		PlayerStatsController * viewController = [[PlayerStatsController alloc] initWithNibName:@"PlayerStatsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_PLAYER_STATS_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_CENTRE_)];
		[self setShowHeadingAtStart:false];
		[self setAppearStyle:POPUP_FADE_];
		[self setDismissStyle:POPUP_FADE_];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}


@end

@implementation MatchPadPhysicalStatsManager

static MatchPadPhysicalStatsManager * physicalStatsInstance_ = nil;

+(MatchPadPhysicalStatsManager *)Instance
{
	if(!physicalStatsInstance_)
		physicalStatsInstance_ = [[MatchPadPhysicalStatsManager alloc] init];
	
	return physicalStatsInstance_;
}

-(id)init
{
	if(self = [super init])
	{
		PhysicalStatsController * viewController = [[PhysicalStatsController alloc] initWithNibName:@"PhysicalStatsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_PHYSICAL_STATS_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_CENTRE_)];
		[self setShowHeadingAtStart:false];
		[self setAppearStyle:POPUP_FADE_];
		[self setDismissStyle:POPUP_FADE_];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}


@end

@implementation MatchPadBallStatsManager

static MatchPadBallStatsManager * ballStatsInstance_ = nil;

+(MatchPadBallStatsManager *)Instance
{
	if(!ballStatsInstance_)
		ballStatsInstance_ = [[MatchPadBallStatsManager alloc] init];
	
	return ballStatsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		BallViewController * viewController = [[BallViewController alloc] initWithNibName:@"BallStatsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_BALL_STATS_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_CENTRE_)];
		[self setShowHeadingAtStart:false];
		[self setAppearStyle:POPUP_FADE_];
		[self setDismissStyle:POPUP_FADE_];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}


@end

@implementation MatchPadPossessionStatsManager

static MatchPadPossessionStatsManager * possessionStatsInstance_ = nil;

+(MatchPadPossessionStatsManager *)Instance
{
	if(!possessionStatsInstance_)
		possessionStatsInstance_ = [[MatchPadPossessionStatsManager alloc] init];
	
	return possessionStatsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		PossessionViewController * viewController = [[PossessionViewController alloc] initWithNibName:@"PossessionStatsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_POSSESSION_STATS_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_CENTRE_)];
		[self setShowHeadingAtStart:false];
		[self setAppearStyle:POPUP_FADE_];
		[self setDismissStyle:POPUP_FADE_];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}

@end

@implementation MatchPadPitchStatsManager

static MatchPadPitchStatsManager * pitchStatsInstance_ = nil;

+(MatchPadPitchStatsManager *)Instance
{
	if(!pitchStatsInstance_)
		pitchStatsInstance_ = [[MatchPadPitchStatsManager alloc] init];
	
	return pitchStatsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		PitchViewController * viewController = [[PitchViewController alloc] initWithNibName:@"PitchStatsView" bundle:nil];
		
		[self setManagedViewController:viewController];
		[self setManagedViewType:MP_PITCH_STATS_POPUP_];
		[self setManagedExclusionZone:(MP_ZONE_CENTRE_)];
		[self setShowHeadingAtStart:false];
		[self setAppearStyle:POPUP_FADE_];
		[self setDismissStyle:POPUP_FADE_];
		[managedViewController setAssociatedManager:self];
		
		[viewController release];
	}
	
	return self;
}

@end


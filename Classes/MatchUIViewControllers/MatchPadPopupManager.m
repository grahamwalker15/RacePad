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
#import "TeamStatsViewController.h"
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

//
//  MidasPopupManager.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasPopupManager.h"

#import "MidasCoordinator.h"
#import "MidasStandingsViewController.h"
#import "MidasCircuitViewController.h"
#import "MidasCameraViewController.h"
#import "MidasFollowDriverViewController.h"

#import "MidasAlertsViewController.h"

#import "MidasDemoViewControllers.h"

#import "BasePadViewController.h"

#import "MidasSocialViewController.h"
#import "MidasTwitterViewController.h"
#import "MidasFacebookViewController.h"
#import "MidasHelpViewController.h"
#import "MidasVIPViewController.h"

@implementation MidasMasterMenuManager

static MidasMasterMenuManager * masterMenuInstance_ = nil;

+(MidasMasterMenuManager *)Instance
{
	if(!masterMenuInstance_)
		masterMenuInstance_ = [[MidasMasterMenuManager alloc] init];
	
	return masterMenuInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [MidasMasterMenuViewController new];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_MASTER_MENU_POPUP_];
		[self setManagedExclusionZone:MIDAS_POPUP_ZONE_ALL_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasStandingsManager

static MidasStandingsManager * standingsInstance_ = nil;

+(MidasStandingsManager *)Instance
{
	if(!standingsInstance_)
		standingsInstance_ = [[MidasStandingsManager alloc] init];
	
	return standingsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasStandingsViewController alloc] initWithNibName:@"MidasStandingsView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_STANDINGS_POPUP_];
		[self setManagedExclusionZone:MIDAS_POPUP_ZONE_TOP_ | MIDAS_POPUP_ZONE_MY_AREA_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasCircuitViewManager

static MidasCircuitViewManager * circuitViewInstance_ = nil;

+(MidasCircuitViewManager *)Instance
{
	if(!circuitViewInstance_)
		circuitViewInstance_ = [[MidasCircuitViewManager alloc] init];
	
	return circuitViewInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasCircuitViewController alloc] initWithNibName:@"MidasCircuitView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_CIRCUIT_POPUP_];
		[self setManagedExclusionZone:MIDAS_POPUP_ZONE_TOP_ | MIDAS_POPUP_ZONE_MY_AREA_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasFollowDriverManager

static MidasFollowDriverManager * followDriverInstance_ = nil;

+(MidasFollowDriverManager *)Instance
{
	if(!followDriverInstance_)
		followDriverInstance_ = [[MidasFollowDriverManager alloc] init];
	
	return followDriverInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasFollowDriverViewController alloc] initWithNibName:@"MidasFollowDriverView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_FOLLOW_DRIVER_POPUP_];
		[self setManagedExclusionZone:MIDAS_POPUP_ZONE_TOP_ | MIDAS_POPUP_ZONE_MY_AREA_];
		[self setOverhang:(CGRectGetWidth([viewController.view bounds]) - CGRectGetWidth([viewController.container bounds]))];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasCameraManager

static MidasCameraManager * cameraInstance_ = nil;

+(MidasCameraManager *)Instance
{
	if(!cameraInstance_)
		cameraInstance_ = [[MidasCameraManager alloc] init];
	
	return cameraInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasCameraViewController alloc] initWithNibName:@"MidasCamerasView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_CAMERA_POPUP_];
		[self setManagedExclusionZone:MIDAS_POPUP_ZONE_TOP_ | MIDAS_POPUP_ZONE_MY_AREA_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasHeadToHeadManager
									   
static MidasHeadToHeadManager * headToHeadInstance_ = nil;
									   
+(MidasHeadToHeadManager *)Instance
{
	if(!headToHeadInstance_)
		headToHeadInstance_ = [[MidasHeadToHeadManager alloc] init];
			
	return headToHeadInstance_;
}
									   
-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasHeadToHeadViewController alloc] initWithNibName:@"MidasDemoImageView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_HEAD_TO_HEAD_POPUP_];
		[self setManagedExclusionZone:MIDAS_POPUP_ZONE_TOP_ | MIDAS_POPUP_ZONE_MY_AREA_];
		[viewController setAssociatedManager:self];
	}
			
	return self;
}
									   
@end

@implementation MidasMyTeamManager
									   
static MidasMyTeamManager * myTeamInstance_ = nil;
									   
+(MidasMyTeamManager *)Instance
{
	if(!myTeamInstance_)
		myTeamInstance_ = [[MidasMyTeamManager alloc] init];
	
	return myTeamInstance_;
}
							   
-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasMyTeamViewController alloc] initWithNibName:@"MidasMyTeamView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_MY_TEAM_POPUP_];
		[self setManagedExclusionZone:MIDAS_POPUP_ZONE_TOP_ | MIDAS_POPUP_ZONE_DATA_AREA_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}
									   
@end
									   

@implementation MidasAlertsManager

static MidasAlertsManager * alertsInstance_ = nil;

+(MidasAlertsManager *)Instance
{
	if(!alertsInstance_)
		alertsInstance_ = [[MidasAlertsManager alloc] init];
	
	return alertsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasAlertsViewController alloc] initWithNibName:@"MidasAlertsView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_ALERTS_POPUP_];
		[self setManagedExclusionZone:(MIDAS_POPUP_ZONE_BOTTOM_ | MIDAS_POPUP_ZONE_TOP_)];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasSocialMediaManager

static MidasSocialMediaManager * socialmediaInstance_ = nil;

+(MidasSocialMediaManager *)Instance
{
	if(!socialmediaInstance_)
		socialmediaInstance_ = [[MidasSocialMediaManager alloc] init];
	
	return socialmediaInstance_;
}

-(id)init
{
	if(self = [super init])
	{
		MidasFacebookViewController *facebookViewController = [MidasFacebookViewController new];
		MidasTwitterViewController *twitterViewController = [MidasTwitterViewController new];
		viewController = [[MidasSocialViewController alloc] initWithViewControllers:@[twitterViewController, facebookViewController]];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_SOCIAL_MEDIA_POPUP_];
		[self setManagedExclusionZone:(MIDAS_POPUP_ZONE_BOTTOM_ | MIDAS_POPUP_ZONE_SOCIAL_MEDIA_ | MIDAS_POPUP_ZONE_TOP_)];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasHelpManager

static MidasHelpManager * helpInstance_ = nil;

+(MidasHelpManager *)Instance
{
	if(!helpInstance_)
		helpInstance_ = [[MidasHelpManager alloc] init];
	
	return helpInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [MidasHelpViewController new];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_HELP_POPUP_];
		[self setManagedExclusionZone:(MIDAS_POPUP_ZONE_BOTTOM_ | MIDAS_POPUP_ZONE_SOCIAL_MEDIA_)];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasVIPManager

static MidasVIPManager * vipInstance_ = nil;

+(MidasVIPManager *)Instance
{
	if(!vipInstance_)
		vipInstance_ = [[MidasVIPManager alloc] init];
	
	return vipInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [MidasVIPViewController new];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_VIP_POPUP_];
		[self setManagedExclusionZone:(MIDAS_POPUP_ZONE_BOTTOM_ | MIDAS_POPUP_ZONE_TOP_)];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end


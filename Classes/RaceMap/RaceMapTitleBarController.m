//
//  RacePadTitleBar.m
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RaceMapTitleBarController.h"
#import "RaceMapCoordinator.h"
#import "TitleBarViewController.h"
#import "AlertViewController.h"
#import "TrackMap.h"
#import "RaceMapSponsor.h"
#import	"BasePadPrefs.h"

#import "UIConstants.h"

@implementation RaceMapTitleBarController

static RaceMapTitleBarController * instance_ = nil;

+(RaceMapTitleBarController *)Instance
{
	if(!instance_)
		instance_ = [[RaceMapTitleBarController alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
	}
	
	return self;
}


- (void)dealloc
{
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) onStartUp
{
}

- (void) displayInViewController:(UIViewController *)viewController SupportCommentary: (bool) supportCommentary
{	
	[super displayInViewController:viewController];
	
	[[titleBarController playStateButton] addTarget:self action:@selector(PlayStatePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateLiveIndicator];
}

- (void) hide
{
	[super hide];
}

- (void) updateTime:(float)time
{
}

- (void) setCurrentLap: (int)lap
{
}

- (int) inqCurrentLap
{
	return 0;
}

- (void) setTrackState:(int)state
{
}

- (IBAction)PlayStatePressed:(id)sender
{
	if([[RaceMapCoordinator Instance] mcServerConnected])
    {
		[[RaceMapCoordinator Instance] mcDisconnect];
    }
    else
    {
        [[RaceMapCoordinator Instance] connectMCServer];
    }
    [self updateLiveIndicator];
}

- (void) updateLiveIndicator
{
	if([[RaceMapCoordinator Instance] mcServerConnected])
		[self showLiveIndicator];
	else
		[self hideLiveIndicator];
    
}

- (void) hideLiveIndicator
{
	UIButton * liveIndicator = [titleBarController playStateButton];
	[liveIndicator setImage:[UIImage imageNamed:@"OfflineIndicator.png"] forState:UIControlStateNormal];
	liveMode = false;
}

@end

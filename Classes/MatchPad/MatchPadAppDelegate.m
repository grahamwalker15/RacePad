//
//  MatchPadAppDelegate.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadAppDelegate.h"
#import "MatchPadCoordinator.h"
#import "MatchPadPopupManager.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadSponsor.h"
#import "MatchPadDatabase.h"

#import "MatchPadVideoViewController.h"

@implementation MatchPadAppDelegate

@synthesize mainViewController;

-(id)init
{
	if(self =[super init])
	{
		[MatchPadSponsor Instance];
		[MatchPadCoordinator Instance];
		[MatchPadTitleBarController Instance];
		[MatchPadDatabase Instance];
		
		tabBarController = nil;
	}
	
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after app launch.
	
	// Start the coordinator, media handler etc.
	[self startBaseServices];
		
	// Create the popup controolers
	[[MatchPadStatsManager Instance] onStartUp];
	[[MatchPadReplaysManager Instance] onStartUp];
	
	[[MatchPadTeamStatsManager Instance] onStartUp];
	
    // Add the home controller's current view as a subview of the window
    [window addSubview:mainViewController.view];
    [window makeKeyAndVisible];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// There's some start-up race condition that means this doesn't display unless we delay slightly
	[[BasePadCoordinator Instance] performSelector:@selector(onDisplayFirstView) withObject:nil afterDelay: 0.1];

    return YES;
}

@end


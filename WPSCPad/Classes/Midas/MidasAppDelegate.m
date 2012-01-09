//
//  MidasAppDelegate.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasAppDelegate.h"

#import "MidasHomeViewController.h"
#import "MidasCoordinator.h"

#import "MidasPopupManager.h"

#import "RacePadClientSocket.h"
#import "BasePadTimeController.h"
#import "RacePadClientSocket.h"
#import "BasePadMedia.h"
#import "RacePadTitleBarController.h"
#import "RacePadSponsor.h"
#import "BasePadPrefs.h"

#import "RacePadDatabase.h"

@implementation MidasAppDelegate

@synthesize window;
@synthesize homeController;
@synthesize tabBarController;

-(id)init
{
	if(self =[super init])
	{
		[RacePadSponsor Instance];
		
		[MidasCoordinator Instance];
		
		[RacePadTitleBarController Instance];
		[RacePadDatabase Instance];
		
		tabBarController= nil;
	}
	
	return self;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after app launch.
	
	// Create the co-ordinator
	[[BasePadCoordinator Instance] onStartUp];
	
	// Create the media handler
	[[BasePadMedia Instance] onStartUp];
	
	// Create the time controller and title bar controller
	[[BasePadTimeController Instance] onStartUp];
	[[BasePadTitleBarController Instance] onStartUp];
	
	// Create the Midas overlay displays
	[[MidasStandingsManager Instance] onStartUp];
	[[MidasCircuitViewManager Instance] onStartUp];
	[[MidasFollowDriverManager Instance] onStartUp];
	[[MidasAlertsManager Instance] onStartUp];
	[[MidasTwitterManager Instance] onStartUp];
	[[MidasFacebookManager Instance] onStartUp];
	[[MidasChatManager Instance] onStartUp];
	
	// Load the prefs
	[BasePadPrefs Instance];
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:homeController.view];
    [window makeKeyAndVisible];
	
	// There's some start-up race condition that means this doesn't display unless we delay slightly
	[[MidasCoordinator Instance] performSelector:@selector(onDisplayFirstView) withObject:nil afterDelay: 0.1];
	// [[BasePadCoordinator Instance] onDisplayFirstView];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	[[BasePadCoordinator Instance] willResignActive];
	[[BasePadPrefs Instance] save];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
	
	[[BasePadCoordinator Instance] didBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[BasePadPrefs Instance] save];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc
{
    [window release];
	
    [super dealloc];
}

@end

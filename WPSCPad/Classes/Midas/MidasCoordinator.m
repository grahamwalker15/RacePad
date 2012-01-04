//
//  MidasCoordinator.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasCoordinator.h"

#import "WorkOffline.h"
#import "midasVideoViewController.h"

@implementation MidasCoordinator

static MidasCoordinator * instance_ = nil;

+(MidasCoordinator *)Instance
{
	if(!instance_)
		instance_ = [[MidasCoordinator alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{
		// Create a view controller for the driver lap times which may be displayed as an overlay
		midasVideoViewController = [[MidasVideoViewController alloc] initWithNibName:@"MidasVideoView" bundle:nil];
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) onStartUp
{	
	[self updateSponsor];
}

- (void) goOffline
{
	if ( workOffline == nil )
		workOffline = [[WorkOffline alloc] initWithNibName:@"MidasWorkOffline" bundle:nil];
	
	[workOffline setAnimatedDismissal:false];
	
	[registeredViewController presentModalViewController:workOffline animated:YES];
}

- (void) onDisplayFirstView
{
	[self goOffline];
}

-(void)displayVideoViewController
{
	// We display the default video view once session is loaded
	
	// Set the style for its presentation
	[registeredViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[registeredViewController setModalPresentationStyle:UIModalPresentationCurrentContext];
	
	// And present it
	[registeredViewController presentModalViewController:midasVideoViewController animated:true];
	
	[self startPlay];
}

-(void)onSessionLoaded
{
	// We display the default video view once session is loaded
	[self performSelector:@selector(displayVideoViewController) withObject:nil afterDelay: 0.1];
}

@end

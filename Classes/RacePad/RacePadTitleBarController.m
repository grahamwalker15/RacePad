    //
//  RacePadTitleBar.m
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadTitleBarController.h"
#import "RacePadCoordinator.h"
#import "TitleBarViewController.h"

@implementation RacePadTitleBarController

static RacePadTitleBarController * instance_ = nil;

+(RacePadTitleBarController *)Instance
{
	if(!instance_)
		instance_ = [[RacePadTitleBarController alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		titleBarController = [[TitleBarViewController alloc] initWithNibName:@"TitleBarView" bundle:nil];
		
		lapCount = 0;
	}
	
	return self;
}


- (void)dealloc
{
	[titleBarController release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) onStartUp
{
}

- (void) displayInViewController:(UIViewController *)viewController
{	
	CGRect super_bounds = [viewController.view bounds];
	CGRect title_controller_bounds = [titleBarController.view bounds];
	
	CGRect frame = CGRectMake(super_bounds.origin.x, super_bounds.origin.y, super_bounds.size.width, title_controller_bounds.size.height);
	[titleBarController.view setFrame:frame];
	
	[viewController.view addSubview:titleBarController.view];
		
	float current_time = [[RacePadCoordinator Instance] currentTime];	
	[self updateTime:current_time];
	
	[[RacePadCoordinator Instance] SetViewDisplayed:titleBarController];
}

- (void) hide
{
	[[RacePadCoordinator Instance] SetViewHidden:titleBarController];
	[titleBarController.view removeFromSuperview];
}

- (void) updateTime:(float)time
{
	if (lapCount <= 0)
	{
		int h = (int)(time / 3600.0); time -= h * 3600;
		int m = (int)(time / 60.0); time -= m * 60;
		int s = (int)(time);
		NSString * time_string = [NSString stringWithFormat:@"%d:%02d:%02d", h, m, s];
		[[titleBarController lapCounter] setTitle:time_string forState:UIControlStateNormal];
	}
}

- (void) setEventName: (NSString *)event
{
	[[titleBarController eventName] setTitle:event forState:UIControlStateNormal];
}

- (void) setLapCount: (int)count
{
	lapCount = count;
}

- (void) setCurrentLap: (int)lap
{
	currentLap = lap;
	
	if (lapCount > 0)
	{
		NSNumber *i = [NSNumber numberWithInt:lap];
		NSNumber *c = [NSNumber	numberWithInt:lapCount];
		NSString *s = @"Lap ";
		s = [s stringByAppendingString:[i stringValue]];
		s = [s stringByAppendingString:@" of "];
		s = [s stringByAppendingString:[c stringValue]];
		[[titleBarController lapCounter] setTitle:s forState:UIControlStateNormal];
	}
}


//////////////////////////////////////////////////////////////////////////////////
// Actions
//////////////////////////////////////////////////////////////////////////////////

- (IBAction)PlayPressed:(id)sender
{
}


@end

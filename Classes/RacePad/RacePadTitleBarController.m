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
#import "AlertViewController.h"
#import "TrackMap.h"
#import "RacePadSponsor.h"

#import "UIConstants.h"

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
		
		alertController = [[AlertViewController alloc] initWithNibName:@"AlertControlView" bundle:nil];
		alertPopover = [[UIPopoverController alloc] initWithContentViewController:alertController];
		[alertPopover setDelegate:self];
		[alertController setParentPopover:alertPopover];
				
		helpController = nil;
		helpPopover = nil;
				
		lapCount = 0;
		
		liveMode = true;
	}
	
	return self;
}


- (void)dealloc
{
	[titleBarController release];
	[helpPopover release];
	[helpController release];
	[alertPopover release];
	[alertController release];
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
	
	[viewController.view addSubview:titleBarController.view];
	
	CGRect frame = CGRectMake(super_bounds.origin.x, super_bounds.origin.y, super_bounds.size.width, title_controller_bounds.size.height);
	[titleBarController.view setFrame:frame];
	
	UIBarButtonItem * alert_button = [titleBarController alertButton];	
	[alert_button setTarget:self];
	[alert_button setAction:@selector(AlertPressed:)];
	
	[[titleBarController playStateButton] addTarget:self action:@selector(AlertPressed:) forControlEvents:UIControlEventTouchUpInside];
	[[titleBarController lapCounter] addTarget:self action:@selector(AlertPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[[titleBarController helpButton] addTarget:self action:@selector(HelpPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	float current_time = [[RacePadCoordinator Instance] currentTime];	
	[self updateTime:current_time];
	
	[self updateSponsor];
		
	[[RacePadCoordinator Instance] SetViewDisplayed:titleBarController];
}

- (void) updateSponsor
{
	[[titleBarController sponsorButton] setImage:[[RacePadSponsor Instance]getSponsorLogo:RPS_LOGO_REGULAR_] forState:UIControlStateNormal];
}

- (void) updateLiveIndicator
{
	if([[RacePadCoordinator Instance] liveMode])
		[self showLiveIndicator];
	else
		[self hideLiveIndicator];
		
}

- (void) hideLiveIndicator
{
	if(liveMode)
	{
		NSMutableArray * items = [[NSMutableArray alloc] init];
		
		UIBarButtonItem * liveIndicator = [titleBarController playStateBarItem];
		
		for (UIBarButtonItem * item in [titleBarController allItems])
		{
			if(item != liveIndicator)
				[items addObject:item];
		}
		
		[[titleBarController toolbar] setItems:items animated:true];
		
		liveMode = false;
	}
}

- (void) showLiveIndicator
{
	if(!liveMode)
	{
		[[titleBarController toolbar] setItems:[titleBarController allItems] animated:true];
		liveMode = true;
	}
}

- (void) hide
{
	[[RacePadCoordinator Instance] SetViewHidden:titleBarController];
	[alertPopover dismissPopoverAnimated:false];
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

- (int) inqCurrentLap
{
	return currentLap;
}

- (void) setTrackState:(int)state
{
	switch (state)
	{
		case TM_TRACK_GREEN:
		default:
			[[titleBarController lapCounter] setDefaultColours];
			[[titleBarController lapCounter] requestRedraw];
			[[titleBarController trackStateButton] setHidden:true];
			break;
		case TM_TRACK_YELLOW:
			[[titleBarController lapCounter] setButtonColour:[UIColor yellowColor]];
			[[titleBarController lapCounter] setTextColour:[UIColor blackColor]];
			[[titleBarController lapCounter] requestRedraw];
			[[titleBarController trackStateButton] setHidden:true];
			break;
		case TM_TRACK_SC:
			[[titleBarController lapCounter] setButtonColour:[UIColor yellowColor]];
			[[titleBarController lapCounter] setTextColour:[UIColor blackColor]];
			[[titleBarController lapCounter] requestRedraw];
			[[titleBarController trackStateButton] setImage:[UIImage imageNamed:@"TitleSC.png"] forState:UIControlStateNormal];
			[[titleBarController trackStateButton] setHidden:false];
			break;
		case TM_TRACK_SCSTBY:
			break;
		case TM_TRACK_SCIN:
			break;
		case TM_TRACK_RED:
			[[titleBarController lapCounter] setButtonColour:[UIColor redColor]];
			[[titleBarController lapCounter] setTextColour:[UIColor whiteColor]];
			[[titleBarController lapCounter] requestRedraw];
			[[titleBarController trackStateButton] setHidden:true];
			break;
		case TM_TRACK_GRID:
			break;
		case TM_TRACK_CHEQUERED:
			[[titleBarController trackStateButton] setImage:[UIImage imageNamed:@"TitleChequered.png"] forState:UIControlStateNormal];
			[[titleBarController trackStateButton] setHidden:false];
			break;
	}
}

//////////////////////////////////////////////////////////////////////////////////
// Actions
//////////////////////////////////////////////////////////////////////////////////

- (IBAction)PlayPressed:(id)sender
{
}

- (IBAction)AlertPressed:(id)sender
{
	if(![alertPopover isPopoverVisible])
	{
		CGSize popoverSize;
		if([[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_)
			popoverSize = CGSizeMake(700,800);
		else
			popoverSize = CGSizeMake(700,600);
		
		[alertPopover setPopoverContentSize:popoverSize];
		
		[alertPopover presentPopoverFromBarButtonItem:[titleBarController alertButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
	}
}

- (IBAction)HelpPressed:(id)sender
{
	RacePadViewController * currentController = [[RacePadCoordinator Instance] registeredViewController];
	
	if(!currentController)
		return;
	
	HelpViewController * newHelpController = [currentController helpController];
	if(!newHelpController)
		return;
	
	if(!helpController || !helpPopover || helpController != newHelpController)
	{
		if(helpController)
		{
			if(helpController != newHelpController)
			{
				[helpController release];	
				helpController = [newHelpController retain];
			}
		}
		else
		{
			helpController = [newHelpController retain];
		}

		if(helpPopover)
			[helpPopover setContentViewController:helpController];
		else
			helpPopover = [[UIPopoverController alloc] initWithContentViewController:helpController];
	}
	
	[helpPopover setDelegate:self];
	[helpController setParentPopover:helpPopover];

	CGSize popoverSize = CGSizeMake(600,650);
	
	[helpPopover setPopoverContentSize:popoverSize];
	[helpPopover presentPopoverFromBarButtonItem:[titleBarController helpBarButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}

@end

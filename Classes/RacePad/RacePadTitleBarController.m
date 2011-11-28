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
#import "CommentaryBubble.h"

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
		alertController = [[AlertViewController alloc] initWithNibName:@"AlertControlView" bundle:nil];
		alertPopover = [[UIPopoverController alloc] initWithContentViewController:alertController];
		[alertPopover setDelegate:self];
		[alertController setParentPopover:alertPopover];
		
		lapCount = 0;

		//Tell race pad co-ordinator that we'll be interested in updates
		[[RacePadCoordinator Instance] AddView:titleBarController WithType:RPC_LAP_COUNT_VIEW_];
	}
	
	return self;
}


- (void)dealloc
{
    [super dealloc];
	[alertPopover release];
	[alertController release];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) onStartUp
{
}

- (void) displayInViewController:(UIViewController *)viewController SupportCommentary: (bool) supportCommentary
{	
	[super displayInViewController:viewController];
	
	UIBarButtonItem * alert_button = [titleBarController alertButton];	
	[alert_button setTarget:self];
	[alert_button setAction:@selector(AlertPressed:)];
	UIBarButtonItem * commentary_button = [titleBarController commentaryButton];	
	[commentary_button setTarget:self];
	[commentary_button setAction:@selector(CommentaryPressed:)];
	commentary_button.enabled = supportCommentary && [[CommentaryBubble Instance] bubblePref];
	
	[[titleBarController playStateButton] addTarget:self action:@selector(PlayStatePressed:) forControlEvents:UIControlEventTouchUpInside];
	[[titleBarController timeCounter] addTarget:self action:@selector(AlertPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) hide
{
	[alertPopover dismissPopoverAnimated:false];
	[super hide];
}

- (void) updateTime:(float)time
{
	if (lapCount <= 0)
	{
		[super updateTime:time];
	}
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
		[[titleBarController timeCounter] setTitle:s forState:UIControlStateNormal];
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
			[[titleBarController timeCounter] setDefaultColours];
			[[titleBarController timeCounter] requestRedraw];
			[[titleBarController trackStateButton] setHidden:true];
			break;
		case TM_TRACK_YELLOW:
			[[titleBarController timeCounter] setButtonColour:[UIColor yellowColor]];
			[[titleBarController timeCounter] setTextColour:[UIColor blackColor]];
			[[titleBarController timeCounter] requestRedraw];
			[[titleBarController trackStateButton] setHidden:true];
			break;
		case TM_TRACK_SC:
			[[titleBarController timeCounter] setButtonColour:[UIColor yellowColor]];
			[[titleBarController timeCounter] setTextColour:[UIColor blackColor]];
			[[titleBarController timeCounter] requestRedraw];
			[[titleBarController trackStateButton] setImage:[UIImage imageNamed:@"TitleSC.png"] forState:UIControlStateNormal];
			[[titleBarController trackStateButton] setHidden:false];
			break;
		case TM_TRACK_SCSTBY:
			break;
		case TM_TRACK_SCIN:
			break;
		case TM_TRACK_RED:
			[[titleBarController timeCounter] setButtonColour:[UIColor redColor]];
			[[titleBarController timeCounter] setTextColour:[UIColor whiteColor]];
			[[titleBarController timeCounter] requestRedraw];
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

- (IBAction)AlertPressed:(id)sender
{
	if(![alertPopover isPopoverVisible])
	{
		CGSize popoverSize;
		if([[BasePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_)
			popoverSize = CGSizeMake(700,800);
		else
			popoverSize = CGSizeMake(700,600);
		
		[alertPopover setPopoverContentSize:popoverSize];
		
		[alertPopover presentPopoverFromBarButtonItem:[titleBarController alertButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
	}
}

- (IBAction)PlayStatePressed:(id)sender
{
	if([[BasePadCoordinator Instance] connectionType] == BPC_SOCKET_CONNECTION_)
	{
		if ( ![[BasePadCoordinator Instance] liveMode] )
		{
			[[BasePadCoordinator Instance] setPlaybackRate:1.0];
			[[BasePadCoordinator Instance] goLive:true];
		}
	}
	else
	{
		[self AlertPressed:sender];
	}
}

- (IBAction)CommentaryPressed:(id)sender
{
	[[CommentaryBubble Instance] toggleShow];
}

@end

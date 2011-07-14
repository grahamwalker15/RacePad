//
//  MatchPadTitleBar.m
//  MatchPad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadTitleBarController.h"
#import "MatchPadCoordinator.h"
#import "MatchPadDatabase.h"
#import "TitleBarViewController.h"
#import "MatchPadSponsor.h"
#import "AlertViewController.h"

#import "UIConstants.h"

@implementation MatchPadTitleBarController

static MatchPadTitleBarController * instance_ = nil;

+(MatchPadTitleBarController *)Instance
{
	if(!instance_)
		instance_ = [[MatchPadTitleBarController alloc] init];
	
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

		//Tell match pad co-ordinator that we'll be interested in updates
		[[MatchPadCoordinator Instance] AddView:titleBarController WithType:MPC_SCORE_VIEW_];
	}
	
	return self;
}


- (void)dealloc
{
	[homeTeam release];
	[awayTeam release];
	[alertPopover release];
	[alertController release];
    [super dealloc];
}

- (void) displayInViewController:(UIViewController *)viewController
{	
	[super displayInViewController:viewController];
	
	UIBarButtonItem * alert_button = [titleBarController alertButton];	
	[alert_button setTarget:self];
	[alert_button setAction:@selector(AlertPressed:)];
	
	[[titleBarController playStateButton] addTarget:self action:@selector(AlertPressed:) forControlEvents:UIControlEventTouchUpInside];
	[[titleBarController timeCounter] addTarget:self action:@selector(AlertPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) hide
{
	[alertPopover dismissPopoverAnimated:false];
	[super hide];
}

- (void) updateEvent
{
	NSString *t = [NSString stringWithFormat:@"%@ %d - %d %@", [[MatchPadDatabase Instance]homeTeam], homeScore, awayScore, [[MatchPadDatabase Instance]awayTeam]];
	[self setEventName:t];
}

- (void) setScore: (int)home Away: (int)away
{
	homeScore = home;
	awayScore = away;
	[self updateEvent];
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

@end

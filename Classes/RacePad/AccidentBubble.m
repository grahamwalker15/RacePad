//
//  AccidentBubble.m
//  BasePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AccidentBubble.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "ElapsedTime.h"
#import "BasePadTimeController.h"
#import "BasePadPrefs.h"
#import "AlertData.h"

#import "UIConstants.h"

@implementation AccidentBubble

@synthesize bubblePref;

static AccidentBubble * instance_ = nil;

+(AccidentBubble *)Instance
{
	if ( !instance_ )
		instance_ = [[AccidentBubble alloc] init];
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		accidentController = [[AccidentBubbleViewController alloc] initWithNibName:@"AccidentBubbleView" bundle:nil];
		accidentView = [accidentController view]; // Force the view to be loaded

		bubblePref = true;
		NSNumber *v = [[BasePadPrefs Instance]getPref:@"accidentPref"];
		int i = [v intValue];
		bubblePref = (i == 1);
		accidentView = nil;
		
		[[RacePadCoordinator Instance] AddView:accidentController.accidentView WithType:RPC_ACCIDENT_VIEW_];
	}
	
	return self;
}


- (void)dealloc
{
	[accidentController release];
	[accidentPopover release];
	[passThroughViews release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) allowBubbles:(UIView *)view
{
	bool shown = accidentView && accidentController.shown;
	accidentView = view;
	[[BasePadCoordinator Instance] SetViewDisplayed:accidentController.accidentView]; // It isn't actually displayed - but it's as if it is
	[accidentController.view removeFromSuperview];
	[accidentController popDown:false];
	[view addSubview:accidentController.view];
	if ( shown )
		[self showNow];
}

- (void) noBubbles
{
	accidentView = nil;
	[[RacePadCoordinator Instance] SetViewHidden:accidentController.accidentView];
	[accidentController.view removeFromSuperview];
	[accidentController popDown:false];
}

- (void)showNow
{
	if ( bubblePref )
	{
		CGRect super_bounds = [accidentView bounds];
		CGRect bubble_bounds = [accidentController.view bounds];
		
		// Position where we want it - popUp will fade it in
		[accidentController.view setAlpha:0.0];
		bubble_bounds = CGRectMake(super_bounds.origin.x + super_bounds.size.width - bubble_bounds.size.width - 20, super_bounds.origin.y + super_bounds.size.height - 50, bubble_bounds.size.width, 10);
		
		[accidentController.view setFrame:bubble_bounds];
		[accidentController popUp];
	}
}

- (void)showIfNeeded
{
	if(!accidentController.shown && accidentView && !shownBeforeRotate)
	{
		int rowCount, firstRow;
		[accidentController.accidentView countRows:&rowCount FirstRow:&firstRow];
		
		if ( rowCount > 0 )
		{
			[self showNow];
		}
	}
}

- (void) popDown
{
	[accidentController popDown:true];
	AlertData * data;
	data = [[RacePadDatabase Instance] accidents];	
	int count = [data itemCount];
	for ( int i = 0; i < count; i++ )
	{
		AlertDataItem *item = [data itemAtIndex:i];
		item.seen = true;
	}
}

- (void)toggleShow
{
	if(accidentController.shown )
	{
		[self popDown];
	}
	else if ( accidentView )
	{
		int rowCount, firstRow;
		[accidentController.accidentView countRows:&rowCount FirstRow:&firstRow];
		[self showNow];
	}
}

- (void) willRotateInterface
{
	shownBeforeRotate = accidentView && accidentController.shown;
	[self popDown];
}

- (void) didRotateInterface
{
	[accidentController resetWidth];
	if ( shownBeforeRotate )
	{
		[self showNow];
	}
	shownBeforeRotate = false;
}


@end

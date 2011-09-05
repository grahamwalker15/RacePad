//
//  CommentaryBubble.m
//  BasePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CommentaryBubble.h"
#import "BasePadCoordinator.h"
#import "ElapsedTime.h"
#import "BasePadTimeController.h"

#import "UIConstants.h"

@implementation CommentaryBubble

@synthesize bubblePref;

static CommentaryBubble * instance_ = nil;

static int showLastNSecs = 8;
static int fadeOffAfter = 8;

+(CommentaryBubble *)Instance
{
	if ( !instance_ )
		instance_ = [[CommentaryBubble alloc] init];
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		commentaryController = [[CommentaryBubbleViewController alloc] initWithNibName:@"CommentaryBubbleView" bundle:nil];
		bubbleView = [commentaryController view]; // Force the view to be loaded
		bubbleView = nil;
		bubblePref = true;
		commentaryController.commentaryView.minPriority = 3;
		
		/*
		commentaryPopover = [[UIPopoverController alloc] initWithContentViewController:commentaryController];
		[commentaryPopover setDelegate:self];
		[commentaryController setParentPopover:commentaryPopover];
		passThroughViews = [[NSMutableArray alloc] init];
		[passThroughViews addObject:[[[BasePadTimeController Instance] timeController] view] ];
		commentaryPopover.passthroughViews = passThroughViews;
		*/

		[[BasePadCoordinator Instance] AddView:commentaryController.commentaryView WithType:BPC_COMMENTARY_VIEW_];
	}
	
	return self;
}


- (void)dealloc
{
	[commentaryController release];
	[commentaryPopover release];
	[passThroughViews release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) allowBubbles:(UIView *)view BottomRight: (bool) br
{
	bubbleView = view;
	bottomRight = br;
	[[BasePadCoordinator Instance] SetViewDisplayed:commentaryController.commentaryView]; // It isn't actually displayed - but it's as if it is
	[commentaryController.view removeFromSuperview];
	[commentaryController popDown:false];
	[view addSubview:commentaryController.view];
}

- (void) noBubbles
{
	bubbleView = nil;
	[[BasePadCoordinator Instance] SetViewHidden:commentaryController.commentaryView];
	[commentaryController.view removeFromSuperview];
	[commentaryController popDown:false];
}

- (void)showNow
{
	if ( bubblePref )
	{
		CGRect super_bounds = [bubbleView bounds];
		CGRect bubble_bounds = [commentaryController.view bounds];
		if ( bottomRight )
			bubble_bounds = CGRectMake(super_bounds.origin.x + super_bounds.size.width - bubble_bounds.size.width - 20, super_bounds.origin.y + super_bounds.size.height - 50, bubble_bounds.size.width, 10);
		else
			bubble_bounds = CGRectMake(super_bounds.origin.x + 20, super_bounds.origin.y + 50, bubble_bounds.size.width, bubble_bounds.size.height);
		[commentaryController.view setFrame:bubble_bounds];
		commentaryController.growUp = bottomRight;
		[commentaryController popUp];
		popdownTimer = [NSTimer scheduledTimerWithTimeInterval:fadeOffAfter target:self selector:@selector(popdownTimerUpdate:) userInfo:nil repeats:NO];
	}
}

- (void)showIfNeeded
{
	if(!commentaryController.shown && bubbleView)
	{
		float timeNow = [[BasePadCoordinator Instance] playTime];
		int rowCount, firstRow;
		
		if ( [[BasePadCoordinator Instance] helpMasterPlaying] )
			commentaryController.commentaryView.timeWindow = timeNow - showLastNSecs;
		else
			commentaryController.commentaryView.timeWindow = 0;
		[commentaryController.commentaryView countRows:&rowCount FirstRow:&firstRow];
		if ( ( timeNow < commentaryController.commentaryView.firstDisplayedTime && commentaryController.commentaryView.firstMessageTime < commentaryController.commentaryView.firstDisplayedTime )
		  || ( timeNow > commentaryController.commentaryView.lastDisplayedTime && commentaryController.commentaryView.latestMessageTime > commentaryController.commentaryView.lastDisplayedTime ) )
		{
			if ( rowCount > 0 )
			{
				[self showNow];
			}
		}
	}
}

- (void) popDown
{
	[commentaryController popDown:true];
	if(popdownTimer)
	{
		[popdownTimer invalidate];
		popdownTimer = nil;
	}
}

- (void)toggleShow
{
	if(commentaryController.shown )
	{
		[self popDown];
	}
	else if ( bubbleView)
	{
		int rowCount, firstRow;
		commentaryController.commentaryView.timeWindow = 0;
		[commentaryController.commentaryView countRows:&rowCount FirstRow:&firstRow];
		[self showNow];
	}
}

- (void) popdownTimerUpdate: (NSTimer *)theTimer
{
	if ( commentaryController.shown )
	{
		double last_update = commentaryController.commentaryView.lastUpdateTime;
		double time_now = [ElapsedTime TimeOfDay];
		int showFor = fadeOffAfter;
		if ( commentaryController.commentaryView.timeWindow > 0
		  && commentaryController.commentaryView.lastRowCount > 5 )
			showFor = (int) (showFor * 1.5 + 0.5);
		if ( time_now - last_update >= showFor )
		{
			[commentaryController popDown:true];
			popdownTimer = nil;
		}
		else
			popdownTimer = [NSTimer scheduledTimerWithTimeInterval:last_update + showFor - time_now target:self selector:@selector(popdownTimerUpdate:) userInfo:nil repeats:NO];
	}
}

- (void) resetBubbleTimings
{
	[commentaryController.commentaryView resetTimings];
}

@end

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
		//Tell match pad co-ordinator that we'll be interested in updates
		[[MatchPadCoordinator Instance] AddView:titleBarController WithType:MPC_SCORE_VIEW_];
	}
	
	return self;
}


- (void)dealloc
{
	[homeTeam release];
	[awayTeam release];
    [super dealloc];
}

- (void) displayInViewController:(UIViewController *)viewController
{	
	[super displayInViewController:viewController];
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

@end

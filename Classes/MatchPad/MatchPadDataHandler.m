//
//  MatchPadDataHandler.m
//  MatchPad
//
//  Created by Mark Riches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadDataHandler.h"
#import "DataStream.h"
#include "MatchPadCoordinator.h"
#include "MatchPadDatabase.h"
#include "MatchPadTitleBarController.h"
#include "MatchPadSponsor.h"
#import "Pitch.h"

@implementation MatchPadDataHandler

- (id) init
{
	[super init];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void)handleCommand:(int) command
{
	switch (command)
	{
		case MPSC_EVENT_:
		{
			MatchPadDatabase *database = [MatchPadDatabase Instance];
			NSString *string = [stream PopString];
			[ database setEventName:string];
			[[MatchPadTitleBarController Instance] setEventName:string];
			break;
		}

		case MPSC_PITCH_: // Pitch
		{
			Pitch *pitch = [[MatchPadDatabase Instance] pitch];
			[pitch loadPitch:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_PITCH_VIEW_];
			break;
		}
		default:
			[super handleCommand:command];
	}
}

@end

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
#import "Possession.h"

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

- (bool) okVersion
{
	return versionNumber <= MATCH_PAD_INTERFACE_VERSION;
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
		case MPSC_TEAMS_:
		{
			NSString *home = [stream PopString];
			NSString *away = [stream PopString];
			[[MatchPadDatabase Instance] setHomeTeam:home];
			[[MatchPadDatabase Instance] setAwayTeam:away];
			break;
		}
			
		case MPSC_PITCH_: // Pitch
		{
			Pitch *pitch = [[MatchPadDatabase Instance] pitch];
			[pitch loadPitch:stream AllNames:false];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_PITCH_VIEW_];
			break;
		}
		case MPSC_PITCH_MOVE_: // PitchMove
		{
			Pitch *pitch = [[MatchPadDatabase Instance] pitch];
			[pitch loadPitch:stream AllNames:false];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_PITCH_VIEW_];
			break;
		}
		case MPSC_POSITIONS_: // Positions
		{
			Positions *positions = [[MatchPadDatabase Instance] positions];
			[positions loadPositions:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_PITCH_VIEW_];
			break;
		}
			
		case MPSC_SCORE_:
		{
			int home = [stream PopInt];
			int away = [stream PopInt];
			[[MatchPadTitleBarController Instance] setScore:home Away:away];
			break;
		}
			
		case MPSC_WHOLE_PLAYER_STATS_:
		{
			TableData *player_stats = [[MatchPadDatabase Instance] playerStatsData];
			[player_stats loadData:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_PLAYER_STATS_VIEW_];
			break;
		}
		case MPSC_UPDATE_PLAYER_STATS_:
		{
			TableData *player_stats = [[MatchPadDatabase Instance] playerStatsData];
			[player_stats updateData:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_PLAYER_STATS_VIEW_];
			break;
		}
		case MPSC_PLAYER_GRAPH_:
		{
			PlayerGraph *playerGraph = [[MatchPadDatabase Instance] playerGraph];
			[playerGraph loadGraph:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_PLAYER_GRAPH_VIEW_];
			break;
		}
		case MPSC_MESSAGES_: // Alerts
		{
			AlertData *alertData = [[MatchPadDatabase Instance] alertData];
			[alertData loadData:stream];
			break;
		}
		case MPSC_POSSESSION_: // Possession
		{
			Possession *possession = [[MatchPadDatabase Instance] possession];
			[possession loadData:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_POSSESSION_VIEW_];
			break;
		}
		case MPSC_MOVES_: // Moves
		{
			Moves *moves = [[MatchPadDatabase Instance] moves];
			[moves loadData:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_MOVE_VIEW_];
			break;
		}
		case MPSC_BALL_: // Ball
		{
			Ball *ball = [[MatchPadDatabase Instance] ball];
			[ball loadData:stream];
			[[MatchPadCoordinator Instance] RequestRedrawType:MPC_BALL_VIEW_];
			break;
		}
		default:
			[super handleCommand:command];
	}
}

@end

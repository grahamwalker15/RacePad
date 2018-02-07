//
//  MatchState.h
//  MatchPad
//
//  Created by Gareth Griffith on 12/12/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MatchState : NSObject
{
	int homeScore;
	int awayScore;
}

@property (assign) int homeScore;
@property (assign) int awayScore;

@end

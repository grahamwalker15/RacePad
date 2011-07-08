//
//  MatchPadTitleBar.h
//  MatchPad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadTitleBarController.h"

@interface MatchPadTitleBarController : BasePadTitleBarController
{
	NSString *homeTeam;
	NSString *awayTeam;
	
	int homeScore;
	int awayScore;
}

+ (MatchPadTitleBarController *)Instance;

- (void) setScore: (int)home Away: (int)away;

@end

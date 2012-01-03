//
//  MatchPadAppDelegate.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadAppDelegate.h"
#import "MatchPadCoordinator.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadSponsor.h"
#import "MatchPadDatabase.h"

@implementation MatchPadAppDelegate

-(id)init
{
	if(self =[super init])
	{
		[MatchPadSponsor Instance];
		[MatchPadCoordinator Instance];
		[MatchPadTitleBarController Instance];
		[MatchPadDatabase Instance];
	}
	
	return self;
}

@end


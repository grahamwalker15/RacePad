//
//  MatchPadTitleBar.m
//  MatchPad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadTitleBarController.h"
#import "MatchPadCoordinator.h"
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
	}
	
	return self;
}


- (void)dealloc
{
    [super dealloc];
}

@end

//
//  RacePadAppDelegate.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadAppDelegate.h"
#import "RacePadClientSocket.h"
#import "RacePadCoordinator.h"
#import "BasePadMedia.h"
#import "RacePadTitleBarController.h"
#import "RacePadSponsor.h"
#import "BasePadPrefs.h"
#import "RacePadDatabase.h"

@implementation RacePadAppDelegate

-(id)init
{
	if(self =[super init])
	{
		[RacePadSponsor Instance];
		[RacePadCoordinator Instance];
		[RacePadTitleBarController Instance];
		[RacePadDatabase Instance];
	}
	
	return self;
}

@end


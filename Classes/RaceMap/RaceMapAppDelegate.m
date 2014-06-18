//
//  RacePadAppDelegate.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RaceMapAppDelegate.h"
#import "RaceMapClientSocket.h"
#import "RaceMapCoordinator.h"
#import "BasePadMedia.h"
#import "RaceMapTitleBarController.h"
#import "RaceMapSponsor.h"
#import "BasePadPrefs.h"
#import "RaceMapData.h"

@implementation RacePadAppDelegate

-(id)init
{
	if(self =[super init])
	{
		[RaceMapSponsor Instance];
		[RaceMapCoordinator Instance];
		[RaceMapTitleBarController Instance];
		[RaceMapData Instance];
	}
	
	return self;
}

@end


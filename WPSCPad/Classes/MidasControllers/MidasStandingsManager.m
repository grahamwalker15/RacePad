//
//  MidasStandingsManager.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasStandingsManager.h"

#import "MidasCoordinator.h"
#import "MidasStandingsViewController.h"
#import "BasePadViewController.h"

@implementation MidasStandingsManager

static MidasStandingsManager * instance_ = nil;

@synthesize standingsViewController;

+(MidasStandingsManager *)Instance
{
	if(!instance_)
		instance_ = [[MidasStandingsManager alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{			
		standingsViewController = [[MidasStandingsViewController alloc] initWithNibName:@"MidasStandingsView" bundle:nil];
		[self setManagedViewController:standingsViewController];
	}
	
	return self;
}


- (void)dealloc
{
	[standingsViewController release];
	[super dealloc];
}

@end

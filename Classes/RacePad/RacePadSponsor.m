//
//  RacePadCSponsor.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadSponsor.h"
#import "RacePadPrefs.h"

@implementation RacePadSponsor

@synthesize sponsor;

static RacePadSponsor * instance_ = nil;

+(RacePadSponsor *)Instance
{
	if(!instance_)
		instance_ = [[RacePadSponsor alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{
		sponsor = RPS_UNKNOWN_;
		NSString *s = [[RacePadPrefs Instance] getPref:@"sponsor"];
		if ( s && [s length] )
			[self setSponsorName:s];
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) setSponsorName: (NSString *)name
{
	if ( [name compare:@"Mercedes"] == NSOrderedSame )
		sponsor = RPS_MERCEDES_;
	else if ( [name compare:@"FiA"] == NSOrderedSame )
		sponsor = RPS_FIA_;
	else
		sponsor = RPS_UNKNOWN_;
	
	[[RacePadPrefs Instance] setPref:@"sponsor" Value:name];
	[[RacePadPrefs Instance] save];
}

- (UIImage *) getSponsorLogo: (unsigned char)logo
{
	if ( logo == RPS_LOGO_REGULAR_ )
	{
		if ( sponsor == RPS_MERCEDES_ )
			return [UIImage imageNamed:@"MGPLogo.png"];
		else if ( sponsor == RPS_FIA_ )
			return [UIImage imageNamed:@"LogoFIA.png"];
	}
	else if ( logo == RPS_LOGO_BIG_ )
	{
		if ( sponsor == RPS_MERCEDES_ )
			return [UIImage imageNamed:@"MGPLogoBig.png"];
		else if ( sponsor == RPS_FIA_ )
			return [UIImage imageNamed:@"LogoFIA.png"];
	}
	
	return [UIImage imageNamed:@"RacePadLogo.png"];
}

- (bool) supportsTab: (unsigned char)tab
{
	if ( sponsor == RPS_UNKNOWN_ )
		return true;

	if ( sponsor == RPS_MERCEDES_ )
		return true;
	
	if ( tab == RPS_DRIVER_LIST_TAB_
	  || tab == RPS_TRACK_MAP_TAB_
	  || tab == RPS_VIDEO_TAB_
	  || tab == RPS_DRIVER_TAB_
	  || tab == RPS_SETTINGS_TAB_ )
		return true;
	
	return false;
}

@end



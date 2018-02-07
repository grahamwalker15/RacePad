//
//  RacePadCSponsor.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadSponsor.h"
#import "BasePadPrefs.h"
#import "RacePadDatabase.h"
#import "RacePadCoordinator.h"

@implementation RacePadSponsor

@synthesize location;

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
		location = RPS_GARAGE_;
		NSNumber *v = [[BasePadPrefs Instance] getPref:@"sponsorLocation"];
		if ( v )
		{
			location = (unsigned char)[v intValue];
		}
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (int) allTabCount
{
	return RPS_ALL_TABS_;
}

- (void) setSponsorName: (NSString *)name
{
	if ( [name compare:@"Mercedes"] == NSOrderedSame )
		sponsor = RPS_MERCEDES_;
	else if ( [name compare:@"FiA"] == NSOrderedSame )
		sponsor = RPS_FIA_;
	else if ( [name compare:@"Williams"] == NSOrderedSame )
		sponsor = RPS_WILLIAMS_;
	else
		sponsor = RPS_UNKNOWN_;
	
	[[BasePadPrefs Instance] setPref:@"sponsor" Value:name];
	[[BasePadPrefs Instance] save];
}

- (bool) supportsLocation
{
	if ( sponsor == RPS_MERCEDES_ )
		return true;
	
	return false;
}

- (void) setLocation: (unsigned char)v
{
	location = v;
	[[BasePadPrefs Instance]setPref:@"sponsorLocation" Value:[NSNumber numberWithInt: v]];
	[[BasePadPrefs Instance] save];
}

- (UIImage *) getSponsorLogo: (unsigned char)logo
{
	if ( logo == BPS_LOGO_REGULAR_ )
	{
		if ( sponsor == RPS_MERCEDES_ )
			if ( location == RPS_GARAGE_ )
				return [UIImage imageNamed:@"MGPLogo.png"];
			else
				return [UIImage imageNamed:@"UBSLogo.png"];
		else if ( sponsor == RPS_FIA_ )
			return [UIImage imageNamed:@"FIALogo.png"];
		else if ( sponsor == RPS_WILLIAMS_ )
			return [UIImage imageNamed:@"WilliamsLogo.png"];
		else
			return [UIImage imageNamed:@"RacePadLogo.png"];
	}
	else if ( logo == BPS_LOGO_BIG_ )
	{
		if ( sponsor == RPS_MERCEDES_ )
			if ( location == RPS_GARAGE_ )
				return [UIImage imageNamed:@"MGPLogoBig.png"];
			else
				return [UIImage imageNamed:@"UBSLogoBig.png"];
		else if ( sponsor == RPS_FIA_ )
			return [UIImage imageNamed:@"FIALogoBig.png"];
		else if ( sponsor == RPS_WILLIAMS_ )
			return [UIImage imageNamed:@"WilliamsLogoBig.png"];
		else
			return [UIImage imageNamed:@"RacePadLogoBig.png"];
	}
	
	return [UIImage imageNamed:@"RacePadLogo.png"];
}

- (bool) supportsTab: (unsigned char)tab
{
	NSNumber *v = [[BasePadPrefs Instance] getPref:@"supportVideo"];
	bool videoSupported = v ? [v boolValue] : true;
	
	if(tab == RPS_INFO_TAB_)
		return false;

	if ( sponsor == RPS_UNKNOWN_ )
	{
		if(tab == RPS_TRACK_MAP_TAB_ && videoSupported)
			return false;
		else if(tab == RPS_VIDEO_TAB_ && !videoSupported)
			return false;
		else if(tab == RPS_WEATHER_TAB_)
			return false;
		
		if ( tab == RPS_HEAD_TOHEAD_TAB_ )
			return [[RacePadDatabase Instance] session] == RPD_SESSION_RACE_;
		
		return true;
	}
	else if ( sponsor == RPS_MERCEDES_ )
	{
		if(tab == RPS_TRACK_MAP_TAB_ && videoSupported)
			return false;
		else if(tab == RPS_VIDEO_TAB_ && !videoSupported)
			return false;
		else if(tab == RPS_WEATHER_TAB_)
			return false;
		
		if ( tab == RPS_HEAD_TOHEAD_TAB_ )
			return [[RacePadDatabase Instance] session] == RPD_SESSION_RACE_;
		
		return true;
	}
	else if ( sponsor == RPS_WILLIAMS_ )
	{
		if(tab == RPS_TRACK_MAP_TAB_ && videoSupported)
			return false;
		else if(tab == RPS_VIDEO_TAB_ && !videoSupported)
			return false;
		
		if ( tab == RPS_HEAD_TOHEAD_TAB_ )
			return [[RacePadDatabase Instance] session] == RPD_SESSION_RACE_;
		
		return true;
	}
	else
	{
		if(tab == RPS_TRACK_MAP_TAB_ && videoSupported)
			return false;
		else if(tab == RPS_VIDEO_TAB_ && !videoSupported)
			return false;
	
		if ( tab == RPS_HEAD_TOHEAD_TAB_ )
			return [[RacePadDatabase Instance] session] == RPD_SESSION_RACE_;
		
		if ( tab == RPS_WEATHER_TAB_ )
			return [[RacePadCoordinator Instance] connectionType] == BPC_SOCKET_CONNECTION_;
		
		if ( tab == RPS_HOME_TAB_
			|| tab == RPS_DRIVER_LIST_TAB_
			|| tab == RPS_TRACK_MAP_TAB_
			|| tab == RPS_VIDEO_TAB_
			|| tab == RPS_DRIVER_TAB_
			|| tab == RPS_SETTINGS_TAB_ )
			return true;
	}
	
	return false;
}


@end



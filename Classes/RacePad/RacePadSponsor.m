//
//  RacePadCSponsor.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadSponsor.h"
#import "BasePadPrefs.h"

@implementation RacePadSponsor

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
	else
		sponsor = RPS_UNKNOWN_;
	
	[[BasePadPrefs Instance] setPref:@"sponsor" Value:name];
	[[BasePadPrefs Instance] save];
}

- (UIImage *) getSponsorLogo: (unsigned char)logo
{
	if ( logo == BPS_LOGO_REGULAR_ )
	{
		if ( sponsor == RPS_MERCEDES_ )
			return [UIImage imageNamed:@"MGPLogo.png"];
		else if ( sponsor == RPS_FIA_ )
			return [UIImage imageNamed:@"FIALogo.png"];
		else
			return [UIImage imageNamed:@"RacePadLogo.png"];
	}
	else if ( logo == BPS_LOGO_BIG_ )
	{
		if ( sponsor == RPS_MERCEDES_ )
			return [UIImage imageNamed:@"MGPLogoBig.png"];
		else if ( sponsor == RPS_FIA_ )
			return [UIImage imageNamed:@"FIALogoBig.png"];
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
		
		return true;
	}
	else if ( sponsor == RPS_MERCEDES_ )
	{
		if(tab == RPS_TRACK_MAP_TAB_ && videoSupported)
			return false;
		else if(tab == RPS_VIDEO_TAB_ && !videoSupported)
			return false;
		
		return true;
	}
	else
	{
		if(tab == RPS_TRACK_MAP_TAB_ && videoSupported)
			return false;
		else if(tab == RPS_VIDEO_TAB_ && !videoSupported)
			return false;
	
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



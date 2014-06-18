//
//  RacePadCSponsor.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RaceMapSponsor.h"
#import "BasePadPrefs.h"
#import "RaceMapData.h"
#import "RaceMapCoordinator.h"

@implementation RaceMapSponsor

@synthesize location;

static RaceMapSponsor * instance_ = nil;

+(RaceMapSponsor *)Instance
{
	if(!instance_)
		instance_ = [[RaceMapSponsor alloc] init];
	
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
	// if ( sponsor == RPS_MERCEDES_ )
		// return true;
	
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
			// if ( location == RPS_GARAGE_ )
				return [UIImage imageNamed:@"MGPLogo.png"];
			// else
				// return [UIImage imageNamed:@"UBSLogo.png"];
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
			// if ( location == RPS_GARAGE_ )
				return [UIImage imageNamed:@"MGPLogoBig.png"];
			// else
				// return [UIImage imageNamed:@"UBSLogoBig.png"];
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
		
 	if ( sponsor == RPS_UNKNOWN_ || sponsor == RPS_FIA_ )
	{
		if(tab == RPS_TRACK_MAP_TAB_)
			return true;
		if(tab == RPS_SETTINGS_TAB_)
			return true;
	}
	return false;
}

- (void) primaryBrandingColor: (float*) red : (float*) green : (float*) blue;
{

    if ( sponsor == RPS_UNKNOWN_ )
    {
        *red = 0.0;
        *green = 0.0;
        *blue = 0.0;
    }
    else if ( sponsor == RPS_MERCEDES_ )
    {
        *red = 3.0/255.0;
        *green = 168.0/255.0;
        *blue = 146.0/255.0;
    }
    else if ( sponsor == RPS_WILLIAMS_ )
    {
        *red = 3.0/255.0;
        *green = 39.0/255.0;
        *blue = 100.0/255.0;
    }
    else if ( sponsor == RPS_FIA_ )
    {
        *red = 3.0/255.0;
        *green = 39.0/255.0;
        *blue = 100.0/255.0;
    }
    else if ( sponsor == RPS_AUDI_ )
    {
        *red = 192.0/255.0;
        *green = 0.0/255.0;
        *blue = 32.0/255.0;
    }
}

@end



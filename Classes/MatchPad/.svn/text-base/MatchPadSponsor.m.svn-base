//
//  MatchPadCSponsor.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadSponsor.h"
#import "BasePadPrefs.h"

@implementation MatchPadSponsor

static MatchPadSponsor * instance_ = nil;

+(MatchPadSponsor *)Instance
{
	if(!instance_)
		instance_ = [[MatchPadSponsor alloc] init];
	
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
	return MPS_ALL_TABS_;
}

- (void) setSponsorName: (NSString *)name
{
	if ( [name compare:@"ManCity"] == NSOrderedSame )
		sponsor = MPS_MAN_CITY_;
	else
		sponsor = MPS_UNKNOWN_;
	
	[[BasePadPrefs Instance] setPref:@"sponsor" Value:name];
	[[BasePadPrefs Instance] save];
}

- (UIImage *) getSponsorLogo: (unsigned char)logo
{
	if ( logo == BPS_LOGO_REGULAR_ )
	{
		if ( sponsor == MPS_MAN_CITY_ )
			return [UIImage imageNamed:@"MGPLogo.png"];
		else
			return [UIImage imageNamed:@"MatchPadLogo.png"];
	}
	else if ( logo == BPS_LOGO_BIG_ )
	{
		if ( sponsor == MPS_MAN_CITY_ )
			return [UIImage imageNamed:@"MGPLogoBig.png"];
		else
			return [UIImage imageNamed:@"MatchPadLogoBig.png"];
	}
	
	return [UIImage imageNamed:@"MatchPadLogo.png"];
}

- (bool) supportsTab: (unsigned char)tab
{
	NSNumber *v = [[BasePadPrefs Instance] getPref:@"supportVideo"];
	bool videoSupported = v ? [v boolValue] : true;
	
	if ( sponsor == MPS_UNKNOWN_ )
	{
		if(tab == MPS_VIDEO_TAB_ && !videoSupported)
			return false;
		
		return true;
	}
	else if ( sponsor == MPS_MAN_CITY_)
	{
		if(tab == MPS_VIDEO_TAB_ && !videoSupported)
			return false;
		
		return true;
	}
	
	return false;
}


@end



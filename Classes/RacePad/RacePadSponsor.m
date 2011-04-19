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
		sponsor = RPS_FIA_;
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
	else
		sponsor = RPS_FIA_;
	
	[[RacePadPrefs Instance] setPref:@"sponsor" Value:name];
	[[RacePadPrefs Instance] save];
}

- (UIImage *) getSponsorLogo: (unsigned char)logo
{
	if ( logo == RPS_LOGO_REGULAR_ )
		if ( sponsor == RPS_MERCEDES_ )
			return [UIImage imageNamed:@"MGPLogo.png"];
		else
			return [UIImage imageNamed:@"LogoFIA.png"];
	else if ( logo == RPS_LOGO_BIG_ )
		if ( sponsor == RPS_MERCEDES_ )
			return [UIImage imageNamed:@"MGPLogoBig.png"];
		else
			return [UIImage imageNamed:@"LogoFIA.png"];
	
	return [UIImage imageNamed:@"LogoFIA.png"];
}

@end



//
//  BasePadCSponsor.m
//  BasePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadSponsor.h"
#import "BasePadPrefs.h"

@implementation BasePadSponsor

@synthesize sponsor;

static BasePadSponsor * instance_ = nil;

+(BasePadSponsor *)Instance
{
	assert ( instance_ );
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{
		instance_ = self;
		
		sponsor = 0;
		NSString *s = [[BasePadPrefs Instance] getPref:@"sponsor"];
		if ( s && [s length] )
			[self setSponsorName:s];
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (int) allTabCount
{
	return 0; // Override Me
}

- (void) setSponsorName: (NSString *)name
{
	[[BasePadPrefs Instance] setPref:@"sponsor" Value:name];
	[[BasePadPrefs Instance] save];
}

- (UIImage *) getSponsorLogo: (unsigned char)logo
{
	return [UIImage imageNamed:@"SBGLogo.png"];
}

- (bool) supportsTab: (unsigned char)tab
{
	return false;
}

- (int) videoTab
{
	return 0;
}

- (void) primaryBrandingColor: (float*) red : (float*) green : (float*) blue
{
    *red = 0.0;
    *green = 0.0;
    *blue = 0.0;
}


@end



//
//  RacePadSponsor.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Sponsors 

enum Sponsors
{
	RPS_UNKNOWN_,
	RPS_MERCEDES_,
	RPS_FIA_,
};

enum SponsorLogo {
	RPS_LOGO_BIG_,
	RPS_LOGO_REGULAR_,
};

enum AllTabs {
	RPS_INFO_TAB_,
	RPS_DRIVER_LIST_TAB_,
	RPS_TRACK_MAP_TAB_,
	RPS_VIDEO_TAB_,
	RPS_BLUE_CAR_TAB_,
	RPS_RED_CAR_TAB_,
	RPS_DRIVER_TAB_,
	RPS_GAME_TAB_,
	RPS_SETTINGS_TAB_,
	RPS_ALL_TABS_
};

@interface RacePadSponsor : NSObject
{
}

@property (nonatomic) unsigned char sponsor;

+(RacePadSponsor *)Instance;

-(UIImage *)getSponsorLogo: (unsigned char) logo;
- (bool) supportsTab:(unsigned char) tab;

- (void) setSponsorName: (NSString *)name;

@end

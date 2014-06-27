//
//  RacePadSponsor.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePadSponsor.h"

// Sponsors 

enum Sponsors
{
	RPS_UNKNOWN_,
	RPS_MERCEDES_,
	RPS_FIA_,
	RPS_WILLIAMS_,
	RPS_AUDI_DTM_,
    RPS_AUDI_WEC_,
};

enum AllTabs {
	RPS_HOME_TAB_,
	RPS_DRIVER_LIST_TAB_,
	RPS_FOM_PAGE1_TAB_,
	RPS_FOM_PAGE2_TAB_,
	RPS_TRACK_MAP_TAB_,
	RPS_VIDEO_TAB_,
	RPS_DRIVER_TAB_,
	RPS_HEAD_TOHEAD_TAB_,
	RPS_GAME_TAB_,
	RPS_INFO_TAB_,
	RPS_WEATHER_TAB_,
	RPS_SETTINGS_TAB_,
	RPS_ALL_TABS_,
	RPS_TELEMETRY_VIEW_,
};

enum Location {
	RPS_PADDOCK_,
	RPS_GARAGE_,
};

@interface RacePadSponsor : BasePadSponsor
{
	
	unsigned char location;
	
}

@property (nonatomic) unsigned char location;

+(RacePadSponsor *)Instance;

- (int) allTabCount;

-(UIImage *)getSponsorLogo: (unsigned char) logo;
- (bool) supportsTab:(unsigned char) tab;

- (void) setSponsorName: (NSString *)name;
- (bool) supportsLocation;
- (void) primaryBrandingColor: (float*) red : (float*) green : (float*) blue;

@end

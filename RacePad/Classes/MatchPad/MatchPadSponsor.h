//
//  MatchPadSponsor.h
//  MatchPad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadSponsor.h"

// Sponsors 

enum Sponsors
{
	MPS_UNKNOWN_,
	MPS_MAN_CITY_,
};

enum AllTabs {
	MPS_HOME_TAB_,
	MPS_VIDEO_TAB_,
	MPS_ANAYSIS_TAB_,
	MPS_STATS_TAB_,
	MPS_POSSESSION_TAB_,
	MPS_MOVES_TAB_,
	MPS_BALL_TAB_,
	MPS_SETTINGS_TAB_,
	MPS_ALL_TABS_
};

@interface MatchPadSponsor : BasePadSponsor
{
}

+(MatchPadSponsor *)Instance;

- (int) allTabCount;

-(UIImage *)getSponsorLogo: (unsigned char) logo;
- (bool) supportsTab:(unsigned char) tab;

- (void) setSponsorName: (NSString *)name;

@end

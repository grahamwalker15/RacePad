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
	RPS_MERCEDES_,
	RPS_FIA_,
};

enum SponsorLogo {
	RPS_LOGO_BIG_,
	RPS_LOGO_REGULAR_,
};

@interface RacePadSponsor : NSObject
{
}

@property (nonatomic) unsigned char sponsor;

+(RacePadSponsor *)Instance;

-(UIImage *)getSponsorLogo: (unsigned char) logo;

- (void) setSponsorName: (NSString *)name;

@end

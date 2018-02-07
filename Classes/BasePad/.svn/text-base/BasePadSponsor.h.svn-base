//
//  BasePadSponsor.h
//  BasePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Sponsors 

enum SponsorLogo {
	BPS_LOGO_BIG_,
	BPS_LOGO_REGULAR_,
};

@interface BasePadSponsor : NSObject
{
	unsigned char sponsor;
}

@property (nonatomic) unsigned char sponsor;

+(BasePadSponsor *)Instance;

- (int) allTabCount;

-(UIImage *)getSponsorLogo: (unsigned char) logo;
- (bool) supportsTab:(unsigned char) tab;

- (void) setSponsorName: (NSString *)name;

- (int) videoTab;

@end

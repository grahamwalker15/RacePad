//
//  MatchPadDatabase.h
//  MatchPad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePadDatabase.h"
#import "Pitch.h"

@interface MatchPadDatabase : BasePadDatabase
{
	Pitch *pitch;
}

@property (readonly) Pitch *pitch;

+ (MatchPadDatabase *)Instance;
- (void) clearStaticData;

@end

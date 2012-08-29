//
//  MidasDatabase.h
//  MidasDemo
//
//  Created by Gareth Griffith on 8/28/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RacePadDatabase.h"	
#import "MidasVoting.h"

@interface MidasDatabase : RacePadDatabase
{
	MidasVoting *midasVoting;
}
	
@property (readonly) MidasVoting *midasVoting;
	
+ (MidasDatabase *)Instance;
- (void) clearStaticData;
	
@end
	

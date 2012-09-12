//
//  MidasDatabase.h
//  MidasDemo
//
//  Created by Gareth Griffith on 8/28/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RacePadDatabase.h"	

@interface MidasDatabase : RacePadDatabase
{
}
		
+ (MidasDatabase *)Instance;
- (void) clearStaticData;
	
@end
	

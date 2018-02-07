//
//  CommentaryData.h
//  RacePad
//
//  Created by Gareth Griffith on 1/19/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AlertData.h"

@interface CommentaryData : AlertData
{
	
	NSString *commentaryFor;

}

@property (retain) NSString *commentaryFor;


- (void) fillWithDefaultData:(int)car;

@end

//
//  MidasVoting.h
//  MidasDemo
//
//  Created by Gareth Griffith on 8/28/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MidasVotingView;

@interface MidasVoting : NSObject
{
	NSString * abbr;
				
	int votesFor;
	int votesAgainst;
	int position;
	int driverCount;
}
	
@property (readonly) NSString * abbr;
	
@property (readonly) int votesFor;
@property (readonly) int votesAgainst;
@property (readonly) int position;
@property (readonly) int driverCount;
	
- (id) initWithDriver:(NSString *)driver;

- (void) clearData;
		
- (void) drawInView : (MidasVotingView *)view;

+ (void) localThumbsUp;
+ (void) localThumbsDown;

@end

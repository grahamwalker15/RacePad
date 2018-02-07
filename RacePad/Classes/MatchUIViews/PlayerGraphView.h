//
//  PlayerGraphView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface PlayerGraphView : DrawingView
{
	NSString * playerToFollow;
}

@property (nonatomic, retain) NSString * playerToFollow;

- (void)followPlayer:(NSString *)name;

@end


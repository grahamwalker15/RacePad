//
//  MatchPadAppDelegate.h
//  MatchPad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadAppDelegate.h"

@class MatchPadVideoViewController;

@interface MatchPadAppDelegate : BasePadAppDelegate
{
	MatchPadVideoViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet MatchPadVideoViewController *mainViewController;

@end

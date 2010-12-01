//
//  PitWindowViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"

@class PitWindowView;
@class BackgroundView;

@interface PitWindowViewController : RacePadViewController
{
	IBOutlet BackgroundView * backgroundView;
	IBOutlet PitWindowView * redPitWindowView;	
	IBOutlet PitWindowView * bluePitWindowView;	
}


@end

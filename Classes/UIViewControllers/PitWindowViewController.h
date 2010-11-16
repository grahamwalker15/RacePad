//
//  PitWindowViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingViewController.h"
#import "ESRenderer.h"

@class PitWindowView;
@class BackgroundView;

@interface PitWindowViewController : DrawingViewController
{
	IBOutlet BackgroundView * backgroundView;
	PitWindowView * pitWindowView;	
}


@end

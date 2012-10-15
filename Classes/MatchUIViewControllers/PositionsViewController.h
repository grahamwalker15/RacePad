//
//  PositionsViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@class PositionsView;
@class BackgroundView;
@class TableDataView;

@interface PositionsViewController : BasePadViewController
{
	
	IBOutlet PositionsView *positionsView;
	IBOutlet BackgroundView *backgroundView;
}

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

@end

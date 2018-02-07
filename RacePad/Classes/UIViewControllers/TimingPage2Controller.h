//
//  TimingPage2Controller.h
//  RacePad
//
//  Created by Mark Riches
//	December 2012
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListViewController.h"
#import "TableDataView.h"

@class DriverLapListController;
@class BackgroundView;

@interface TimingPage2Controller : SimpleListViewController
{
	IBOutlet TableDataView * timing_page_view_;
}

@end

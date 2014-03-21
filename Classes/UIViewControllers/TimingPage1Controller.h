//
//  TimingPage1Controller.h
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

@interface TimingPage1Controller : SimpleListViewController
{
	IBOutlet TableDataView * timing_page_view_;
	DriverLapListController * driver_lap_list_controller_;
	
	bool driver_lap_list_controller_displayed_;
	bool driver_lap_list_controller_closing_;
}

- (void)ShowDriverLapList:(NSString *)driver;
- (void)HideDriverLapListAnimated:(bool)animated;

@end

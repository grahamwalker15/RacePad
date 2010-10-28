//
//  DriverLapListController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/24/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListViewController.h"

@class TableDataView;

@interface DriverLapListController : UIViewController
{
	IBOutlet UIToolbar * title_bar_;
	IBOutlet TableDataView * lap_list_view_;
	
	IBOutlet UIBarButtonItem * back_button_;
	IBOutlet UIBarButtonItem * title_;
	IBOutlet UIBarButtonItem * previous_button_;
	IBOutlet UIBarButtonItem * next_button_;
}

- (IBAction)BackButton:(id)sender;
- (IBAction)PreviousButton:(id)sender;
- (IBAction)NextButton:(id)sender;

@end

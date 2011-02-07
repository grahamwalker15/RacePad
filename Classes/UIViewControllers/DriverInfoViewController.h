//
//  DriverInfoViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/7/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DriverInfoViewController : UIViewController
{
	IBOutlet UIButton * closeButton;

	IBOutlet UILabel * driverFirstName;
	IBOutlet UILabel * driverSurname;
	IBOutlet UILabel * team;
	IBOutlet UIImageView * photo;
	
	UIPopoverController * parentPopover;
}

@property (nonatomic, retain) UIPopoverController * parentPopover;

- (IBAction) closePressed:(id)sender;

- (bool) setDriverIndex:(int)index;

@end

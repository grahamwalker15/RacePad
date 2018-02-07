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
	IBOutlet UIImageView * helmet;
	IBOutlet UIImageView * car;
	
	IBOutlet UILabel * age;
	IBOutlet UILabel * races;
	IBOutlet UILabel * championships;
	IBOutlet UILabel * wins;
	IBOutlet UILabel * poles;
	IBOutlet UILabel * fastestLaps;
	IBOutlet UILabel * points;
	IBOutlet UILabel * lastPos;
	IBOutlet UILabel * lastPoints;	
	
	UIPopoverController * parentPopover;
}

@property (nonatomic, retain) UIPopoverController * parentPopover;

- (IBAction) closePressed:(id)sender;

- (bool) setDriverIndex:(int)index;

@end

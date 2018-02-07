//
//  InfoDriversController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoChildController.h"

@interface InfoDriversController : InfoChildController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UITableView * drivers;
	
	IBOutlet UIView * driverInfoBase;
	
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
}

- (void) setDriverIndex:(int)index;
- (void) emptyDriverInfoTable;

@end

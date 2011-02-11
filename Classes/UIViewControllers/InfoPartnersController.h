//
//  InfoPartnersController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/9/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoChildController.h"

@interface InfoPartnersController : InfoChildController
{
	IBOutlet UIButton * partner1;
	IBOutlet UIButton * partner2;
	IBOutlet UIButton * partner3;
	IBOutlet UIButton * partner4;
	IBOutlet UIButton * partner5;
	IBOutlet UIButton * partner6;
	IBOutlet UIButton * partner7;
	IBOutlet UIButton * partner8;
	IBOutlet UIButton * partner9;
	IBOutlet UIButton * partner10;
	IBOutlet UIButton * partner11;
	
	UIButton * selectedPartner;
}

- (IBAction) buttonPressed:(id)sender;

@end

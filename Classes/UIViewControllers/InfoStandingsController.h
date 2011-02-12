//
//  InfoStandingsController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/12/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoChildController.h"
#import "ShinyButton.h"

@interface InfoStandingsController : InfoChildController
{
	IBOutlet ShinyButton * drivers;
	IBOutlet ShinyButton * constructors;
	
	IBOutlet UIImageView * fiaLogo;
	
	UIButton * selectedButton;
}

- (IBAction) buttonPressed:(id)sender;

@end

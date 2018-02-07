//
//  InfoRulesController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/11/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoChildController.h"
#import "ShinyButton.h"

@interface InfoRulesController : InfoChildController
{
	IBOutlet ShinyButton * rules1;
	IBOutlet ShinyButton * rules2;
	IBOutlet ShinyButton * rules3;
	IBOutlet ShinyButton * rules4;
	IBOutlet ShinyButton * rules5;
	IBOutlet ShinyButton * rules6;
	IBOutlet ShinyButton * rules7;
	IBOutlet ShinyButton * rules8;
	IBOutlet ShinyButton * rules9;
	IBOutlet ShinyButton * rules10;
	IBOutlet ShinyButton * rules11;
	IBOutlet ShinyButton * rules12;
	
	IBOutlet UIImageView * fiaLogo;
	
	UIButton * selectedRules;
}

- (IBAction) buttonPressed:(id)sender;

@end

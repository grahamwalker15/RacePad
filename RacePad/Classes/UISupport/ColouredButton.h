//
//  ColouredButton.h
//  RacePad
//
//  Created by Gareth Griffith on 1/29/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColouredButton : UIButton
{
	UIColor * textColour;
	UIColor * buttonColour;
	UIColor * outlineColour;
	
	UIColor * selectedTextColour;
	UIColor * selectedButtonColour;

	float radius;
	bool outline;
}

@property (nonatomic, retain) UIColor * textColour;
@property (nonatomic, retain) UIColor * buttonColour;
@property (nonatomic, retain) UIColor * outlineColour;
@property (nonatomic, retain) UIColor * selectedTextColour;
@property (nonatomic, retain) UIColor * selectedButtonColour;
@property (nonatomic) float radius;
@property (nonatomic) bool outline;

- (void) setDefaultColours;
- (void) requestRedraw;

@end

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
}

@property (nonatomic, retain) UIColor * textColour;
@property (nonatomic, retain) UIColor * buttonColour;
@property (nonatomic, retain) UIColor * outlineColour;

- (void) setDefaultColours;
- (void) requestRedraw;

@end

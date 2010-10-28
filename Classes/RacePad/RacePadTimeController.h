//
//  RacePadTimeController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/25/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeViewController;

@interface RacePadTimeController : NSObject
{
	TimeViewController * timeController;
}

+(RacePadTimeController *)Instance;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController;
- (void) hide;

- (IBAction)TestPressed:(id)sender;

@end

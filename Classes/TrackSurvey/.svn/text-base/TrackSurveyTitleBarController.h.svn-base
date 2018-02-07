//
//  TrackSurveyTitleBar.h
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShinyButton.h"

@interface TitleBarViewController : UIViewController
{
	IBOutlet UIToolbar * toolbar;
	
	IBOutlet UIBarButtonItem * alertButton;
	IBOutlet UIBarButtonItem * surveyStateBarItem;
	IBOutlet UIButton * surveyStateButton;	

	NSArray * allItems;

}

@property (readonly) UIToolbar * toolbar;
@property (readonly) UIBarButtonItem * surveyStateBarItem;
@property (readonly) UIButton * surveyStateButton;

@property (readonly) NSArray * allItems;

- (void)RequestRedraw;
- (void)RequestRedrawForUpdate;

@end

@interface TrackSurveyTitleBarController : NSObject
{
	TitleBarViewController * titleBarController;
}

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController;
- (void) hide;

- (IBAction)SurveyPressed:(id)sender;

+ (TrackSurveyTitleBarController *)Instance;

@end

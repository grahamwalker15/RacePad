//
//  WorkOffline.h
//  RacePad
//
//  Created by Mark Riches on 05/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShinyButton.h"
#import "BackgroundView.h"


@interface WorkOffline : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	
	IBOutlet BackgroundView *backgroundView;
	IBOutlet UIPickerView *event;
	IBOutlet ShinyButton *ok;
	IBOutlet ShinyButton *online;
	IBOutlet UIButton *settings;
	IBOutlet UIImageView *logo;
	
	NSMutableArray *events;
	NSMutableArray *sessions;
	
	bool animatedDismissal;
	
}

@property (nonatomic) bool animatedDismissal;

- (IBAction)okPressed:(id)sender;
- (IBAction)onlinePressed:(id)sender;
- (IBAction)settingsPressed:(id)sender;

@end

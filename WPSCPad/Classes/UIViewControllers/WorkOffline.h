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
#import "BasePadCoordinator.h"


@interface WorkOffline : UIViewController <ConnectionFeedbackDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
	
	IBOutlet UITextField *ip_address_edit_;
	IBOutlet UIButton *connect;
	IBOutlet UILabel *status;
	IBOutlet UIActivityIndicatorView *serverTwirl;

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

- (void) updateServerState:(NSString *)message;

- (IBAction)IPAddressChanged:(id)sender;
- (IBAction)connectPressed:(id)sender;

- (IBAction)okPressed:(id)sender;
- (IBAction)onlinePressed:(id)sender;
- (IBAction)settingsPressed:(id)sender;

@end

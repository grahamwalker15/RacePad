//
//  ViewController.h
//  F1Test
//
//  Created by Andrew Greenshaw on 05/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterView.h"
#import "FacebookView.h"
#import "MidasView.h"

@interface ViewController : UIViewController <BaseSocialmediaViewDelegate> {
    TwitterView *twitview;
    FacebookView *faceview;
    MidasView *midasview;
}

@property (nonatomic, retain) TwitterView *twitview;
@property (nonatomic, retain) FacebookView *faceview;
@property (nonatomic, retain) MidasView *midasview;

-(IBAction)showTwitter:(id)sender;
-(IBAction)showFacebook:(id)sender;
-(IBAction)showMidas:(id)sender;

- (void)handledTap;

@end

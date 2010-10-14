//
//  MovieViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface MovieViewController : UIViewController
{

}

- (void) movieFinishedCallback:(NSNotification*) aNotification;

@end

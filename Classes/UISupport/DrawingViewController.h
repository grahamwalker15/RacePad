//
//  DrawingViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePadViewController.h"
#import "DrawingView.h"

@interface DrawingViewController : BasePadViewController
{
	IBOutlet DrawingView * drawingView;
}

@property (readonly) DrawingView * drawingView;

@end

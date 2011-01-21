//
//  CommentaryView.h
//  RacePad
//
//  Created by Gareth Griffith on 1/18/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleListView.h"

@interface CommentaryView : SimpleListView
{
	int car;
	
	int lastRowCount;
}

@property (nonatomic) int car;

@end
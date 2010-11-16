//
//  LeaderboardView.h
//  RacePad
//
//  Created by Gareth Griffith on 11/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface LeaderboardView : DrawingView
{
	id tableData;
}

@property (nonatomic, retain, setter=SetTableDataClass) id tableData;

- (int) RowHeight;
- (int) RowCount;
- (NSString *) GetCellTextAtRow:(int)row Col:(int)col;
- (NSString *) carNameAtX:(float)x Y:(float)y;

@end

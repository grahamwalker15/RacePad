//
//  LeaderboardView.h
//  RacePad
//
//  Created by Gareth Griffith on 11/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@class TrackMapView;

@interface LeaderboardView : DrawingView
{
	id tableData;
	TrackMapView * associatedTrackMapView;
	
	bool smallDisplay;
	bool addOutlines;
	
	NSString *highlightCar; // Follow this car if there is no associatedTrackMap
}

@property (nonatomic, retain, setter=SetTableDataClass:) id tableData;
@property (nonatomic, retain) TrackMapView * associatedTrackMapView;
@property (nonatomic) bool smallDisplay;
@property (nonatomic) bool addOutlines;
@property (nonatomic, retain) NSString * highlightCar;

- (int) RowHeight;
- (int) RowCount;
- (NSString *) GetCellTextAtRow:(int)row Col:(int)col;
- (NSString *) carNameAtX:(float)x Y:(float)y;
- (NSString *) carNameAtPosition:(int)position;

@end

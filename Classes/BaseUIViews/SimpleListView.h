//
//  SimpleListView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/8/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrawingView.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

// Cell types
enum CellTypes {
	SLV_TEXT_CELL_,
	SLV_IMAGE_CELL_,
	SLV_CLIENT_IMAGE_,
	SLV_CUSTOM_DRAW_,
} ;

// Text align types
enum AlignTypes {
	SLV_TEXT_LEFT_,
	SLV_TEXT_RIGHT_,
	SLV_TEXT_CENTRE_,
} ;

// Column types
enum ColumnTypes {
	SLV_COL_STANDALONE_,
	SLV_COL_PARENT_,
	SLV_COL_CHILD_
} ;

// Column priority
enum ColumnPriority {
	SLV_USE_FOR_LANDSCAPE,
	SLV_USE_FOR_PORTRAIT,
	SLV_USE_FOR_BOTH,
} ;

#define SLV_MAX_COLUMNS 1024
#define SLV_MAX_ROWS 1024	// Actually just max number of rows that can be expanded, or have adaptable height cached

@class SimpleListView;

@protocol SimpleListViewDelegate
- (bool) SLVHandleSelectHeadingInView:(SimpleListView *)view;
- (bool) SLVHandleSelectRowInView:(SimpleListView *)view Row:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press;
- (bool) SLVHandleSelectColInView:(SimpleListView *)view Col:(int)col;
- (bool) SLVHandleSelectCellInView:(SimpleListView *)view Row:(int)row Col:(int)col DoubleClick:(bool)double_click LongPress:(bool)long_press;
- (bool) SLVHandleSelectBackgroundInView:(SimpleListView *)view DoubleClick:(bool)double_click LongPress:(bool)long_press;
- (void) SLVHandleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;
@end

@interface SimpleListView : DrawingView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
@protected
	
	UIColor * heading_bg_colour_;
	UIColor * heading_text_colour_;
	
	UIColor * option_tyre_;
	UIColor * prime_tyre_;
	UIColor * inter_tyre_;
	UIColor * wet_tyre_;
    
	int row_count_ ;
	int standardRowHeight;
	int expansionRowHeight;
	
	int column_count_;
	
	int font_;
	
	bool expansionAllowed;
	unsigned char expansionFlag[SLV_MAX_ROWS];
	
	float maxRowHeightCache[SLV_MAX_ROWS];
	
	int cellYMargin;
	bool rowDivider;
	
	bool adaptableRowHeight;
	
	int column_width_[SLV_MAX_COLUMNS];
	int column_type_[SLV_MAX_COLUMNS];
	
	bool if_heading_ ;
	bool shadeHeading;
	bool swiping_enabled_;
	
	bool scroll_to_end_requested_;
	bool reset_scroll_requested_;
	bool scroll_animating_;
	NSTimer *scrollTimeoutTimer;
    
	int text_baseline_;
    
	int selected_row_;
	int selected_col_;
	
	int down_row_, down_col_;
	int mouse_x_, mouse_y_;
	int down_x_, down_y_;
	bool select_on_up_;
	
	int click_;
	bool double_click_possible_;
	
	UIColor * base_colour_;
	UIColor * selected_colour_;
	UIColor * focus_colour_;
	UIColor * selected_text_colour_;
	
	UIColor * text_colour_;
	UIColor * background_colour_;
	
	float background_alpha_;
	bool draw_all_cells_;
	
	int alignment_;
	
	bool portraitMode;;

	NSTimer *doubleTapTimer;
	CGPoint tapPoint;
	
	UIViewController <SimpleListViewDelegate> * gestureDelegate;
    
}

@property (nonatomic) int standardRowHeight;
@property (nonatomic) int expansionRowHeight;

@property (nonatomic) bool expansionAllowed;

@property (nonatomic) bool adaptableRowHeight;

@property (nonatomic) int cellYMargin;
@property (nonatomic) bool rowDivider;
@property (nonatomic) bool shadeHeading;

@property (nonatomic, setter=SetFont:, getter=GetFont) int font_;
@property (nonatomic, setter=SetDrawAllCells:, getter=DrawAllCells) bool draw_all_cells_;
@property (nonatomic, setter=SetBackgroundAlpha:, getter=BackgroundAlpha) float background_alpha_;
@property (nonatomic, retain, setter=SetBaseColour:, getter=BaseColour) UIColor * base_colour_;
@property (nonatomic, retain, setter=SetSelectedColour:, getter=SelectedColour) UIColor * selected_colour_;
@property (nonatomic, retain, setter=SetFocusColour:, getter=FocusColour) UIColor * focus_colour_;
@property (nonatomic, retain, setter=SetSelectedTextColour:, getter=SetSelectedTextColour) UIColor * selected_text_colour_;
@property (nonatomic, retain, setter=SetTextColour:, getter=TextColour) UIColor * text_colour_;
@property (nonatomic, retain, setter=SetBackgroundColour:, getter=BackgroundColour) UIColor * background_colour_;

@property (nonatomic, retain) UIViewController <SimpleListViewDelegate> * gestureDelegate;

- (void) DeleteTable;

- (void) SetRowCount:(int)count;

- (void) AddColumn;
- (void) AddColumnWithWidth:(int)width;
- (void) AddColumnWithWidth:(int)width Type:(int)type;
- (void) SetColumn:(int)column Width:(int)width;

- (int) TableWidth;
- (int) TableHeight;
- (int) TableHeightToRow:(int)row;

- (void) SetHeading:(bool)if_heading;
- (void) SetSwipingEnabled:(bool)value;

- (void) ResetScroll;
- (void) RequestScrollToEnd;
- (void) ScrollToEnd;
- (void) ScrollToRow:(int)row;
- (void) MakeRowVisible:(int)row;

- (void) setScrollTimer;
- (void) scrollTimerExpired:(NSTimer *)theTimer;

- (void) ClearRows;
- (bool) IfHeading;

- (void) SetDefaultFormatting:(bool)if_heading;
- (void) SetTextColour:(UIColor *)colour;
- (void) SetBackgroundColour:(UIColor *)colour;
- (void) MixBackgroundColour:(UIColor *)colour MixPct:(int) pct;
- (void) DarkenBackgroundColour;
- (void) LightenBackgroundColour;
- (void) SetBaseColour:(UIColor *)colour;
- (void) SetAlignment:(int)alignment;

- (void) SelectRow:(int)index;
- (bool) IsRowSelected:(int)index;
- (int) InqSelectedRowIndex;
- (bool) IsColSelected:(int)index;
- (int) InqSelectedColIndex;

- (void) DrawRow:(int)row AtY:(float)y WithRowHeight:(float)row_height AndLineHeight:(float)line_height;
- (void) Draw:(CGRect)region;
- (void) DrawBase;

-(void)	CustomDrawCellForRow:(int)row Col:(int)col AtX:(float)x Y:(float)y WithRowHeight:(float)row_height ColumnWidth:(int)column_width AndLineHeight:(float)line_height;

// Functions that CAN be overridden for customised content (defaults return local array counts)
- (int) RowCount;
- (int) ColumnCount;

- (int) ContentRowHeight:(int)row;
- (int) ExpansionRowHeight:(int)row;
- (int) RowHeight:(int)row;
- (int) MaxContentRowHeight:(int)row;
- (void) ClearRowHeightCache;

- (void) SetRow:(int)row Expanded:(bool)expanded;
- (bool) RowExpanded:(int)row;
- (void) UnexpandAllRows;

- (int) ColumnWidth:(int)col;
- (int) ColumnType:(int)col;
- (int) ColumnUse:(int)col;

- (int) GetFontAtRow:(int)row Col:(int)col;

// Functions that CAN be overridden for customised content (defaults do nothing)
- (void) PrepareData;
- (void) PrepareRow:(int)row;

// Functions that MUST be overridden for customised content (defaults return no content)
- (int) InqCellTypeAtRow:(int)row Col:(int)col;
- (NSString *) GetCellTextAtRow:(int)row Col:(int)col;
- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col;
- (UIImage *) GetCellClientImageAtRow:(int)row Col:(int)col;
- (NSString *) GetHeadingAtCol:(int)col;
- (NSString *) GetRowTag:(int)row;

- (void) InitialiseSimpleListViewMembers;

- (bool) FindCellAtX:(float)x Y:(float)y RowReturn:(int *)row_return ColReturn:(int *)col_return;
- (bool) InExpansionForRow:(int)row AtY:(float)y;

- (bool) HandleSelectHeading;
- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press;
- (bool) HandleSelectCol:(int)col;
- (bool) HandleSelectCellRow:(int)row Col:(int)col DoubleClick:(bool)double_click LongPress:(bool)long_press;
- (bool) HandleSelectBackgroundDoubleClick:(bool)double_click LongPress:(bool)long_press;
- (void) HandleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;

// Gesture recognizer creation

-(void) addTapRecognizer;
-(void) addDoubleTapRecognizer;
-(void) addLongPressRecognizer;

// Gesture recognizer callbacks

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleDoubleTapFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleLongPressFrom:(UIGestureRecognizer *)gestureRecognizer;

// Action callbacks

- (void) OnTapGestureAtX:(float)x Y:(float)y;
- (void) OnDoubleTapGestureAtX:(float)x Y:(float)y;
- (void) OnLongPressGestureAtX:(float)x Y:(float)y;

@end
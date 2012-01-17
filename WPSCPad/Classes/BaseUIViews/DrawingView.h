//
//  DrawingView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIConstants.h"

// View types
enum FontTypes
{
	DW_LIGHT_REGULAR_FONT_,
	DW_LIGHT_CONTROL_FONT_,
	DW_LIGHT_LARGER_CONTROL_FONT_,
	DW_LIGHT_BIG_FONT_,
	DW_REGULAR_FONT_,
	DW_TITLE_FONT_,
	DW_CONTROL_FONT_,
	DW_LARGER_CONTROL_FONT_,
	DW_BOLD_FONT_,
	DW_MEDIUM_BOLD_FONT_,
	DW_BIG_FONT_,
	DW_ITALIC_LARGER_CONTROL_FONT_,
	DW_ITALIC_REGULAR_FONT_,
	DW_ITALIC_BIG_FONT_,

};

@interface DrawingView : UIScrollView
{
	@protected
		
		UIColor * fg_;
		UIColor * bg_;
	
		UIColor * black_;
		UIColor * white_;
		UIColor * blue_;
		UIColor * orange_;
		UIColor * yellow_;
		UIColor * red_;
		UIColor * green_;
		UIColor * cyan_;
		UIColor * dark_red_;
		UIColor * dark_blue_;
		UIColor * light_blue_;
		UIColor * dark_grey_;
		UIColor * very_dark_grey_;
		UIColor * light_grey_;
		UIColor * very_light_blue_;
		UIColor * very_light_grey_;
		UIColor * light_orange_;
		UIColor * magenta_;
		UIColor * dark_magenta_;

		UIFont * current_font_;
		NSMutableArray * font_stack_;
	
		CGRect current_bounds_;
		CGSize current_size_;
		CGPoint current_origin_;
		CGPoint current_bottom_left_;
		CGPoint current_top_right_;
	
		CGPoint current_scroll_offset_;
	
		CGContextRef current_context_;
		CGContextRef bitmap_context_;
	
		char * bitmap_context_data_;

		CGAffineTransform current_matrix_;
		
		bool entered_;
				
		int last_x_, last_y_;
	
		bool double_tap_enabled_;
	
}
	
// Properties for synthesizing

@property (nonatomic, retain, setter=SetFGColour, getter=FGColour) UIColor * fg_;
@property (nonatomic, retain, setter=SetBGColour, getter=BGColour) UIColor * bg_;
@property (nonatomic, setter=SetDoubleTapEnabled, getter=DoubleTapEnabled) bool double_tap_enabled_;
@property (readonly) UIColor * black_;
@property (readonly) UIColor * white_;
@property (readonly) UIColor * blue_;
@property (readonly) UIColor * orange_;
@property (readonly) UIColor * yellow_;
@property (readonly) UIColor * red_;
@property (readonly) UIColor * green_;
@property (readonly) UIColor * cyan_;
@property (readonly) UIColor * dark_red_;
@property (readonly) UIColor * dark_blue_;
@property (readonly) UIColor * light_blue_;
@property (readonly) UIColor * dark_grey_;
@property (readonly) UIColor * very_dark_grey_;
@property (readonly) UIColor * light_grey_;
@property (readonly) UIColor * very_light_blue_;
@property (readonly) UIColor * very_light_grey_;
@property (readonly) UIColor * light_orange_;
@property (readonly) UIColor * magenta_;
@property (readonly) UIColor * dark_magenta_;

// Initialisation
- (void)InitialiseDrawingViewMembers;
- (void)InitialiseImageDrawing;
- (void)InitialiseStatics;

+ (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b;
+ (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b Alpha:(float)a;

- (UIColor *)CreateHighlightColourFromColour:(UIColor *)source;
- (UIColor *)CreateShadowColourFromColour:(UIColor *)source;

// Basic utilities
- (void)getCurrentBoundsInfo;
- (CGSize)InqSize;

- (bool)CreateBitmapContext;
- (CGImageRef)GetImageFromBitmapContext;
- (void)DestroyBitmapContext;

- (void)SetBGToShadowColour;
- (void)SetAlpha:(float)alpha;

// Request a redraw on next cycle
- (void)RequestRedraw;
- (void)RequestRedrawInRect:(CGRect)rect;
- (void) RequestRedrawForUpdate; // Default will RequestRedraw - but indicates an external request rather than an internal one

// Recraw window (N.B. THESE METHODS SHOULD BE OVERRIDDEN)
- (void)Draw;
- (void)Draw:(CGRect)rect;

// Drawing should be bracketed with BeginDrawing/EndDrawing. This ensures that
// the display gets flushed correctly on buffered screens.
- (void)BeginDrawing;
- (void)EndDrawing;

// 
// Drawing primitives
// Lines & text drawn in foreground colour
// Fills and text bg drawn in background colour
//

- (void)SaveGraphicsState;
- (void)RestoreGraphicsState;

- (void)ClearScreen;
- (void)SetClippingArea:(CGRect)rect; // N.B. Sets it to an intersection with current clip area. Need a save/restore around it
- (void)SetClippingAreaToPath:(CGMutablePathRef)path; // N.B. Sets it to an intersection with current clip area. Need a save/restore around it

- (void)SetLineWidth:(float)width;
- (void)SetSolidLine;
- (void)SetDashedLine;
- (void)SetDashedLine:(float) length;

- (void)SetDropShadowXOffset:(float)xoffset YOffset:(float)yoffset Blur:(float)blur; // N.B. Need a save/restore around it to switch off
- (void)ResetDropShadow;

- (void)LineX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)LinePoint0:(CGPoint)p0 Point1:(CGPoint)p1;

- (void)FillRectangle:(CGRect)rect;
- (void)FillShadedRectangle:(CGRect)rect WithHighlight:(bool)ifHighlight;
- (void)FillGlassRectangle:(CGRect)rect;
- (void)LineRectangle:(CGRect)rect;
- (void)FillRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)FillShadedRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 WithHighlight:(bool)ifHighlight;
- (void)FillGlassRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)FillPatternRectangle:(UIImage *)image X0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)LineRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)LineCircle:(float)x0 Y0:(float)y0 Radius:(float)r;
- (void)LineArc:(float)x0 Y0:(float)y0 StartAngle:(float)startAngle EndAngle:(float)endAngle Clockwise:(bool) clockwise Radius:(float)r;

- (void)EtchRectangle:(CGRect)rect EtchIn:(bool)etch_in;

- (void)SetXorLines:(bool)set;

// Polygon / Path drawing

- (void)FillPolygonPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y;
- (void)LinePolygonPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y;

+ (CGMutablePathRef)CreatePathPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y;
+ (CGMutablePathRef)CreatePathPoints:(int)p0 P1:(int)p1 XCoords:(float *)x YCoords:(float *)y Count:(int) count;
+ (CGMutablePathRef)CreateTrianglePathX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2;
+ (CGMutablePathRef)CreateRectPathX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
+ (CGMutablePathRef)CreateRoundedRectPathX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 Radius:(float)r;

- (void)BeginPath;
- (void)LoadPath:(CGMutablePathRef)path;

- (void)FillCurrentPath;
- (void)LineCurrentPath;

- (void)FillPath:(CGMutablePathRef)path;
- (void)LinePath:(CGMutablePathRef)path;

//
// Image Drawing
//

- (void) DrawImage:(UIImage *)image AtX:(float)x Y:(float)y;
- (void) DrawImage:(UIImage *)image AtX:(float)x Y:(float)y WithAlpha:(float)alpha;

- (void) DrawImage:(UIImage *)image InRect:(CGRect)rect;
- (void) DrawImage:(UIImage *)image InRect:(CGRect)rect WithAlpha:(float)alpha;

- (void) DrawPattern:(UIImage *)image InRect:(CGRect)rect;

//
// Text Drawing
//

- (void)DrawString:(NSString *)string AtX:(float)x Y:(float)y;
- (void)DrawClippedString:(NSString *)string AtX:(float)x Y:(float)y MaxWidth:(float)max_width;
- (void)GetStringBox:(NSString *)string WidthReturn:(float *)width HeightReturn:(float *)height;

- (void)UseFont:(int)font;
- (void)UseTitleFont;
- (void)UseBigFont;
- (void)UseControlFont;
- (void)UseLargerControlFont;
- (void)UseBoldFont;
- (void)UseMediumBoldFont;
- (void)UseRegularFont;

- (void)SelectUIFont;

- (void)SaveFont;
- (void)RestoreFont;

// Matrix manipulation
- (void)SetScale:(float) scale;
- (void)SetScaleX:(float) scale_x Y:(float)scale_y;
- (void)SetTranslateX:(float)x Y:(float)y;
- (void)SetRotation:(float)angle;
- (void)SetRotationInDegrees:(float)angle;

- (void)StoreTransformMatrix;
- (void)ResetTransformMatrix;

- (CGPoint)TransformPoint:(CGPoint)point;

// Scrolling support

- (void)SetContentWidth:(float)width AndHeight:(float)height;

@end

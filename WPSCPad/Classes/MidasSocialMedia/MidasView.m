//
//  MidasView.m
//  F1Test
//
//  Created by Andrew Greenshaw on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MidasView.h"

#define kTestDataLen    12

@implementation MidasView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userName.textColor = [UIColor blackColor];
        self.viewType = Midas;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)loadData {
    self.entryTimings = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryTime = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    
    self.dummyEntryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
	
	[self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 0 * 60 + 15)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 3 * 60 + 36)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 3 * 60 + 59)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 4 * 60 + 29)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 4 * 60 + 37)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 5 * 60 + 25)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 5 * 60 + 45)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 6 * 60 + 15)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 6 * 60 + 35)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 7 * 60 + 25)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 10 * 60 + 20)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 10 * 60 + 50)]];
	
    [self.dummyEntryName addObject:@"Bruce Steinberg"];
    [self.dummyEntryName addObject:@"Sam Mackellar"];
    [self.dummyEntryName addObject:@"Sam Mackellar"];
    [self.dummyEntryName addObject:@"F1Meir"];
    [self.dummyEntryName addObject:@"KrivKriv"];
    [self.dummyEntryName addObject:@"Graeme Weston"];
    [self.dummyEntryName addObject:@"Gareth Griffith"];
    [self.dummyEntryName addObject:@"Graeme Weston"];
    [self.dummyEntryName addObject:@"Bruce Steinberg"];
    [self.dummyEntryName addObject:@"KrivKriv"];
    [self.dummyEntryName addObject:@"Gareth Griffith"];
    [self.dummyEntryName addObject:@"Graeme Weston"];
    
    [self.dummyEntryUserId addObject:@"TheSteinberg "];
    [self.dummyEntryUserId addObject:@"SMackellar101 "];
    [self.dummyEntryUserId addObject:@"SMackellar101 "];
    [self.dummyEntryUserId addObject:@"F1Meir "];
	[self.dummyEntryUserId addObject:@"KrivKriv "];
	[self.dummyEntryUserId addObject:@"GrayW "];
    [self.dummyEntryUserId addObject:@"GG "];
    [self.dummyEntryUserId addObject:@"GrayW "];
    [self.dummyEntryUserId addObject:@"TheSteinberg "];
    [self.dummyEntryUserId addObject:@"KrivKriv "];
    [self.dummyEntryUserId addObject:@"GG "];
    [self.dummyEntryUserId addObject:@"GrayW "];
	
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"The-Steinberg.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"SMackellar.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"SMackellar.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"F1Meir.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"KrivKriv.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"GrayW.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"GG.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"GrayW.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"The-Steinberg.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"KrivKriv.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"GG.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"GrayW.png"]];
    
    [self.dummyEntryComment addObject:@"Hey! U should check out the VIP area!"];
    [self.dummyEntryComment addObject:@"Check out the exclusive with Jenson Button in the VIP area!!!"];
    [self.dummyEntryComment addObject:@"he is so cute. Hehe ;-)"];
    [self.dummyEntryComment addObject:@"Did you see that overtake! Look at it from his onboard"];
    [self.dummyEntryComment addObject:@"Anyone got an F1 cap? They look awesome!"];
    [self.dummyEntryComment addObject:@"You can get caps at the F1 store."];
    [self.dummyEntryComment addObject:@"Check out the start from Alonso's onboard. Amazing!"];
    [self.dummyEntryComment addObject:@"Guys - check out the pitcam - new nose for Kobayashi..."];
    [self.dummyEntryComment addObject:@"That's Webber's first non-finish of the season."];
    [self.dummyEntryComment addObject:@"The championship is Vettel's now."];
    [self.dummyEntryComment addObject:@"Wach that Vettel move in slow motion. That was brave!"];
    [self.dummyEntryComment addObject:@"Jenson is looking quicker than Lewis today."];
    
}

- (NSString *)getDefaultText{
    return @"message";
}

- (NSString *)getCommentText:(int)row {
    NSString *ret = nil;
    
    NSString *comment = [self.entryComment objectAtIndex:row];
    if ([comment characterAtIndex:0] == '@')
    {
        // Assume starts with a tweet name...
        //(NSRange)rangeOfString:(NSString *)aString
        NSRange rnge = [comment rangeOfString:@" "];
        NSString *tname = [comment substringToIndex:rnge.location];
        NSString *remcomment = [comment substringFromIndex:rnge.location + rnge.length];
        NSString *newcomment = [[NSString alloc] initWithFormat:@"<div><font color=\"blue\">%@</font><font color=\"white\">&nbsp;%@</font></div>", tname, remcomment];
        ret = newcomment;
    }
    else
    {
        ret = [self.entryComment objectAtIndex:row];
    }
    
    return ret;
}

- (CGRect)getTimeTextFrame:(CGFloat)height{
    return CGRectMake(42, 3, 280, 20);
}

- (CGRect)getNameTextFrame{
    return CGRectMake(68, 3, 200, 22);
}

- (CGRect)getCommentTextFrame:(CGFloat)height{
    return CGRectMake(60, 13, 246, height + 10);
}

- (UIColor *)getTextColour {
    UIColor *ret = [UIColor whiteColor];    
    return ret;
}

- (UIColor *)getCellBackColour {
    UIColor *ret = [UIColor colorWithRed: 0.35 green: 0.35 blue: 0.35 alpha: 1];    
    return ret;
}

- (UIImage *)getHeaderIcon {
    UIImage *ret = [UIImage imageNamed:@"Midas-front-layer.png"];
    return ret;
}

- (CGRect)getSendTextFrame {
    return CGRectMake(40, 49, 246, 27);
}

- (UIImage *)getFooterText{
    UIImage *ret = [UIImage imageNamed:@"Midas-title.png"];
    return ret;
}

- (UIImage *)getFooterLogo{
    UIImage *ret = [UIImage imageNamed:@"Midas-icon.png"];
    return ret;
}

- (UIImage *)getSendLogo{
    UIImage *ret = nil;
    return ret;
}

- (UIColor *)getSeparatorColour {
    //UIColor *ret = [UIColor blackColor];    
    UIColor *ret = [UIColor colorWithRed: 0.45 green: 0.45 blue: 0.45 alpha: 1];    
    return ret;
}

- (BOOL)canPostReply{
    return NO;
}

- (CGFloat)heightForRowAtIndexPath:(CGFloat)row{
    NSString *text = [self getUnformattedCommentText:row];
    CGFloat height = [self getTextHeight:text];
    int numoflines = height / 15;
    if (numoflines > 1)
    {
        height += 6;
    }
    if (self.replyRow == row)
    {
        height += 44;
    }
    height += 10;
    
    return height + 20;
}

@end

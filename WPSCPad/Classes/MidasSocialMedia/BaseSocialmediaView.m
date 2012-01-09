//
//  BaseSocialmediaViewController.m
//  F1Test
//
//  Created by Andrew Greenshaw on 05/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseSocialmediaView.h"

@interface UITextView (extended)
- (void)setContentToHTMLString:(NSString *) contentText;
@end

@implementation BaseSocialmediaView

#define kTestDataLen    12

#define kHeaderHeight   44
#define kViewHeight     432

static NSUInteger const kTimeTag = 1;
static NSUInteger const kNameTag = 2;
static NSUInteger const kImageTag = 3;
static NSUInteger const kCommentTag = 4;
static NSUInteger const kIconTag = 5;
static NSUInteger const kTextTag = 6;
static NSUInteger const kRepliedIconTag = 7;
static NSUInteger const kLikeTag = 8;

@synthesize delegate = _delegate;

@synthesize view;
@synthesize topBackView;

@synthesize visible;
@synthesize replying;
@synthesize replyRow;

@synthesize bottomBackGraphic;
@synthesize topBackGraphic;
@synthesize topSendIcon;
@synthesize bottomIconGraphic;
@synthesize bottonSocialTypeGraphic;
@synthesize socialTable;
@synthesize sendText;

@synthesize entryTime;
@synthesize entryName;
@synthesize entryImage;
@synthesize entryComment;
@synthesize entryUserId;
@synthesize entryReplied;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"BaseSocialmediaView" owner:self options:nil];
        [self addSubview:self.view];
        self.topBackView.backgroundColor = [self getCellBackColour];
        self.topBackView.alpha = kAlphaValue;

        self.socialTable.alpha = kAlphaValue;
        self.socialTable.separatorColor = [self getSeparatorColour];
        self.sendText.alpha = kAlphaValue;
        // Might not have an icon ?
        self.sendText.frame = [self getSendTextFrame];
        self.sendText.placeholder = [self getDefaultText];

        //self.socialTable.backgroundColor = [self getCellBackColour];
        
        self.bottomBackGraphic.image = [self getFooterIcon];
        self.topBackGraphic.image = [self getHeaderIcon];
        self.topSendIcon.image = [self getSendLogo];
        self.bottomIconGraphic.image = [self getFooterLogo];
        self.bottonSocialTypeGraphic.image = [self getFooterText];
        
        self.bottomBackGraphic.alpha = kAlphaValue;
        self.topBackGraphic.alpha = kAlphaValue;
        self.topSendIcon.alpha = kAlphaValue;
        self.bottomIconGraphic.alpha = kAlphaValue;
        self.bottonSocialTypeGraphic.alpha = kAlphaValue;
        
        [self loadData];
        
        UITapGestureRecognizer *dTap = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(handleTap:)];
        
        dTap.numberOfTapsRequired = 1;
//#ifdef HANDLE_SHOW_HIDE_INTERNALLY
        [self.view addGestureRecognizer:dTap];
//#endif
        
        self.visible = NO;
        self.replying = NO;
        self.replyRow = -1;
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.view];
    [self loadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

// Helper functions to be overridden

- (NSString *)getTimeEntry:(int)offset
{
    NSString *currentTime = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    if (offset >= 0)
    {
        currentTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(-2000 + offset * 129)]];
    }
    else
    {
        currentTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
    return currentTime;
}

- (void)loadData {
    self.entryTime = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];

    for (int i = 0; i < kTestDataLen; i++)
    {
        [self.entryTime addObject:[self getTimeEntry:i]];
    }

    [self.entryName addObject:@"John J"];
    [self.entryName addObject:@"Freddie F1"];
    [self.entryName addObject:@"Mary Jane"];
    [self.entryName addObject:@"Chris"];
    [self.entryName addObject:@"Hazel I"];
    [self.entryName addObject:@"Jake BBCF1"];
    [self.entryName addObject:@"Eddie I BBCF1"];
    [self.entryName addObject:@"R Schumacher"];
    [self.entryName addObject:@"Chris F1 Fan"];
    [self.entryName addObject:@"Marky Boy"];
    [self.entryName addObject:@"Kylie M"];
    [self.entryName addObject:@"Nigel Mansell"];
    
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    
    [self.entryComment addObject:@"John J Comment"];
    [self.entryComment addObject:@"Freddie F1 Comment"];
    [self.entryComment addObject:@"Mary Jane Comment Mary Jane Comment Mary Jane Comment"];
    [self.entryComment addObject:@"Chris Comment"];
    [self.entryComment addObject:@"Hazel I Comment Hazel I Comment Hazel I Comment"];
    [self.entryComment addObject:@"Jake BBCF1 Comment"];
    [self.entryComment addObject:@"Eddie I BBCF1 Comment"];
    [self.entryComment addObject:@"R Schumacher Comment"];
    [self.entryComment addObject:@"Chris F1 Fan Comment"];
    [self.entryComment addObject:@"Marky Boy Comment"];
    [self.entryComment addObject:@"Kylie M Comment"];
    [self.entryComment addObject:@"Nigel Mansell Comment Nigel Mansell Comment"];

    [self.entryUserId addObject:@"@johnj "];
    [self.entryUserId addObject:@"@freddief1 "];
    [self.entryUserId addObject:@"@maryjane "];
    [self.entryUserId addObject:@"@chris "];
    [self.entryUserId addObject:@"@hazeli "];
    [self.entryUserId addObject:@"@jakebbc1 "];
    [self.entryUserId addObject:@"@eddiebbc1 "];
    [self.entryUserId addObject:@"@rschumacher "];
    [self.entryUserId addObject:@"@chrisf1 "];
    [self.entryUserId addObject:@"@markyboy "];
    [self.entryUserId addObject:@"@kyliem "];
    [self.entryUserId addObject:@"@nigelmansell "];
    
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
}

- (void)scrollUpStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    self.visible = NO;
    [self.delegate baseSocialmediaHidden:self];
}

- (void)scrollDownStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    self.visible = YES;
    [self.delegate baseSocialmediaShown:self];
}

- (BOOL)isVisible {
    return (self.visible);
}

- (void)hideReplying {
    if (self.replying)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:self.replyRow inSection:0];
        UITableViewCell *cell = [self.socialTable cellForRowAtIndexPath:(NSIndexPath *)ipath];
        UIImageView *cIcon = (UIImageView *)[cell.contentView viewWithTag:kIconTag];
        UITextField *cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
        [cText resignFirstResponder];
        cIcon.hidden = YES;
        cText.hidden = YES;
        cText.text = [self.entryUserId objectAtIndex:self.replyRow];
        self.replying = NO;
        self.replyRow = -1;
        [self.socialTable beginUpdates];
        [self.socialTable endUpdates];
    }
}

- (void)showView:(CGFloat)slideDuration {
    if (self.visible == NO)
    {
        [self.delegate baseSocialmediaAboutToShow:self];

        CGRect rect = self.frame;
        rect.origin.y = -kViewHeight;
        self.frame = rect;
        
        [UIView beginAnimations:nil context:@"scroll down"];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
        
        [UIView setAnimationDuration:slideDuration];
        
        rect.origin.y = 0;
        self.frame = rect;
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(scrollDownStop:finished:context:)];
        
        [UIView commitAnimations]; 
        
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:[self.entryTime count] - 1 inSection:0];
        [self.socialTable scrollToRowAtIndexPath :ipath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)showViewAtPos:(CGFloat)slideDuration:(int)atXpos {
    if (self.visible == NO)
    {
        CGRect rect = self.frame;
    
        rect.origin.x = atXpos;
        self.frame = rect;
    
        [self showView:slideDuration];
    }
}

- (void)hideView:(CGFloat)slideDuration {
#ifdef INTERNAL_HIDE_SHOW
    if (self.visible)
    {
        CGRect rect = self.frame;
        
        [UIView beginAnimations:nil context:@"scroll up"];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
        
        [UIView setAnimationDuration:slideDuration];
        
        rect.origin.y = -kViewHeight;
        self.frame = rect;
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(scrollUpStop:finished:context:)];
        
        [UIView commitAnimations]; 
    }
#endif
}

- (void)reshowData {
    [self.socialTable reloadData];
    if (self.replying)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:self.replyRow inSection:0];
        UITableViewCell *cell = [self.socialTable cellForRowAtIndexPath:(NSIndexPath *)ipath];
        UITextField *cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
        [cText becomeFirstResponder];
        [self.socialTable scrollToRowAtIndexPath :ipath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)scrollToEnd {
    NSIndexPath *ipath = [NSIndexPath indexPathForRow:[self.entryTime count] - 1 inSection:0];
    [self.socialTable scrollToRowAtIndexPath :ipath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)     
    {   
        CGPoint locationInView = [sender locationInView:self]; 
        //NSLog(@"x=%f, y=%f", locationInView.x, locationInView.y);
        CGRect frame = self.frame;
        if (frame.origin.y > -50 /* is shown */)
        {
            if (locationInView.y < kHeaderHeight)
            {
                [self hideReplying];
                [self.sendText resignFirstResponder];
                [self.delegate baseSocialmediaAboutToHide:self];
                [self hideView:0.5];
#ifndef INTERNAL_HIDE_SHOW
                self.visible = NO;
#endif
            }
            else if (locationInView.y > 2 * kHeaderHeight && locationInView.y < self.frame.size.height - kHeaderHeight)
            {
                locationInView = [sender locationInView:self.socialTable];
                // clicked in table - get row under "point"
                NSIndexPath *ipath = [self.socialTable indexPathForRowAtPoint:locationInView];
                if (ipath != nil && [self canPostReply])
                {
                    //NSLog(@"Row = %d", [ipath row]);
                    UITableViewCell *cell = [self.socialTable cellForRowAtIndexPath:(NSIndexPath *)ipath];
                    UIImageView *cIcon = (UIImageView *)[cell.contentView viewWithTag:kIconTag];
                    UITextField *cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];

                    if (self.replying == YES)
                    {
                        if (self.replyRow == [ipath row])
                        {
                            // Just remove the "replying" bit
                            self.replying = NO;
                            self.replyRow = -1;
                            cIcon.hidden = YES;
                            cText.hidden = YES;
                        }
                        else
                        {
                            // Reply on a new row
                            self.replyRow = [ipath row];
                            cIcon.hidden = YES;
                            cText.hidden = YES;
                        }
                    }
                    else
                    {
                        // Expand reply row...
                        self.replying = YES;
                        self.replyRow = [ipath row];
                    }
                    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(reshowData) userInfo:nil repeats:NO];
                    [self.socialTable beginUpdates];
                    [self.socialTable endUpdates];
                }
            }
        }
    } 
}

- (void)addEntry:(NSString *)text {
    [self.entryTime addObject:[self getTimeEntry:-1]];
    
    [self.entryName addObject:@"Peter Rand"];
    
    [self.entryImage addObject:[UIImage imageNamed:@"activeuser.png"]];
    
    [self.entryComment addObject:text];
    
    [self.entryUserId addObject:@"@peterrand "];
    
    [self.entryReplied addObject:@"NO"];

    [self.socialTable reloadData];
    
    [self.socialTable beginUpdates];
    [self.socialTable endUpdates];
}

- (CGRect)getSendTextFrame {
    return CGRectMake(44, 50, 246, 31);
}

- (CGRect)getTimeTextFrame:(CGFloat)height{
    return CGRectMake(44, 6, 280, 20);
}

- (CGRect)getNameTextFrame{
    return CGRectMake(80, 6, 200, 22);
}

- (CGRect)getCommentTextFrame:(CGFloat)height{
    return CGRectMake(72, 22, 210, height + 10);
}

- (UIColor *)getCellBackColour {
    UIColor *ret = [UIColor lightGrayColor];
    
    return ret;
}

- (NSString *)getDefaultText{
    return @"tweet";
}

- (UIImage *)getHeaderIcon {
    UIImage *ret = [UIImage imageNamed:@"Twitter-front-layer.png"];
    return ret;
}

- (UIImage *)getFooterIcon{
    UIImage *ret = [UIImage imageNamed:@"twitter-selected.png"];
    return ret;
}

- (UIImage *)getFooterText{
    UIImage *ret = [UIImage imageNamed:@"Twitter-title.png"];
    return ret;
}

- (UIImage *)getFooterLogo{
    UIImage *ret = [UIImage imageNamed:@"Twitter-icon.png"];
    return ret;
}

- (UIImage *)getSendLogo{
    UIImage *ret = [UIImage imageNamed:@"Twitter-mini-icon.png"];
    return ret;
}

- (UIImage *)getRepliedIcon{
    UIImage *ret = [UIImage imageNamed:@"Twitter-reply-icon.png"];
    return ret;
}

- (NSString *)getReplyPrefix:(int)row {
    return ([self.entryUserId objectAtIndex:row]);
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
        NSString *newcomment = [[NSString alloc] initWithFormat:@"<div><font color=\"blue\">%@</font><font color=\"black\">&nbsp;%@</font></div>", tname, remcomment];
        ret = newcomment;
    }
    else
    {
        ret = [self.entryComment objectAtIndex:row];
    }
    
    return ret;
}

- (NSString *)getUnformattedCommentText:(int)row {
    return [self.entryComment objectAtIndex:row];
}

-(CGFloat)getTextHeight:(NSString *)text
{
	CGFloat ret = 0.0;
	text = [text stringByReplacingOccurrencesOfString:@" \n" withString:@""];
	text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	CGSize stringSize = [text sizeWithFont:[UIFont fontWithName:@"Arial-BoldMT" size:15] constrainedToSize:CGSizeMake(248, 9999) lineBreakMode:UILineBreakModeWordWrap];
	ret = stringSize.height;
	return ret;
}

- (UIColor *)getTextColour {
    UIColor *ret = [UIColor blackColor];    
    return ret;
}

- (UIColor *)getSeparatorColour {
    UIColor *ret = [UIColor darkGrayColor];    
    return ret;
}

- (BOOL)canPostReply {
    return YES;
}

- (BOOL)canLike{
    return NO;
}

- (CGFloat)heightForRowAtIndexPath:(CGFloat)row{
    CGFloat height = [self getTextHeight:[self.entryComment objectAtIndex:row]] + 36;
    if (self.replyRow == row)
    {
        if (height < 70)
        {
            height = 74;
        }
        height += 40;
    }
    
    return height;
}

- (IBAction)doLike:(id)sender
{
    UIButton *from = (UIButton *)sender;
    NSString *text = from.currentTitle;
    if ([text isEqualToString:@"- Like"])
    {
        [from setTitle:@"- Unlike" forState:UIControlStateNormal];
    }
    else
    {
        [from setTitle:@"- Like" forState:UIControlStateNormal];
    }
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger ret = [self.entryTime count];
    
    return ret;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellId = [[NSString alloc] initWithFormat:@"CellId_%d", [indexPath row]];
	
	UILabel *cTime = nil;
	UILabel *cName = nil;
	UIImageView *cImage = nil;
	UITextView *cComment = nil;
	UIImageView *cIcon = nil;
    UITextField *cText = nil;
    //UITextView *cText = nil;
	UIImageView *cRepliedIcon = nil;
    UIButton *cLike =nil;
    
    int row = [indexPath row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];

        //UIView *cellbackView = [[UIView alloc] initWithFrame:CGRectZero];
        //cellbackView.backgroundColor = [self getCellBackColour];
        //cellbackView.alpha = 0;
        
        //cell.backgroundView = cellbackView;
        NSString *tempcommenttext = [self getUnformattedCommentText:row];
        CGFloat tHeight = [self getTextHeight:tempcommenttext];

        cTime = [[UILabel alloc] initWithFrame:[self getTimeTextFrame:tHeight]];
        cTime.font = [UIFont systemFontOfSize:9];
        cTime.tag = kTimeTag;
        cTime.alpha = kAlphaValue;
        cTime.backgroundColor = [UIColor clearColor];
        cTime.textColor = [self getTextColour];
        [cell.contentView addSubview:cTime];
        
        cName = [[UILabel alloc] initWithFrame:[self getNameTextFrame]];
        cName.font = [UIFont boldSystemFontOfSize:15];
        cName.tag = kNameTag;
        cName.alpha = kAlphaValue;
        cName.backgroundColor = [UIColor clearColor];
        cName.textColor = [self getTextColour];
        [cell.contentView addSubview:cName];
        
        cImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 26, 26)];
        cImage.tag = kImageTag;
        cImage.alpha = kAlphaValue;
        [cell.contentView addSubview:cImage];
        
        int numoflines = tHeight / 15;
        //cComment = [[UITextView alloc] initWithFrame:CGRectMake(80, 26, 210, tHeight)];
        cComment = [[UITextView alloc] initWithFrame:[self getCommentTextFrame:tHeight]];
        cComment.font = [UIFont systemFontOfSize:15];
        //cComment.lineBreakMode = UILineBreakModeWordWrap;
        //cComment.numberOfLines = tHeight / 15;
        cComment.tag = kCommentTag;
        cComment.alpha = kAlphaValue;
        cComment.userInteractionEnabled = NO;
        cComment.backgroundColor = [UIColor clearColor];
        cComment.textAlignment = UITextAlignmentLeft;
        cComment.textColor = [self getTextColour];
        [cell.contentView addSubview:cComment];
        
        cIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, tHeight + 38 + ((numoflines == 1) ? 19 : 0), 44, 44)];
        cIcon.tag = kIconTag;
        cIcon.alpha = kAlphaValue;
        cIcon.hidden = YES;
        cIcon.image = [self getSendLogo];
        [cell.contentView addSubview:cIcon];
        
        cText = [[UITextField alloc] initWithFrame:CGRectMake(42, tHeight + 40 + ((numoflines == 1) ? 19 : 0), 250, 31)];
        //cText = [[UITextView alloc] initWithFrame:CGRectMake(48, tHeight + 40 + ((cComment.numberOfLines == 1) ? 19 : 0), 242, 31)];
        cText.tag = kTextTag;
        cText.alpha = kAlphaValue;
        cText.hidden = YES;
        cText.delegate = self;
        cText.textAlignment = UITextAlignmentLeft;
        cText.borderStyle = UITextBorderStyleRoundedRect;
        cText.backgroundColor = [UIColor whiteColor];
        cText.keyboardAppearance = UIKeyboardAppearanceDefault;
        cText.keyboardType = UIKeyboardTypeDefault;
        cText.returnKeyType = UIReturnKeySend;
        cText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        cText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        cText.clearButtonMode = UITextFieldViewModeAlways;
        cText.enablesReturnKeyAutomatically = YES;
        cText.textColor = [self getTextColour];
        [cell.contentView addSubview:cText];
        
        cRepliedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(280, 12, 8, 8)];
        cRepliedIcon.tag = kRepliedIconTag;
        cRepliedIcon.alpha = kAlphaValue;
        cRepliedIcon.hidden = YES;
        NSString *replied = [self.entryReplied objectAtIndex:row];
        if ([replied isEqualToString:@"YES"])
        {
            cRepliedIcon.hidden = NO;
        }
        cRepliedIcon.image = [self getRepliedIcon];
        [cell.contentView addSubview:cRepliedIcon];
    
        if ([self canLike])
        {
            cLike = [UIButton buttonWithType:UIButtonTypeCustom];
            cLike.tag = kLikeTag;
            cLike.alpha = kAlphaValue;
            cLike.enabled = YES;
            cLike.userInteractionEnabled = YES;
            [cLike addTarget:self action:@selector(doLike:) forControlEvents:UIControlEventTouchDown];
            [cLike setTitle:@"- Like" forState:UIControlStateNormal];
            [cLike setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            CGRect frame = [self getTimeTextFrame:tHeight];
            frame.origin.x += 160;
            frame.origin.y -= 14;
            frame.size.width = 50;
            frame.size.height = 50;
            cLike.frame = frame;            
            cLike.titleLabel.font = [UIFont systemFontOfSize:11];
            [cell.contentView addSubview:cLike];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.alpha = 0;
        
        cell.backgroundView.frame = CGRectMake(0, 0, 300, 60);
    }
    else
    {
        cTime = (UILabel *)[cell.contentView viewWithTag:kTimeTag];
        cName = (UILabel *)[cell.contentView viewWithTag:kNameTag];
        cImage = (UIImageView *)[cell.contentView viewWithTag:kImageTag];
        cComment = (UITextView *)[cell.contentView viewWithTag:kCommentTag];
        cIcon = (UIImageView *)[cell.contentView viewWithTag:kIconTag];
        cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
        cRepliedIcon = (UIImageView *)[cell.contentView viewWithTag:kRepliedIconTag];
        cLike = (UIButton *)[cell.contentView viewWithTag:kLikeTag];
    }
    cTime.text = [self.entryTime objectAtIndex:row];
    cName.text = [self.entryName objectAtIndex:row];
    cImage.image = [self.entryImage objectAtIndex:row];
    [cComment setContentToHTMLString:[self getCommentText:row]];

    cText.text = [self getReplyPrefix:row];
    //NSString *str = [[NSString alloc] initWithFormat:@"<div><font color=\"blue\">%@</font><font color=\"black\">&nbsp;</font></div>", cText.text = [self getReplyPrefix:row]];
    //[cText setContentToHTMLString:str];
 
    if (self.replying && self.replyRow == row)
    {
        cIcon.hidden = NO;
        cText.hidden = NO;
    }
    else
    {
        cIcon.hidden = YES;
        cText.hidden = YES;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ([self heightForRowAtIndexPath:[indexPath row]]);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
    //[cell setBackgroundColor:[self getCellBackColour]];
    //cell.alpha = kAlphaValue + 0.125;
}

#pragma mark UITextField methods
- (IBAction)sendTextFieldEntered:(id)sender {
    [self hideReplying];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL ret = NO;
    if (self.replying == NO && [self.sendText.text length] > 0)
    {
        [self.sendText resignFirstResponder];
        [self addEntry:self.sendText.text];
        self.sendText.text = @"";
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
        ret = YES;
    }
    if (self.replying)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:self.replyRow inSection:0];
        UITableViewCell *cell = [self.socialTable cellForRowAtIndexPath:(NSIndexPath *)ipath];
        UITextField *cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
        UIImageView *cRepliedIcon = (UIImageView *)[cell.contentView viewWithTag:kRepliedIconTag];
        if ([cText.text length] > 0)
        {
            [self addEntry:cText.text];
            cRepliedIcon.hidden = NO;
            [self.entryReplied replaceObjectAtIndex:self.replyRow withObject:@"YES"];
            [self hideReplying];
            ret = YES;
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
        }
    }
    return ret;
}

#pragma mark UITextView methods

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    if (self.replying)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:self.replyRow inSection:0];
        UITableViewCell *cell = [self.socialTable cellForRowAtIndexPath:(NSIndexPath *)ipath];
        UITextField *cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
        UIImageView *cRepliedIcon = (UIImageView *)[cell.contentView viewWithTag:kRepliedIconTag];
        if ([cText.text length] > 0)
        {
            [self addEntry:cText.text];
            cRepliedIcon.hidden = NO;
            [self.entryReplied replaceObjectAtIndex:self.replyRow withObject:@"YES"];
            [self hideReplying];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
        }
    }
    return NO;
}

@end

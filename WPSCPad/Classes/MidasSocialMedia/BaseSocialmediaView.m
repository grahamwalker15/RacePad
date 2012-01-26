//
//  BaseSocialmediaViewController.m
//  F1Test
//
//  Created by Andrew Greenshaw on 05/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseSocialmediaView.h"

#ifdef USE_REAL_TWITTER
#import <Accounts/Accounts.h>
#endif

//#define HANDLE_SHOW_HIDE_INTERNALLY

@interface UITextView (extended)
- (void)setContentToHTMLString:(NSString *) contentText;
@end

@implementation BaseSocialmediaView

#define kTestDataLen    12

//#define INTERNAL_HIDE_SHOW

static NSUInteger const kTimeTag = 1;
static NSUInteger const kNameTag = 2;
static NSUInteger const kImageTag = 3;
static NSUInteger const kCommentTag = 4;
static NSUInteger const kIconTag = 5;
static NSUInteger const kTextTag = 6;
static NSUInteger const kRepliedIconTag = 7;
static NSUInteger const kLikeTag = 8;
static NSUInteger const kTwitterTag = 9;
static NSUInteger const kDivideTag = 10;
static NSUInteger const kTwitReplyTag = 11;

@synthesize delegate = _delegate;

@synthesize view;
@synthesize topBackView;

@synthesize visible;
@synthesize replying;
@synthesize replyRow;
@synthesize lastMessageCount;

@synthesize bottomBackGraphic;
@synthesize topBackGraphic;
@synthesize topSendIcon;
@synthesize bottomIconGraphic;
@synthesize bottonSocialTypeGraphic;
@synthesize socialTable;
@synthesize userIcon;
@synthesize userName;
@synthesize sendText;
@synthesize sendButton;

@synthesize shad1;
@synthesize shad2;
@synthesize shad2_1;
@synthesize shad3;
@synthesize shad4;

@synthesize entryTimings;
@synthesize entryTime;
@synthesize entryName;
@synthesize entryImage;
@synthesize entryComment;
@synthesize entryUserId;
@synthesize entryReplied;

@synthesize dummyEntryName;
@synthesize dummyEntryImage;
@synthesize dummyEntryComment;
@synthesize dummyEntryUserId;

@synthesize twitUser;
@synthesize twitUserName;
@synthesize twitImage;

@synthesize addedRows;

@synthesize viewType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"MidasBaseSocialmediaView" owner:self options:nil];

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

#ifndef INTEGRATED_IN_MIDAS
        self.bottomBackGraphic.image = [self getFooterIcon];
        self.bottomIconGraphic.image = [self getFooterLogo];
        self.bottonSocialTypeGraphic.image = [self getFooterText];
        
        self.bottomBackGraphic.alpha = kAlphaValue;
		self.bottomIconGraphic.alpha = kAlphaValue;
        self.bottonSocialTypeGraphic.alpha = kAlphaValue;
#endif
        self.topBackGraphic.image = [self getHeaderIcon];
        self.topSendIcon.image = [self getSendLogo];
        
        self.topBackGraphic.alpha = kAlphaValue;
        self.topSendIcon.alpha = kAlphaValue;
 		
        self.lastMessageCount = 0;
        
        self.sendButton.hidden = YES;
		
        self.shad1.hidden = YES;
        self.shad2.hidden = YES;
        self.shad2_1.hidden = YES;
        self.shad3.hidden = YES;
        self.shad4.hidden = YES;
        
        self.userIcon.alpha = kAlphaValue;
        self.userName.alpha = kAlphaValue;
        self.twitUser = @"";
        self.twitUserName = @"";
        self.twitImage = nil;
        [self getTwitUser];
        [self loadData];
		
        UISwipeGestureRecognizer *dSwipe = [[UISwipeGestureRecognizer alloc]
											initWithTarget:self action:@selector(handleSwipe:)];
        dSwipe.direction = UISwipeGestureRecognizerDirectionUp;
        
#ifdef HANDLE_SHOW_HIDE_INTERNALLY
        [self.view addGestureRecognizer:dSwipe];
#endif
        UITapGestureRecognizer *dTap = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(handleTap:)];
        
        dTap.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:dTap];
        
        self.visible = NO;
        self.replying = NO;
        self.replyRow = -1;
        self.addedRows = 0;
		
		lastEntryCount = 0;
		
		int messageType = (self.viewType == Twitter) ? MIDAS_SM_TWITTER_ : (self.viewType == Facebook) ? MIDAS_SM_FACEBOOK_ : MIDAS_SM_MIDAS_CHAT_;
		[[MidasCoordinator Instance] AddSocialmediaSource:self WithType:messageType];

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

- (void)updateNameAndImage:(id)sender
{
    [self.userIcon setImage:self.twitImage];
    self.userName.text = self.twitUserName;
    [self.userIcon setNeedsLayout];
    [self.userName setNeedsLayout];
}

- (void)getTwitUser
{
#ifdef USE_REAL_TWITTER
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to access their Twitter account
    [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
     {
         // Did user allow us access?
         if (granted == YES)
         {
             // Populate array with all available Twitter accounts
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             
             // Sanity check
             if ([arrayOfAccounts count] > 0) 
             {
                 // Keep it simple, use the first account available
                 ACAccount *twitAccount = [arrayOfAccounts objectAtIndex:0];
                 
                 //NSLog(@"User = %@", twitAccount.username);
                 
                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                 [params setObject:twitAccount.username forKey:@"screen_name"];
                 //[params setObject:@"1" forKey:@"include_entities"];
                 
                 //  The endpoint that we wish to call
                 NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/users/show.json"];
                 
                 //  Build the request with our parameter 
                 TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodGET];
                 
                 // Post the request
                 [request setAccount:twitAccount];
                 
                 // Block handler to manage the response
                 [request performRequestWithHandler:^(NSData *rponseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                  {
                      NSString *responseString = [[NSString alloc] initWithData:rponseData encoding:NSUTF8StringEncoding];
                      //NSLog(@"resp %@", responseString);
                      //NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
                      if (error != nil) 
                      {
                          // inspect the contents of error 
                          NSLog(@"%@", error);
                      } 
                      else 
                      {
                          NSError *jsonError = nil;
                          NSDictionary *aTweet = [responseString JSONValue];
                          
                          if (jsonError == nil && aTweet) 
                          {
                              //NSLog(@"%@", responseString);
                              self.twitUser = twitAccount.username;
                              self.twitUserName = [aTweet objectForKey:@"name"];
                              NSURL *url = [NSURL URLWithString:[aTweet objectForKey:@"profile_image_url"]];
                              NSData *data = [NSData dataWithContentsOfURL:url];
                              UIImage *tmpImage = [UIImage imageWithData:data];
                              
                              self.twitImage = [self resizeImage:tmpImage width:26 height:26];
                              [self performSelectorOnMainThread:@selector(updateNameAndImage:) withObject:nil waitUntilDone:NO];
                          } 
                      }
                  }];
             }
         }
     }];
	
#else
    
    self.twitUser = @"@peterrand ";
    self.twitUserName = @"Peter Rand";
    self.twitImage = [UIImage imageNamed:@"user1.png"];
    
    [self.userIcon setImage:self.twitImage];
    self.userName.text = self.twitUserName;   
    
#endif
}

// Helper functions to be overridden

- (BOOL)haveNewMessage 
{
    BOOL ret = NO;
    
    if (self.lastMessageCount < [self.entryTime count])
    {
        ret = YES;
        self.lastMessageCount = [self.entryTime count];
    }
    
    return ret;
}

- (NSString *)getTimeEntry:(int)offset
{
    NSString *currentTime = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    if (offset >= 0)
    {
        currentTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(-5000 + offset * 129)]];
    }
    else
    {
        currentTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
    return currentTime;
}

- (void)loadData {
}

- (void)insertDummyEntry:(int)row
{
    [self.entryTime insertObject:[self getTimeEntry:-1] atIndex:0];
    [self.entryName insertObject:[self.dummyEntryName objectAtIndex:row] atIndex:0];
    [self.entryImage insertObject:[self.dummyEntryImage objectAtIndex:row] atIndex:0];
    [self.entryComment insertObject:[self.dummyEntryComment objectAtIndex:row] atIndex:0];
    [self.entryUserId insertObject:[self.dummyEntryUserId objectAtIndex:row] atIndex:0];
    [self.entryReplied insertObject:@"NO" atIndex:0];                                  
}

- (void)__checkForNewMessages:(CGFloat)mTime {
    if (mTime >= 0.0 && self.replying == NO)
    {        
        for (int i = 0; i < [self.entryTimings count]; i++)
        {
            CGFloat aFloat = [[self.entryTimings objectAtIndex:i] floatValue];
            if (mTime > aFloat - 0.1/* && mTime < aFloat + 0.1*/)
            {
                [self insertDummyEntry:i];
                [self.socialTable reloadData];
                [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
            }
        }
    }
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
        UIButton *ctwitReply = (UIButton *)[cell.contentView viewWithTag:kTwitReplyTag];
        [cText resignFirstResponder];
        cIcon.hidden = YES;
        cText.hidden = YES;
        cText.text = [self.entryUserId objectAtIndex:self.replyRow];
        ctwitReply.hidden = YES;
        self.replying = NO;
        self.replyRow = -1;
        [self.sendText resignFirstResponder];
        
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
    [self.delegate baseSocialmediaAboutToHide:self];
    [self hideReplying];
    [self.sendText resignFirstResponder];
    
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

- (void)setDefaultUser:(NSString *)userDisplayName:(NSString *)newUserName:(NSString *)userImageName {
    self.twitUser = newUserName;
    self.twitUserName = userDisplayName;
    self.twitImage = [UIImage imageNamed:userImageName];
    [self updateNameAndImage:nil];
}

- (void)reshowData {    
    [self.socialTable reloadData];
    if (self.replying)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:self.replyRow inSection:0];
        UITableViewCell *cell = [self.socialTable cellForRowAtIndexPath:(NSIndexPath *)ipath];
        UITextField *cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
        [cText becomeFirstResponder];
        if (self.replyRow > 0)
        {
            [self.socialTable scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }
}

- (void)scrollToEnd {
    if ([self.entryTime count] > 0)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.socialTable scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)     
    {   
        CGPoint locationInView = [sender locationInView:self]; 
        //NSLog(@"x=%f, y=%f", locationInView.x, locationInView.y);
        CGRect frame = self.frame;
        if (frame.origin.y > -50 /* is shown */)
        {
            if (locationInView.y > frame.size.height - kHeaderHeight)
            {
                [self hideView:0.5];
#ifndef INTERNAL_HIDE_SHOW
                self.visible = NO;
#endif
            }
        }
    }
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
                [self hideView:0.5];
#ifndef INTERNAL_HIDE_SHOW
                self.visible = NO;
#endif
            }
            else if (locationInView.y > frame.size.height - kHeaderHeight)
            {
                [self hideView:0.5];
#ifndef INTERNAL_HIDE_SHOW
                self.visible = NO;
#endif
            }
            else if (0 && locationInView.y > 2 * kHeaderHeight && locationInView.y < self.frame.size.height - kHeaderHeight)
            {
                [self.sendText resignFirstResponder];
            }
			/* NO REPLY  NOW*/
#if 1
            else if (locationInView.y > ((self.viewType == Facebook) ? kHeaderHeight : 2 * kHeaderHeight)
                     && locationInView.y < self.frame.size.height - kHeaderHeight)
            {
                locationInView = [sender locationInView:self.socialTable];
                // clicked in table - get row under "point"
                NSIndexPath *ipath = [self.socialTable indexPathForRowAtPoint:locationInView];
                if (ipath != nil)// && [self canPostReply])
                {
                    //NSLog(@"Row = %d", [ipath row]);
                    UITableViewCell *cell = [self.socialTable cellForRowAtIndexPath:(NSIndexPath *)ipath];
                    UIImageView *cIcon = (UIImageView *)[cell.contentView viewWithTag:kIconTag];
                    UITextField *cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
                    UIButton *ctwitReply = (UIButton *)[cell.contentView viewWithTag:kTwitReplyTag];
					
                    CGPoint locationInButton = [sender locationInView:ctwitReply]; 
                    if (locationInButton.x > 0 && locationInButton.y > 0 && locationInButton.x < 36 && locationInButton.y < 14)
                    {
                        [self sendReply:cText];
                    }
                    else if (self.replying == YES)
                    {
                        if (self.replyRow == [ipath row])
                        {
                            // Just remove the "replying" bit
                            self.replying = NO;
                            self.replyRow = -1;
                            cIcon.hidden = YES;
                            cText.hidden = YES;
                            ctwitReply.hidden = YES;
                        }
                        else
                        {
                            // Reply on a new row
                            self.replyRow = [ipath row];
                            cIcon.hidden = YES;
                            cText.hidden = YES;
                            ctwitReply.hidden = YES;
                        }
                    }
                    else
                    {
                        // Expand reply row...
                        self.replying = YES;
                        self.replyRow = [ipath row];
                        //NSLog(@"Text = %@", [self.entryComment objectAtIndex:self.replyRow]);
                    }
                    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(reshowData) userInfo:nil repeats:NO];
                    [self.socialTable beginUpdates];
                    [self.socialTable endUpdates];
                }
            }
#endif
        }
    } 
}

- (void)addEntry:(NSString *)text {    
    [self.entryTime insertObject:[self getTimeEntry:-1] atIndex:0];
    
    NSNumber *aNumber = [NSNumber numberWithFloat:-1];
    [self.entryTimings insertObject:aNumber atIndex:0];
    
    [self.entryName insertObject:self.twitUserName atIndex:0];
	
    [self.entryImage insertObject:self.twitImage atIndex:0];
    
    [self.entryComment insertObject:text atIndex:0];
    
    NSString *tmpStr = [[NSString alloc] initWithFormat:@"%@ ", self.twitUser];
    [self.entryUserId insertObject:tmpStr atIndex:0];
    
    [self.entryReplied insertObject:@"NO" atIndex:0];
    
    self.addedRows++;
	
    [self.socialTable reloadData];  
    
    [self.socialTable beginUpdates];
    [self.socialTable endUpdates];
}

- (IBAction)sendButtonTweet:(id)sender
{
    if ([self.sendText.text length] > 0)
    {
        [self addEntry:self.sendText.text];
    }
    [self hideView:0.4];
    self.sendText.text = @"";
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
}

- (IBAction)sendReply:(id)sender
{
    UILabel *txtLab = (UILabel *)sender;
    if ([txtLab.text length] > 0)
    {
        [self addEntry:txtLab.text];
        [self hideView:0.4];
        txtLab.text = @"";
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
    }
}

- (CGRect)getSendTextFrame {
    return CGRectMake(40, 49, 213, 20);
}

- (CGRect)getTimeTextFrame:(CGFloat)height{
    return CGRectMake(42, 4, 280, 20);
}

- (CGRect)getNameTextFrame{
    return CGRectMake(42, 3, 200, 22);
}

- (CGRect)getCommentTextFrame:(CGFloat)height{
    return CGRectMake(34, 13, 246, height + 10);
}

- (UIColor *)getCellBackColour {
    //UIColor *ret = [UIColor lightGrayColor];
    UIColor *ret = [UIColor colorWithRed:0.92157 green:0.92157 blue:0.92157 alpha:1.0];
    
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
    UIImage *ret = [UIImage imageNamed:@"Twitter-mini-icon-blue.png"];
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
    if ([comment length] > 1 && [comment characterAtIndex:0] == '@')
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
	CGSize stringSize = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:10] constrainedToSize:CGSizeMake(246, 9999) lineBreakMode:UILineBreakModeWordWrap];
	ret = stringSize.height;
	return ret;
}

- (UIColor *)getTextColour {
    UIColor *ret = [UIColor blackColor];    
    return ret;
}

- (UIColor *)getSeparatorColour {
    UIColor *ret = [UIColor colorWithRed:0.8235 green:0.8235 blue:0.8235 alpha:1.0];
    return ret;
}

- (BOOL)canPostReply {
    return YES;
}

- (BOOL)canLike{
    return NO;
}

- (CGFloat)heightForRowAtIndexPath:(CGFloat)row{
    NSString *text = [self.entryComment objectAtIndex:row];
    CGFloat height = [self getTextHeight:text] + 30;
    if (self.replyRow == row)
    {
        height += 36;
    }
    //if ([self canPostReply])
    {
        height += 10;
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

- (IBAction)doLaunchTwitter:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://"]];    
}

-(UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height {
#if 0
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	
    alphaInfo = kCGImageAlphaNoneSkipLast;
	
	CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4 * width, CGImageGetColorSpace(imageRef), alphaInfo);
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
#endif
	return image;	
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger ret = [self.entryTime count];
    
    return ret;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *cellId = [[NSString alloc] initWithFormat:@"CellId_%d%d", [indexPath row], self.addedRows++];
	
	UILabel *cTime = nil;
	UILabel *cName = nil;
	UIImageView *cImage = nil;
	UITextView *cComment = nil;
	UIImageView *cIcon = nil;
    UITextField *cText = nil;
    //UITextView *cText = nil;
	UIImageView *cRepliedIcon = nil;
    UIButton *cLike =nil;
    UIButton *cTwitter =nil;
    UIImageView *cDivide = nil;
    UIButton *ctwitReply =nil;
    
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
        cTime.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
        cTime.tag = kTimeTag;
        //cTime.alpha = kAlphaValue;
        cTime.backgroundColor = [UIColor clearColor];
        cTime.textColor = [self getTextColour];
        cTime.text = [self.entryTime objectAtIndex:row];
        if (self.viewType == Twitter)
        {
            cTime.text = @"";
        }
        [cell.contentView addSubview:cTime];
        
        cName = [[UILabel alloc] initWithFrame:[self getNameTextFrame]];
        cName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        cName.tag = kNameTag;
        //cName.alpha = kAlphaValue;
        cName.backgroundColor = [UIColor clearColor];
        cName.textColor = [self getTextColour];
        cName.text = [self.entryName objectAtIndex:row];
        [cell.contentView addSubview:cName];
        
        cImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 26, 26)];
        cImage.tag = kImageTag;
        cImage.alpha = kAlphaValue;
        if ([[self.entryImage objectAtIndex:row] isKindOfClass:[UIImage class]])
        {
            cImage.image = [self.entryImage objectAtIndex:row];
        }
        [cell.contentView addSubview:cImage];
        
        int numoflines = tHeight / 15;
        //cComment = [[UITextView alloc] initWithFrame:CGRectMake(80, 26, 210, tHeight)];
        cComment = [[UITextView alloc] initWithFrame:[self getCommentTextFrame:tHeight]];
        cComment.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        //cComment.lineBreakMode = UILineBreakModeWordWrap;
        //cComment.numberOfLines = tHeight / 15;
        cComment.tag = kCommentTag;
        //cComment.alpha = kAlphaValue;
        cComment.userInteractionEnabled = NO;
        cComment.backgroundColor = [UIColor clearColor];
        cComment.textAlignment = UITextAlignmentLeft;
        cComment.textColor = [self getTextColour];
        [cComment setContentToHTMLString:[self getCommentText:row]];
        [cell.contentView addSubview:cComment];
        
        cIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, tHeight + 30 + ((numoflines == 0) ? 11 : 11), 26, 26)];
        cIcon.tag = kIconTag;
        cIcon.alpha = kAlphaValue;
        cIcon.hidden = YES;
        cIcon.image = [self getSendLogo];
        [cell.contentView addSubview:cIcon];
        
        cText = [[UITextField alloc] initWithFrame:CGRectMake(40, tHeight + 34 + ((numoflines == 0) ? 11 : 11), 213, 20)]; //(self.viewType == Twitter) ?  213 : 248, 20)];
        //cText = [[UITextView alloc] initWithFrame:CGRectMake(48, tHeight + 40 + ((cComment.numberOfLines == 1) ? 19 : 0), 242, 31)];
        cText.tag = kTextTag;
        //cText.alpha = kAlphaValue;
        cText.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
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
        cText.clearButtonMode = UITextFieldViewModeNever;
        cText.enablesReturnKeyAutomatically = YES;
        cText.textColor = [self getTextColour];
        if (self.viewType == Midas)
        {
            cText.textColor = [UIColor blackColor];
        }
        cText.text = (self.viewType == Twitter) ? [self getReplyPrefix:row] : @"";
        [cell.contentView addSubview:cText];
		
        //if (self.viewType == Twitter)
        {
            ctwitReply = [UIButton buttonWithType:UIButtonTypeCustom];
            ctwitReply.tag = kTwitReplyTag;
            cTwitter.alpha = kAlphaValue;
            ctwitReply.enabled = YES;
            ctwitReply.hidden = YES;
            ctwitReply.userInteractionEnabled = YES;
            [ctwitReply addTarget:self action:@selector(sendReply:) forControlEvents:UIControlEventTouchDown];
            [ctwitReply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [ctwitReply setBackgroundColor:[UIColor clearColor]];
            CGRect frame = CGRectMake(259, tHeight + 37 + ((numoflines == 0) ? 11 : 11), 36, 13);
            ctwitReply.frame = frame;            
            ctwitReply.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
            [ctwitReply setTitle:@"Tweet" forState:UIControlStateNormal];
            [ctwitReply setBackgroundImage:[UIImage imageNamed:@"Twitter-capsule.png"] forState:UIControlStateNormal];
            if (self.viewType == Facebook)
            {
                [ctwitReply setTitle:@"Send" forState:UIControlStateNormal];
                [ctwitReply setBackgroundImage:[UIImage imageNamed:@"Facebook-capsule.png"] forState:UIControlStateNormal];
            }
            if (self.viewType == Midas)
            {
                [ctwitReply setTitle:@"Send" forState:UIControlStateNormal];
                [ctwitReply setBackgroundImage:[UIImage imageNamed:@"Midas-capsule.png"] forState:UIControlStateNormal];
                [ctwitReply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            [cell.contentView addSubview:ctwitReply];
            
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
        }
        
        if (0 && self.viewType == Facebook)
        {
            cLike = [UIButton buttonWithType:UIButtonTypeCustom];
            cLike.tag = kLikeTag;
            //cLike.alpha = kAlphaValue;
            cLike.enabled = YES;
            cLike.userInteractionEnabled = YES;
            cLike.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
            [cLike addTarget:self action:@selector(doLike:) forControlEvents:UIControlEventTouchDown];
            [cLike setTitle:@"- Like" forState:UIControlStateNormal];
            [cLike setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            CGRect frame = [self getTimeTextFrame:tHeight];
            frame.origin.x += 200;
            frame.origin.y -= 14;
            frame.size.width = 50;
            frame.size.height = 50;
            cLike.frame = frame;            
            cLike.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [cell.contentView addSubview:cLike];
        }
        
        if (self.viewType == Twitter)
        {
#if 1
            cTwitter = [UIButton buttonWithType:UIButtonTypeCustom];
            cTwitter.tag = kTwitterTag;
            //cTwitter.alpha = kAlphaValue;
            cTwitter.enabled = YES;
            cTwitter.userInteractionEnabled = NO;
            [cTwitter addTarget:self action:@selector(doLaunchTwitter:) forControlEvents:UIControlEventTouchDown];
            [cTwitter setTitleColor:[UIColor colorWithRed:0.15 green:0.4 blue:0.85 alpha:1.0] forState:UIControlStateNormal];
            CGRect frame = cComment.frame;
            frame.origin.x += 9;
            frame.origin.y += frame.size.height - 9;
            frame.size.width = 250;
            frame.size.height = 30;
            cTwitter.frame = frame;            
            cTwitter.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            cTwitter.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
            NSString *tmpStr = [[NSString alloc] initWithFormat:@"%@", [self.entryTime objectAtIndex:row]];
            [cTwitter setTitle:tmpStr forState:UIControlStateNormal];
            [cell.contentView addSubview:cTwitter];
#endif
        }
        
        cDivide = [[UIImageView alloc] initWithFrame:CGRectMake(0, [self heightForRowAtIndexPath:[indexPath row]], 284, 1)];
        cDivide.tag = kDivideTag;
        cDivide.alpha = kAlphaValue;
        cDivide.image = [UIImage imageNamed:@"Line-T-1.png"];
        //[cell.contentView addSubview:cDivide];
		
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.alpha = 0;
        
        cell.backgroundView.frame = CGRectMake(0, 0, 300, 60);
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
#if 0
        cTime = (UILabel *)[cell.contentView viewWithTag:kTimeTag];
        cName = (UILabel *)[cell.contentView viewWithTag:kNameTag];
        cImage = (UIImageView *)[cell.contentView viewWithTag:kImageTag];
        cComment = (UITextView *)[cell.contentView viewWithTag:kCommentTag];
        cIcon = (UIImageView *)[cell.contentView viewWithTag:kIconTag];
        cText = (UITextField *)[cell.contentView viewWithTag:kTextTag];
        cRepliedIcon = (UIImageView *)[cell.contentView viewWithTag:kRepliedIconTag];
        cLike = (UIButton *)[cell.contentView viewWithTag:kLikeTag];
        cTwitter = (UIButton *)[cell.contentView viewWithTag:kTwitterTag];
#endif
    }
	
    if (self.replying && self.replyRow == row)
    {
        cIcon.hidden = NO;
        cText.hidden = NO;
        ctwitReply.hidden = NO;
    }
    else
    {
        cIcon.hidden = YES;
        cText.hidden = YES;
        ctwitReply.hidden = YES;
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

/*
 - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
 [cell setBackgroundColor:[UIColor clearColor]];
 //[cell setBackgroundColor:[self getCellBackColour]];
 //cell.alpha = kAlphaValue + 0.125;
 }
 */

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
        [self hideView:0.4];
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
            //if (self.viewType == Twitter)
            {
                [self addEntry:cText.text];
                cRepliedIcon.hidden = NO;
                [self.entryReplied replaceObjectAtIndex:self.replyRow withObject:@"YES"];
            }
            [self hideReplying];
            ret = YES;
            [self hideView:0.4];
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
        //if ([cText.text length] > 0)
        {
            if (self.viewType == Twitter)
            {
                [self addEntry:cText.text];
                cRepliedIcon.hidden = NO;
                [self.entryReplied replaceObjectAtIndex:self.replyRow withObject:@"YES"];
            }
            [self hideView:0.4];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
        }
    }
    return NO;
}

////////////////////////////////////////////////////////////////////
// MidasSocialmediaResponderSource Methods

#ifdef INTEGRATED_IN_MIDAS

- (void)resetMessageCount
{
    [self.entryTime removeAllObjects];
    [self.entryName removeAllObjects];
    [self.entryImage removeAllObjects];
    [self.entryComment removeAllObjects];
    [self.entryUserId removeAllObjects];
    [self.entryReplied removeAllObjects];                                  
	[self.socialTable reloadData];
	lastEntryCount = 0;
}

- (bool)queueNewMessages:(NSMutableArray *)messageQueue AtTime:(float)updateTime
{
	int startOfSearch = lastEntryCount;
	
	if (updateTime >= 0.0 && self.replying == NO)
	{        
		if(startOfSearch < [self.entryTimings count])
		{
			for (int i = startOfSearch; i < [self.entryTimings count]; i++)
			{
				float messageTime = [[self.entryTimings objectAtIndex:i] floatValue];
				if (updateTime >= messageTime)
				{
					[self insertDummyEntry:i];
					[self.socialTable reloadData];
					[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
					
					NSString * messageSender = (NSString *)[self.entryUserId objectAtIndex:i];
					int messageType = (self.viewType == Twitter) ? MIDAS_SM_TWITTER_ : (self.viewType == Facebook) ? MIDAS_SM_FACEBOOK_ : MIDAS_SM_MIDAS_CHAT_;
					MidasSocialmediaMessage * newMessage = [[MidasSocialmediaMessage alloc] initWithSender:messageSender Type:messageType Time:messageTime ID:lastEntryCount];
					[messageQueue addObject:newMessage];
					[newMessage release];
					
					lastEntryCount++;
				}
				else 
				{
					break;
				}

			}
		}
	}
	
	return (lastEntryCount > startOfSearch);
}
#endif

@end

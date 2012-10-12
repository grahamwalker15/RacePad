//
//  MidasHelpTableViewCell.h
//  MidasDemo
//
//  Created by Daniel Tull on 07/09/2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import <DCTTableViewDataSources/DCTTableViewDataSources.h>

@interface MidasHelpTableViewCell : DCTTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *helpImageView;
@property (weak, nonatomic) IBOutlet UITextView *helpTextView;
@property (weak, nonatomic) IBOutlet UILabel *helpTitleLabel;
@end

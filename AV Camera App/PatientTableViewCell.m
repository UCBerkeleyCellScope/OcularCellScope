//
//  PatientTableViewCell.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/7/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "PatientTableViewCell.h"

@implementation PatientTableViewCell

@synthesize eyeThumbnail = _eyeThumbnail;
@synthesize idLabel = _idLabel;
@synthesize nameLabel = _nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _eyeThumbnail.layer.cornerRadius = _eyeThumbnail.frame.size.width / 2;
        _eyeThumbnail.clipsToBounds = YES;
        _eyeThumbnail.layer.borderWidth = 2.0f;
        _eyeThumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

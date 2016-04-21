//
//  SettingCell.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/24.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "SettingCell.h"

#define margin 14

@implementation SettingCell


- (void)setLayout{
    
    self.leftImageView.sd_layout.
    widthIs(16).heightIs(16).
    leftSpaceToView(self.contentView, 20).
    topSpaceToView(self.contentView, margin).
    bottomSpaceToView(self.contentView, margin);
    
    self.contentLabel.sd_layout.
    leftSpaceToView(self.leftImageView,10).
    topSpaceToView(self.contentView, margin).
    bottomSpaceToView(self.contentView, margin);
    
    self.rightImageView.sd_layout.
    widthIs(16).heightIs(16).
    rightSpaceToView(self.contentView, 20).
    topSpaceToView(self.contentView, margin).
    bottomSpaceToView(self.contentView, margin);
    
}

- (void)awakeFromNib {
    // Initialization code
    [self setLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

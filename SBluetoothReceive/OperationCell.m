//
//  OperationCell.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/18.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "OperationCell.h"

@implementation OperationCell

- (void)awakeFromNib {
    // Initialization code
    //[self setLayout];
}

- (void)setLayout{
    _fileName.sd_layout.
    topSpaceToView(self.contentView, 10).
    leftSpaceToView(self.contentView, 10).
    rightSpaceToView(_sendBtn, 10);
    
    _fileDate.sd_layout.
    topSpaceToView(_fileName, 10).
    leftSpaceToView(self.contentView, 10).
    rightSpaceToView(_sendBtn, 10);
    
    _sendBtn.sd_layout
    .rightSpaceToView(self.contentView, 10)
    .topSpaceToView(self.contentView, 10)
    .widthIs(40);
    
    [self setupAutoHeightWithBottomView:_fileDate bottomMargin:10];
}

-(void)setData:(NSString *)data{
    NSArray *array = [data componentsSeparatedByString:@"|:|"];
    if (array != nil && array.count > 0) {
        self.fileName.text = array[0];
        self.fileDate.text = array[1];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

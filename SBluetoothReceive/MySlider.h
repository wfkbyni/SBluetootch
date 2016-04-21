//
//  MySlider.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/2/2.
//  Copyright © 2016年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^StartSendSliderDrawData)(NSString *drawData);

@interface MySlider : UISlider

@property (nonatomic, strong) NSString *changeValue;

@property (nonatomic, copy) StartSendSliderDrawData startSendSliderDrawData;

- (void)startSendSliderDrawData:(StartSendSliderDrawData)startSendSliderDrawData;



@end

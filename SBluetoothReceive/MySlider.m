//
//  MySlider.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/2/2.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "MySlider.h"

@implementation MySlider

-(instancetype)init{
    [self getChangeValue];
    if (self == [super initWithFrame:CGRectMake(62, 85, 196, 30)]) {
        self.transform =  CGAffineTransformMakeRotation( M_PI * -0.5 );
        self.minimumValue = 0;
        self.maximumValue = 51200;
        [[self rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISlider *slider) {
            
            int intValue = slider.value;
            
            float afterValue = [[[NSUserDefaults standardUserDefaults] valueForKey:@"cache_value2"] floatValue];
            float value = afterValue / 1000;
            [NSThread sleepForTimeInterval:value];
            
            NSString *str = @"D00000";
            if (intValue < 10) {
                str = [NSString stringWithFormat:@"D0000%d",intValue];
            }else if(intValue < 100){
                str = [NSString stringWithFormat:@"D000%d",intValue];
            }else if(intValue < 1000){
                str = [NSString stringWithFormat:@"D00%d",intValue];
            }else if(intValue < 10000){
                str = [NSString stringWithFormat:@"D0%d",intValue];
            }else{
                str = [NSString stringWithFormat:@"D%d",intValue];
            }
            
            _changeValue = str;
            
        }];
    }
    return self;
}

/**
 *  @brief 每隔50毫秒取一个值
 */
- (void)getChangeValue{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger time = [[[NSUserDefaults standardUserDefaults] valueForKey:@"cache_value1"] intValue];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            
            if (_changeValue != nil) {
                NSLog(@"changeValue %@",self.changeValue);
                
                if (_startSendSliderDrawData != nil) {
                    _startSendSliderDrawData(_changeValue);
                }
                
                _changeValue = nil;
                
            }
            
            [self getChangeValue];
            
        });
        
    });
}

-(void)startSendSliderDrawData:(StartSendSliderDrawData)startSendSliderDrawData{
    _startSendSliderDrawData = startSendSliderDrawData;
}

@end

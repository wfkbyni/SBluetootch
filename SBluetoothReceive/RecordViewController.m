//
//  RecordViewController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/7/21.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "RecordViewController.h"

@interface RecordViewController (){
    UIImageView *bgImageView;
    UIImageView *imageView;
    NSInteger time;
}

@end

#define mArray @[@"20", @"50", @"100", @"200" ,@"1000" ,@"2000"]


@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    time = 20;
    [self setNavTitle];



    bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:bgImageView];

    UIImage *image = [UIImage imageNamed:@"1"];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - width) / 2,
                                                                          (CGRectGetHeight(self.view.frame) - height) / 2 , width, height)];
    [bgImageView addSubview:imageView];
    bgImageView.userInteractionEnabled = YES;

    for (NSInteger i = 0;  i < mArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 64 + 50 * i, 80, 40);
        [button setTitle:mArray[i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor greenColor];
        [bgImageView addSubview:button];

        button.tag = i;

        [button addTarget:self action:@selector(selectTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [self methodExec];
    });
}

- (void)setNavTitle{
    self.title = [NSString stringWithFormat:@"%@毫秒",@(time)];
}

- (void)selectTimeAction:(UIButton *)sender{
    time = [mArray[sender.tag] integerValue];
    [self setNavTitle];
}


- (void)methodExec{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        NSInteger value = arc4random_uniform(51200);

        value = value / 512;

        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",@(value)]];
        imageView.image = image;

        NSString *name;
        if (value < 25) {
            name = @"top_1";
        }else if(value < 50){
            name = @"top_2";
        }else if(value < 75){
            name = @"top_3";
        }else{
            name = @"top_4";
        }
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",name]];
        bgImageView.image = image;
        NSLog(@"%@",@(value));

        [self methodExec];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

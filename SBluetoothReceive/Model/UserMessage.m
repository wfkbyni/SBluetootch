//
//  UserMessage.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "UserMessage.h"

@implementation UserMessage

-(NSURL *)getUrlPicPath{
    
    NSURL *url = [NSURL URLWithString:[self getStrPicPath]];
    
    return url;
}

- (NSString *)getStrPicPath{
    NSString *headPath = [NSString stringWithFormat:@"http://%@%@", serverurl, self.Avatar];
    return headPath;
}

@end


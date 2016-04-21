//
//  NSStringExtension.h
//  Collector
//
//  Created by pactera on 15/4/21.
//  Copyright (c) 2015年 panderman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringExtension)
///将json key不标准的转换为标准key的json
+ (NSString *)changeNotStandardJsonKeyToStandardJsonString:(NSString *)json;
- (NSString*)md5;
- (BOOL)validateUrl:(NSString *)candidate;
- (NSString *)trim;
///移除所有空格
- (NSString *)trimAll;
///根据格式转化为日期类型
- (NSDate *)dateWithFormatString:(NSString *)formatString;

- (NSString *)mimeType;

- (NSString *)physicalPathMimeType;
///如果值为空则返回空值
+ (NSString *)isNilThenSetEmptyString:(NSString *)string;
///如果值为空则返回默认值
+ (NSString *)isNilThenSetDefaultString:(NSString *)string defaultString:(NSString *)defaultString;
///判断是否为空
+ (BOOL)isEmpty:(NSString *)string;
//defaultSize:默认尺寸，一般会根据宽度而不定高度，attributes:@{NSFontAttributeName:label.font}
- (CGSize)toSize:(CGSize)defaultSize attributes:(NSDictionary *)attributes;
///正则匹配
- (BOOL)isMatch:(NSString *)patten;

- (BOOL)isPhone;
///拨打电话
- (BOOL)phoneCall;
///不四舍五入的输出数字
+ (NSString *)notRounding:(float)price digitsPosition:(NSUInteger)digitsPosition;
///序列化JSON
- (id)JSON;
@end

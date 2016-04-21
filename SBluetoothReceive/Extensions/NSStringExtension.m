//
//  NSStringExtension.m
//  Collector
//
//  Created by pactera on 15/4/21.
//  Copyright (c) 2015年 panderman. All rights reserved.
//

#import "NSStringExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NSStringExtension)
+ (NSString *)changeNotStandardJsonKeyToStandardJsonString:(NSString *)json{
    // 将没有双引号的替换成有双引号的
//    NSString *validString = [json stringByReplacingOccurrencesOfString:@"(\\w+)\\s*:([^A-Za-z0-9_])" withString:@"\"$1\":$2" options:NSRegularExpressionSearch range:NSMakeRange(0, [json length])];
    
    //把'单引号改为双引号"
//    validString = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])'" withString:@"$1\"" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
//    validString = [validString stringByReplacingOccurrencesOfString:@"'([:\\],\\}])" withString:@"\"$1" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
    
    //再重复一次 将没有双引号的替换成有双引号的
//    validString = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])(\\w+)\\s*:" withString:@"$1\"$2\":" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
    NSString *validString = [json stringByReplacingOccurrencesOfString:@"\\{(\\w+)\\s*:" withString:@"{\"$1\":" options:NSRegularExpressionSearch range:NSMakeRange(0, [json length])];
    validString = [validString stringByReplacingOccurrencesOfString:@"\\,(\\w+)\\s*:" withString:@",\"$1\":" options:NSRegularExpressionSearch range:NSMakeRange(0, [validString length])];
    return validString;
}

- (NSString*)md5{
    const char * cStrValue = [self UTF8String];
    unsigned char theResult[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStrValue, (CC_LONG)strlen(cStrValue), theResult);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            theResult[0], theResult[1], theResult[2], theResult[3],
            theResult[4], theResult[5], theResult[6], theResult[7],
            theResult[8], theResult[9], theResult[10], theResult[11],
            theResult[12], theResult[13], theResult[14], theResult[15]];
}

- (BOOL)validateUrl:(NSString *)candidate {
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (NSString *)trim{
    NSString *cleanString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return cleanString;
}

- (NSString *)trimAll{
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    return [filteredArray componentsJoinedByString:@""];
}

- (NSDate *)dateWithFormatString:(NSString *)formatString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formatString;
    return [formatter dateFromString:self];
}

- (BOOL)containsString:(NSString *)aString{
    NSRange range = [self rangeOfString:aString];
    return range.length != 0;
}

- (NSString *)mimeType{
    NSString *fileExtension = [self pathExtension];
    if (!fileExtension) {
        return @"";
    }
    fileExtension = [fileExtension lowercaseString];
    if ([fileExtension isEqualToString:@"jpg"] || [fileExtension isEqualToString:@"jpeg"]) {
        return @"image/jpeg";
    }
    if ([fileExtension isEqualToString:@"png"]) {
        return @"image/png";
    }
    if ([fileExtension isEqualToString:@"gif"]) {
        return @"image/gif";
    }
    if ([fileExtension isEqualToString:@"bmp"]) {
        return @"image/bmp";
    }
    return @"";
}

- (NSString *)physicalPathMimeType{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
    CFStringRef resultType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!resultType) {
        return @"application/octet-stream";
    }
    NSString *result = (__bridge NSString *)resultType;
    return result;
}

+ (NSString *)isNilThenSetEmptyString:(NSString *)string{
    return [self isNilThenSetDefaultString:string defaultString:@""];
}

+ (NSString *)isNilThenSetDefaultString:(NSString *)string defaultString:(NSString *)defaultString{
    if([NSString isEmpty:string]){
        return defaultString;
    }
    return string;
}

+ (BOOL)isEmpty:(NSString *)string {
    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return YES;
    }
    
    return NO;
}
//defaultSize:默认尺寸，一般会根据宽度而不定高度，attributes:@{NSFontAttributeName:label.font}
- (CGSize)toSize:(CGSize)defaultSize attributes:(NSDictionary *)attributes{
    if (!self) {
        return CGSizeMake(0, 0);
    }
    return [self boundingRectWithSize:defaultSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}

- (BOOL)isMatch:(NSString *)patten{
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patten options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    if (match) {
        return YES;
    }
    return NO;
}

- (BOOL)isPhone{
    return self && [self isMatch:@"^(1(([35][0-9])|(47)|[8][0123456789]))\\d{8}$"];
}

- (BOOL)phoneCall{
    if (![self isPhone]) {
        return NO;
    }
    NSString *phoneNumber = [@"tel://" stringByAppendingString:self];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    return YES;
}

+ (NSString *)notRounding:(float)price digitsPosition:(NSUInteger)digitsPosition{
    NSString *priceStr = [NSString stringWithFormat:@"%f",price];
    NSRange r = [priceStr rangeOfString:@"."];
    if (r.length) {
        r.location += digitsPosition + 1;
        r.length = r.location;
        r.location = 0;
        priceStr = [priceStr substringWithRange:r];
    }else{
        priceStr = [NSString stringWithFormat:@"%lu",(unsigned long)price];
    }
    return priceStr;
    //    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //    formatter.roundingMode = NSNumberFormatterRoundDown;
    //    formatter.maximumFractionDigits = digitsPosition;
    //    return [formatter stringFromNumber:[NSNumber numberWithFloat:price]];
    
}

- (id)JSON{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        DebugLog(@"json反序列化失败：%@",error);
    }
    return json;
}

@end

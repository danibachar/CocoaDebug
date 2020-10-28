//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_OCLogModel.h"
#import "_OCLoggerFormat.h"
#import "_NetworkHelper.h"

@implementation _OCLogModel

- (instancetype)initWithContent:(NSString *)content
                          color:(UIColor *)color
                       fileInfo:(NSString *)fileInfo
                          isTag:(BOOL)isTag
                           type:(CocoaDebugToolType)type
{
    if (self = [super init]) {
        
        if ([fileInfo isEqualToString:@"XXX|XXX|1"]) {
            if (type == CocoaDebugToolTypeProtobuf) {
                fileInfo = @"Protobuf\n";
            } else {
                fileInfo = @"\n";
            }
        }
        
        //
        if (type == CocoaDebugToolTypeNone) {
            if ([fileInfo isEqualToString:@" \n"]) {//nslog
                fileInfo = @"NSLog\n";
            } else if ([fileInfo isEqualToString:@"\n"]) {//color
                fileInfo = @"Color\n";
            }
        }
        
        //RN (java script)
        if ([fileInfo isEqualToString:@"[RCTLogError]\n"]) {
            fileInfo = @"[error]\n";
        } else if ([fileInfo isEqualToString:@"[RCTLogInfo]\n"]) {
            fileInfo = @"[log]\n";
        }
        
        //
        self.Id = [[NSUUID UUID] UUIDString];
        self.fileInfo = fileInfo;
        self.date = [NSDate date];
        self.color = color;
        self.isTag = isTag;
        
        if ([content isKindOfClass:[NSString class]]) {
            self.contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        //避免日志数量过多导致卡顿
        if (content.length > 1000) {
            content = [content substringToIndex:1000];
        }
        self.content = content;
        
        /////////////////////////////////////////////////////////////////////////
        
        NSInteger startIndex = 0;
        NSInteger lenghtDate = 0;
        NSString *stringContent = @"";
        
        stringContent = [stringContent stringByAppendingFormat:@"[%@]", [_OCLoggerFormat formatDate:self.date]];
        lenghtDate = [stringContent length];
        startIndex = [stringContent length];
        
        if (self.fileInfo) {
            stringContent = [stringContent stringByAppendingFormat:@"%@%@", self.fileInfo, self.content];
        } else {
            stringContent = [stringContent stringByAppendingFormat:@"%@", self.content];
        }
        
        NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:stringContent];
        [attstr addAttribute:NSForegroundColorAttributeName value:self.color range:NSMakeRange(0, [stringContent length])];
        
        NSRange range = NSMakeRange(0, lenghtDate);
        [attstr addAttribute:NSForegroundColorAttributeName value: [[_NetworkHelper shared] mainColor] range: range];
        [attstr addAttribute:NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range: range];
        
        NSRange range2 = NSMakeRange(startIndex, self.fileInfo.length);
        
        if ([self.fileInfo isEqualToString:@"[error]\n"]) {
            [attstr addAttribute: NSForegroundColorAttributeName value: [UIColor systemRedColor]  range: range2];
        } else {
            [attstr addAttribute: NSForegroundColorAttributeName value: [UIColor systemGrayColor]  range: range2];
        }
        
        [attstr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range: range2];
        
        
        //换行
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        
        NSRange rang3 = NSMakeRange(0, attstr.length);
        [attstr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:rang3];
        
        
        //
        self.str = stringContent;
        self.attr = [[_OCLogModel attributedStringFrom:fileInfo content:content date:self.date color:color ] copy];
    }
    
    return self;
}

+ (NSAttributedString*)attributedStringFrom:(NSString *)fileInfo
                                    content:(NSString *)content
                                       date:(NSDate *)date
                                      color:(UIColor *)color
{
    NSInteger startIndex = 0;
    NSInteger lenghtDate = 0;
    NSString *stringContent = @"";
    
    stringContent = [stringContent stringByAppendingFormat:@"[%@]", [_OCLoggerFormat formatDate:date]];
    lenghtDate = [stringContent length];
    startIndex = [stringContent length];
    
    if (fileInfo) {
        stringContent = [stringContent stringByAppendingFormat:@"%@%@", fileInfo, content];
    } else {
        stringContent = [stringContent stringByAppendingFormat:@"%@", content];
    }

    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:stringContent];
    [attstr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [stringContent length])];
    
    NSRange range = NSMakeRange(0, lenghtDate);
    [attstr addAttribute:NSForegroundColorAttributeName value: [[_NetworkHelper shared] mainColor] range: range];
    [attstr addAttribute:NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range: range];
    
    NSRange range2 = NSMakeRange(startIndex, fileInfo.length);
    [attstr addAttribute: NSForegroundColorAttributeName value: [UIColor grayColor]  range: range2];
    [attstr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range: range2];
    
    
    //换行
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSRange rang3 = NSMakeRange(0, attstr.length);
    [attstr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:rang3];
    return attstr;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        self.Id = [decoder decodeObjectForKey:@"Id"];
        self.fileInfo = [decoder decodeObjectForKey:@"fileInfo"];
        self.content = [decoder decodeObjectForKey:@"content"];
        self.isTag = [decoder decodeBoolForKey:@"isTag"];
        self.str = [decoder decodeObjectForKey:@"str"];
        
        
        NSData *dateData = [decoder decodeObjectForKey:@"date"];
        self.date = [NSKeyedUnarchiver unarchiveObjectWithData: dateData];
        
        NSData *colorData = [decoder decodeObjectForKey:@"color"];
        self.color = [NSKeyedUnarchiver unarchiveObjectWithData: colorData];
        self.attr = [[_OCLogModel attributedStringFrom:self.fileInfo content:self.content date:self.date color:self.color ] copy];
        
        NSInteger type = [decoder decodeIntForKey:@"h5LogType"];
        switch (type) {
        case 1:
                self.h5LogType = H5LogTypeNotNone;
        default:
                self.h5LogType = H5LogTypeNone;
        }
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.Id forKey:@"Id"];
    [encoder encodeObject:self.fileInfo forKey:@"fileInfo"];
    [encoder encodeObject:self.content forKey:@"content"];
    [encoder encodeBool:self.isTag forKey:@"isTag"];
    [encoder encodeObject:self.str forKey:@"str"];
    [encoder encodeInt:self.h5LogType forKey:@"h5LogType"];
    
    NSDate *dateData = [NSKeyedArchiver archivedDataWithRootObject:self.date];
    [encoder encodeObject:dateData forKey:@"date"];
    
    NSDate *colorDaa = [NSKeyedArchiver archivedDataWithRootObject:self.color];
    [encoder encodeObject:colorDaa forKey:@"color"];
}

@end

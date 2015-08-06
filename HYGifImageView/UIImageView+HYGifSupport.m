//
//  UIImageView+HYGifSupport.m
//  UserFulResourceCollect
//
//  Created by yanghaha on 15/7/8.
//  Copyright (c) 2015年 yanghaha. All rights reserved.
//

#import "UIImageView+HYGifSupport.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>

@interface UIImageView () {
    NSInteger _gifTotalTime;
}

@end


@implementation UIImageView (HYGifSupport)

#pragma mark - SET && GET

static const char *kDelayTimeList = "kDelayTimeList";
-(NSMutableArray *)delayTimeList {
    NSMutableArray *array = objc_getAssociatedObject(self, kDelayTimeList);

    if (!array) {
        array = [NSMutableArray array];
        objc_setAssociatedObject(self, kDelayTimeList, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return array;
}

-(void)setDelayTimeList:(NSMutableArray *)delayTimeList {
    objc_setAssociatedObject(self, kDelayTimeList, delayTimeList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static const char *kGifTotalTime = "kGifTotalTime";
-(CGFloat)gifTotalTime {

    CGFloat gifTotalTime = [objc_getAssociatedObject(self, kGifTotalTime) integerValue];

    if (!gifTotalTime) {
        for (NSNumber *number in self.delayTimeList) {
            gifTotalTime += number.floatValue;
        }
        objc_setAssociatedObject(self, kGifTotalTime, [@(gifTotalTime) description], OBJC_ASSOCIATION_ASSIGN);
    }

    return gifTotalTime;
}

-(void)setGifTotalTime:(CGFloat)gifTotalTime {
    objc_setAssociatedObject(self, kGifTotalTime, [@(gifTotalTime) description], OBJC_ASSOCIATION_ASSIGN);
}

- (void)handleGifData:(NSData *)gifData pageCount:(NSUInteger)pageCount {

    //当未传入pageCount时，默认的帧数
#define kGifPageCount 20

    pageCount = pageCount>0? pageCount:kGifPageCount;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:pageCount];

    if (self.delayTimeList) {
        self.delayTimeList = nil;
        self.animationDuration = 0;
        self.delayTimeList = [NSMutableArray arrayWithCapacity:pageCount];
    }



    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)gifData, NULL);
    if (src) {
        NSUInteger frameCount = CGImageSourceGetCount(src);

        NSDictionary *gifProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(src, NULL);


        if (gifProperties) {
            //            NSDictionary *gifDictionary = [gifProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary]; //
            //            NSUInteger loopCount = [[gifDictionary objectForKey:(NSString *)kCGImagePropertyGIFLoopCount] integerValue];        //循环次数

            for (NSUInteger i=0; i<frameCount; i++) {
                CGImageRef imgRef = CGImageSourceCreateImageAtIndex(src, (size_t)i, NULL);
                if (imgRef) {
                    UIImage *image = [UIImage imageWithCGImage:imgRef];
                    [array addObject:image];

                    NSDictionary *imgInfoDic = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(src, (size_t)i, NULL);

                    if (imgInfoDic) {
                        //从信息里获取延迟时间之类
                        NSDictionary *detailInfoDic = [imgInfoDic objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
                        CGFloat delayTime = [[detailInfoDic objectForKey:(NSString *)kCGImagePropertyGIFDelayTime] floatValue];        //每帧数延迟时间
                        self.animationDuration += delayTime;
                        [self.delayTimeList addObject:@(delayTime)];
                    }
                }
            }
        }
    }
    self.animationImages = array;
}

-(CGFloat)delayTimeImage:(UIImage *)image {

    NSNumber *number = self.delayTimeList[[self.animationImages indexOfObject:image]];

    return number.floatValue;
}

@end

//
//  UIImageView+HYGifSupport.h
//  UserFulResourceCollect
//
//  Created by yanghaha on 15/7/8.
//  Copyright (c) 2015年 yanghaha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (HYGifSupport)
/**
 *@brief  保存每一张图片的延迟时间
 *
 **/
@property (nonatomic, strong, readonly) NSMutableArray *delayTimeList;

/**
 *@brief gif图片， 动画周期
 **/
@property (nonatomic, assign) CGFloat gifTotalTime;
/**@brief 获取指定图片的延迟时间
 *
 *@param image 指定的图片
 **/
- (CGFloat)delayTimeImage:(UIImage *)image;

/**@brief 解析处理gif数据流，并将解析到的image数组设置为animationImages，
 *@param
 *@param gifData gif文件的二进制流
 *@param pageCount gif文件的帧数(当无法预测时，默认值为20)
 **/
- (void)handleGifData:(NSData *)gifData pageCount:(NSUInteger)pageCount;

@end

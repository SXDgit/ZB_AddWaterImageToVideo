//
//  ZRWaterPrintComposition.h
//  TakeVideos
//
//  Created by VictorZhang on 29/08/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//  添加水印

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZRWaterPrintComposition : NSObject

/**
 * 添加水印
 * @param originalURL 视频原始地址
 * @param waterprintImage 水印的logo图片
 * @param completionHandler 回调block
 */
- (void)addVideoWaterprintAtURL:(NSURL *)originalURL WithWaterprintImage:(UIImage *)waterprintImage completionHandler:(void(^)(int status, NSString *errorMsg, NSURL *finishedVideoURL))completionHandler;

@end

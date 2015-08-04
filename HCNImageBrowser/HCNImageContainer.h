//
//  HCNImageContainer.h
//  ZaiChengdu
//
//  Created by Nick Hu on 15/8/4.
//  Copyright (c) 2015年 DigitalChina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCNImageContainer;
@protocol HCNImageContainerDelegate <NSObject>
@required
- (void)HCNImageContainerDimiss:(HCNImageContainer *)container;

@end

@interface HCNImageContainer : UIView <UIScrollViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<HCNImageContainerDelegate> delegate;
- (void)setThumbImageURLString:(NSString *)url originImageURLString:(NSString *)url;
- (void)setImage:(UIImage *)image;
@end

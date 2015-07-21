//
//  HCNImageViewer.h
//
//
//  Created by Nick Hu on 14/12/12.
//  Copyright (c) 2014年 Sudiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kViewTagPhotoViewerView 9191919
@protocol HCNImageViewerDelegate <NSObject>
@optional
- (void)photoViewDidDisappear;
@end

@interface HCNImageViewer : UIView

@property (nonatomic,weak) id<HCNImageViewerDelegate> delegate;
@property (nonatomic,strong) NSArray *thumbImageUriArray;
@property (nonatomic,strong) NSArray *originalImageUriArray;
@property (nonatomic,assign) NSInteger currentIndex;
/**
 *  显示photoView，从view的位置开始动画显示
 *
 *  @param view 动画起点的view
 */
- (void)showWithFromView:(UIView *)view;
@end

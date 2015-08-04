//
//  HCNPhotoView.h
//
//
//  Created by Nick Hu on 14/12/12.
//  Copyright (c) 2014年 Sudiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kViewTagPhotoViewerView 9191919
@class HCNPhotoView;


@protocol HCNPhotoViewDelegate <NSObject>
@optional
/**
 *  用于找到显示动画的起始的rect，在隐藏时用户找到动画结束的rect
 *
 *  @param photoView 当前的photoView
 *  @param index 当前的显示image的idx
 *
 *  @return 进行过坐标系转换的起始view的rec
 */
- (UIView *)photoView:(HCNPhotoView*)photoView SourceViewWithIndex:(NSInteger)index;

- (void)photoViewDidDisappear;
@end


@protocol HCNPhotoViewDataSource <NSObject>

@optional
- (NSArray*)photoViewThumbImageData:(HCNPhotoView*)photoView;
- (NSArray*)photoViewOriginalImageData:(HCNPhotoView*)photoView;
@end

@interface HCNPhotoView : UIViewController

@property (nonatomic, weak) id<HCNPhotoViewDelegate> delegate;
@property (nonatomic, weak) id<HCNPhotoViewDataSource> dataSource;

@property (nonatomic, assign) NSInteger currentIndex;
/**
 *  显示photoView，从view的位置开始动画显示
 *
 */
- (void)show;
@end

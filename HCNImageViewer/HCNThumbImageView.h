//
//  MRImagePreviewer.h
//
//
//  Created by Nick Hu on 14/12/12.
//  Copyright (c) 2014年 Sudiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCNImageViewer.h"
@class HCNThumbImageView;
@protocol HCNThumbImageViewDelegate <NSObject>

@required
- (void)imagePreviewerWillShowPhotoView:(HCNThumbImageView *)previewer;

@end

@interface HCNThumbImageView : UIImageView
@property (nonatomic, weak) id<HCNThumbImageViewDelegate> delegate;
@property (nonatomic, strong) NSString *thumbImageUri;
@property (nonatomic, strong) NSString *originImageUri;//default is thumbImageUri
@property (nonatomic, strong, readonly) HCNImageViewer *photoViewer;
- (void)showOriginalPhoto;
@end

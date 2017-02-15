//
//  ProgressView.h
//  SlideMusicPlayer
//
//  Created by wbq on 17/2/15.
//  Copyright © 2017年 汪炳权. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (nonatomic,assign)CGFloat progress;

- (void)drawProgress:(CGFloat)progressnow;

@end

//
//  SlideGestureRecognizer.m
//  SlideMusicPlayer
//
//  Created by wbq on 17/2/15.
//  Copyright © 2017年 汪炳权. All rights reserved.
//

#import "SlideGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@implementation SlideGestureRecognizer


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //手势开始时候
    if (self.state == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateBegan];
    }
    
    //判断是不是单手操作
    if ([event touchesForGestureRecognizer:self].count >1){
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.state == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateBegan];
    }else{
        [self setState:UIGestureRecognizerStateChanged];
    }
    
    UITouch *touch = [touches anyObject];
    
    UIView *view = [self view];
    //当前view的位置
    CGPoint center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    
    //获取当前手势位置
    CGPoint currentPoint = [touch locationInView:view];
    
    //获取之前手势位置
    CGPoint previousPoint = [touch previousLocationInView:view];
    //用tan反函数计算当前角度和手势作用之前角度
    CGFloat currentRotation = atan2f((currentPoint.y - center.y), (currentPoint.x - center.x));
    CGFloat previousRotation = atan2f((previousPoint.y - center.y), (previousPoint.x - center.x));
    //计算出手势前后旋转的角度
    self.rotation = currentRotation - previousRotation;
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.state == UIGestureRecognizerStateChanged) {
        
        //手势结束
        [self setState:UIGestureRecognizerStateEnded];
        
    }else {
        
        [self setState:UIGestureRecognizerStateFailed];
      
    }
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self setState:UIGestureRecognizerStateFailed];
}



@end

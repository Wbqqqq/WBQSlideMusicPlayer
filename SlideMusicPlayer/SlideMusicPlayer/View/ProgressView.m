//
//  ProgressView.m
//  SlideMusicPlayer
//
//  Created by wbq on 17/2/15.
//  Copyright © 2017年 汪炳权. All rights reserved.
//

#import "ProgressView.h"
#import "Define.h"


@implementation ProgressView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    
    CGPoint center = CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
    
    CGFloat radius = rect.size.width/2 - 5;
    
    CGFloat startA = - M_PI_2;  //圆起点位置

    CGFloat endA = _progress * M_PI * 2;
    
    if (endA>=2*M_PI){
        
        endA =2*M_PI;
        
    }else if (endA<=0){
        
        endA = 0;

    }
    
    CGFloat finall= endA +startA;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:finall clockwise:YES];
    
    CGContextSetLineWidth(ctx, 8*KWidth_Scale); //设置线条宽度
    
    [RGBACOLOR(235, 97, 0, 1) setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
}

//外部改变值的时候重绘
- (void)drawProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
}

@end

//
//  RulerScrollView.h
//  TestRulerDemo
//
//  Created by yjc on 14/03/2018.
//  Copyright © 2018 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RulerScrollView : UIScrollView


@property (nonatomic) float bottomMargin;
@property (nonatomic) float smallDegreeHeight;
@property (nonatomic) float largeDegreeHeight;

@property (nonatomic, strong) UIColor* degreeColor;

- (id)initWithFrame:(CGRect)frame;
- (void)jumpToDegree:(NSInteger)degree;

@end

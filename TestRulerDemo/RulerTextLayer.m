//
//  RulerTextLayer.m
//  TestRulerDemo
//
//  Created by yjc on 15/03/2018.
//  Copyright © 2018 test. All rights reserved.
//

#import "RulerTextLayer.h"
#import <UIKit/UIFont.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIScreen.h>

@implementation RulerTextLayer{
    NSString* layerId;
}

+ (RulerTextLayer*)getTextLayer{
    
    RulerTextLayer* layer = [[RulerTextLayer alloc] init];
    
    layer.foregroundColor = [UIColor grayColor].CGColor;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.wrapped = YES;
    
    UIFont* font = [UIFont systemFontOfSize:10];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    layer.font = fontRef;
    layer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    return layer;
}

+ (RulerTextLayer*)getTextLayerWithString:(NSString*)string rect:(CGRect)rect{
    
    RulerTextLayer* layer = [RulerTextLayer getTextLayer];
    
    layer.frame = rect;
    layer.string = string;
    
    return layer;
}

- (void)setString:(NSString*)string rect:(CGRect)rect{
    
    self.string = string;
    self.frame = rect;
}

- (void)setID:(NSString*)layerIdentifier{
    layerId = layerIdentifier;
}

- (NSString*)getID{
    return layerId;
}

@end

//
//  RulerTextLayer.h
//  TestRulerDemo
//
//  Created by yjc on 15/03/2018.
//  Copyright © 2018 test. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface RulerTextLayer : CATextLayer

@property (nonatomic, weak) CALayer* nextLayerPointer; // 指针

+ (RulerTextLayer*)getTextLayer;

+ (RulerTextLayer*)getTextLayerWithString:(NSString*)string rect:(CGRect)rect;

- (void)setString:(NSString*)string rect:(CGRect)rect;

- (void)setID:(NSString*)layerIdentifier;

- (NSString*)getID;

@end

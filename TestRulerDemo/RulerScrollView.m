//
//  RulerScrollView.m
//  TestRulerDemo
//
//  Created by yjc on 14/03/2018.
//  Copyright © 2018 test. All rights reserved.
//

#import "RulerScrollView.h"
#import "RulerTextLayer.h"

#define RULER_MAGIN 10
#define RULER_X_MARGIN (self.frame.size.width/2)

@interface RulerScrollView()

//中间的红线
@property (nonatomic, strong) UIView* midLine;

//链接指针
@property (nonatomic, weak) RulerTextLayer* frontRulerPotiner;
@property (nonatomic, weak) RulerTextLayer* behindRulerPotiner;

//缓存数组
@property (nonatomic, strong) NSMutableSet* setCache;

@end

@implementation RulerScrollView{
    
    NSInteger singleUnitDegree;
    CALayer* rulerLayer;
    
    NSInteger rulerFromDegree;
    NSInteger rulerToDegree;
    
    NSInteger drawFromDegree;
    NSInteger drawToDegree;
    
    BOOL draw; // 开关，默认为false,还没用到
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        [self setUpValueDefault];
        [self setUpUIDefault];
        
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

#pragma mark - Set Up Method

- (void)setUpValueDefault{
    
    singleUnitDegree = 1000; // 一个生成区域内有多少个

    rulerFromDegree = drawFromDegree = 0;
    rulerToDegree = drawToDegree = singleUnitDegree;
    
    self.bottomMargin = self.frame.size.height/2;
    self.smallDegreeHeight = 20.f;
    self.largeDegreeHeight = 40.f;
    self.degreeColor = [UIColor grayColor];
    
    self.setCache = [[NSMutableSet alloc] initWithCapacity:singleUnitDegree/10];
    
}

- (void)setUpUIDefault{
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setContentSize:CGSizeMake(singleUnitDegree * 10 + RULER_X_MARGIN, 0)];
    
    rulerLayer = [[CALayer alloc] initWithLayer:self.layer];
    [self.layer addSublayer:rulerLayer];
}


#pragma mark Opening Method

-  (void)jumpToDegree:(NSInteger)degree{
    
    if(degree >= 0){
        
        if(rulerFromDegree + 200 <= degree && rulerToDegree - 200 >= degree){ //所跳区域在绘制范围内(200以内不用重画)
            [self setContentOffset:CGPointMake(degree * RULER_MAGIN , 0)];
        }
        else if(rulerFromDegree - 200 < degree && rulerFromDegree + 200 > degree){
            [self setContentOffset:CGPointMake(degree * RULER_MAGIN , 0)];
            
        }
        else if(rulerToDegree - 200 < degree && rulerToDegree + 200 > degree){
            [self setContentSize:CGSizeMake((rulerToDegree + singleUnitDegree) * 10 + RULER_X_MARGIN, 0)];

            [self setContentOffset:CGPointMake(degree * RULER_MAGIN , 0)];
        }
        else{
            //清空重新画
            [self cleanAreaWithPointer:self.frontRulerPotiner];
            [self cleanAreaWithPointer:self.behindRulerPotiner];
            self.frontRulerPotiner = nil;
            self.behindRulerPotiner = nil;
            
            NSInteger floorValue = floorf((float)degree/(float)singleUnitDegree);
            NSInteger ceilValue = ceil((float)degree/(float)singleUnitDegree);
            
            NSInteger lowDegree = (floorValue == ceilValue)?(floorValue-1) * singleUnitDegree:floorValue * singleUnitDegree;
            if(lowDegree < 0)lowDegree = 0;
            NSInteger highDegree = lowDegree + singleUnitDegree;
            
            rulerFromDegree = drawFromDegree = lowDegree;
            rulerToDegree = drawToDegree = highDegree;
            
            [self drawRect:self.frame];
            [self setContentOffset:CGPointMake(degree * RULER_MAGIN , 0)];
            [self setContentSize:CGSizeMake(rulerToDegree * 10 + RULER_X_MARGIN, 0)];
        }

    }
    else{
        [self setContentOffset:CGPointMake(RULER_X_MARGIN, 0)];
    }
}

- (void)refreshRulerView{
    
    //清空链表上的layer
    [self cleanAreaWithPointer:self.frontRulerPotiner];
    [self cleanAreaWithPointer:self.behindRulerPotiner];

    self.frontRulerPotiner = nil;
    self.behindRulerPotiner = nil;
    
    rulerLayer.sublayers = nil;
    [rulerLayer removeFromSuperlayer];
    rulerLayer = [[CALayer alloc] initWithLayer:self.layer];
    [self.layer addSublayer:rulerLayer];
    //---
    [self jumpToDegree:0];
}


#pragma mark DrawRect

- (void)drawRect:(CGRect)rect{

    [self drawFromNum:drawFromDegree toDegree:drawToDegree];
}


#pragma mark - Custom Method
//画字
- (RulerTextLayer*)createStrWithString:(NSString*)num frame:(CGRect)rect{

    RulerTextLayer* layer = [self.setCache anyObject];
    RulerTextLayer* textLayer;
    
    if(layer == nil){
        
        textLayer = [RulerTextLayer getTextLayerWithString:num rect:rect];
    }
    else{
        textLayer = layer;
        textLayer.frame = rect;
        textLayer.string = num;
        [self.setCache removeObject:layer];
    }
    [rulerLayer addSublayer:textLayer];
    
    return textLayer;
}


- (void)drawFromNum:(NSInteger)num toDegree:(NSInteger)totalNum{
    
    float bottom = self.frame.size.height - self.bottomMargin;
    
    CGMutablePathRef degreeRef = CGPathCreateMutable();
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.strokeColor = self.degreeColor.CGColor;
    layer.fillColor = self.degreeColor.CGColor;
    layer.lineWidth = 1.f;
    layer.lineCap = kCALineCapButt;
    
    CGSize strSize = CGSizeMake(10 * RULER_MAGIN, 30);// 数字大小
    
    double fixOffSet = RULER_MAGIN*(num-0) + RULER_X_MARGIN;
    
    RulerTextLayer* tmpTextLayer;
    
    for(NSInteger i = num ; i < totalNum; i++){
        
        if(i % 10 == 0){
            
            NSString* number = [NSString stringWithFormat:@"%ld",i * 1]; // 画数字
            if(tmpTextLayer){
                
                RulerTextLayer* nextTextLayer = [self createStrWithString:number frame:CGRectMake(fixOffSet + RULER_MAGIN * (i-num) - strSize.width/2, bottom - self.largeDegreeHeight - 20, strSize.width, strSize.height)];
                tmpTextLayer.nextLayerPointer = nextTextLayer;
                
                tmpTextLayer = nextTextLayer;
            }
            else{
                
                tmpTextLayer = [self createStrWithString:number frame:CGRectMake(fixOffSet + RULER_MAGIN * (i-num) - strSize.width/2, bottom - self.largeDegreeHeight - 20, strSize.width, strSize.height)];
                
                if(!self.frontRulerPotiner){
                    self.frontRulerPotiner = tmpTextLayer;
                }
                else{
                    self.behindRulerPotiner = tmpTextLayer;
                }
            }
            
            CGPathMoveToPoint(degreeRef, NULL, fixOffSet+ RULER_MAGIN * (i-num), bottom);
            CGPathAddLineToPoint(degreeRef, NULL, fixOffSet + RULER_MAGIN * (i-num), bottom - self.largeDegreeHeight);
        }
        else{
            
            CGPathMoveToPoint(degreeRef, NULL, fixOffSet + RULER_MAGIN * (i-num), bottom);
            CGPathAddLineToPoint(degreeRef, NULL, fixOffSet + RULER_MAGIN * (i-num), bottom - self.smallDegreeHeight);
        }
        // 加上横线
        CGPathMoveToPoint(degreeRef, NULL, fixOffSet + RULER_MAGIN * (i-num), bottom);
        CGPathAddLineToPoint(degreeRef, NULL, fixOffSet + RULER_MAGIN * ((i-num)+1), bottom);
    }
    
    layer.path = degreeRef;
    [rulerLayer addSublayer:layer];
    CGPathRelease(degreeRef);
    tmpTextLayer.nextLayerPointer = layer; // 最后连着一个CAShaperLayer
    //链表格式： （RulerTextLayer）-》（RulerTextLayer）-》（RulerTextLayer）-》（CAShapeLayer）
}

- (void)cleanAreaWithPointer:(RulerTextLayer*)layer{
    
    while(layer.nextLayerPointer){
        
        if([layer.nextLayerPointer isKindOfClass:[RulerTextLayer class]]){
            
            RulerTextLayer* nextLayer = (RulerTextLayer*)layer.nextLayerPointer;
            
            if(self.setCache.count < singleUnitDegree/10)
                [self.setCache addObject:layer];
            
            [layer removeFromSuperlayer];
            layer = nextLayer;
        }
        else if([layer.nextLayerPointer isKindOfClass:[CAShapeLayer class]]){
            CAShapeLayer* lastLayer = (CAShapeLayer*)layer.nextLayerPointer;
            [layer removeFromSuperlayer];
            [lastLayer removeFromSuperlayer];
            break;
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"contentOffset"]){
        if(self.contentOffset.x > (rulerToDegree - 200) * RULER_MAGIN + RULER_X_MARGIN){ // 到了后面200的区域
            
            if(rulerToDegree - rulerFromDegree <= singleUnitDegree){ //只有一个singleUnitDegree的绘画[只有 0 - 1000 ]
                drawFromDegree += singleUnitDegree;
                drawToDegree += singleUnitDegree;
                rulerToDegree += singleUnitDegree;
                
            }
            else {
                //通常情况
                drawFromDegree = rulerToDegree;
                drawToDegree = rulerToDegree + singleUnitDegree;
                rulerFromDegree += singleUnitDegree;
                rulerToDegree += singleUnitDegree;
                
                RulerTextLayer* needCleanLayer = self.frontRulerPotiner;
                self.frontRulerPotiner = self.behindRulerPotiner; // 让下个渲染的时候，链表用在behindRulerPotiner上
                self.behindRulerPotiner = nil;
                [self cleanAreaWithPointer:needCleanLayer]; //清掉前面1000的区域
            }
            
            [self setNeedsDisplay];
            [self setContentSize:CGSizeMake(rulerToDegree * 10 + RULER_X_MARGIN, 0)];
        }
        else if(self.contentOffset.x < (rulerFromDegree + 200) * RULER_MAGIN + RULER_X_MARGIN){ //到了前面200的区域
            if(rulerFromDegree == 0){
                return;
            }
            
            drawFromDegree = rulerFromDegree - singleUnitDegree;
            drawToDegree = rulerFromDegree;
            rulerToDegree -= singleUnitDegree;
            rulerFromDegree -= singleUnitDegree;
            
            if(rulerToDegree - rulerFromDegree <= singleUnitDegree){ //只有一个singleUnitDegree的绘画[跳到某个区域的时候，可能会出现只绘制了一个区域]
                self.behindRulerPotiner = self.frontRulerPotiner; // 让下个渲染的时候，链表用在behindRulerPotiner上
                self.frontRulerPotiner = nil;
                
            }
            else{
                //这个因为behind链表有layer，这个layer是最后面那个区域的，所以要清除掉
                RulerTextLayer* needCleanLayer = self.behindRulerPotiner;
                self.behindRulerPotiner = self.frontRulerPotiner; // 让下个渲染的时候，链表用在behindRulerPotiner上
                self.frontRulerPotiner = nil;
                
                [self cleanAreaWithPointer:needCleanLayer]; //清掉后面1000的区域
            }
            
            [self setNeedsDisplay];
        }
    }
}

#pragma mark - Getter & Setter

- (UIView*)midLine{
    
    if(!_midLine){
        
        _midLine = [[UIView alloc] init];
        [_midLine setBackgroundColor:[UIColor colorWithRed:248.f/255.f green:57.f/255.f blue:66.f/255.f alpha:0.5]];
    }
    return _midLine;
}

#pragma mark - Dealloc

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

@end

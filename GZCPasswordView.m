//
//  GZCPasswordView.m
//  GZCPasswordWindow
//
//  Created by ZhongCheng Guo on 2017/1/4.
//  Copyright © 2017年 ZhongCheng Guo. All rights reserved.
//

#import "GZCPasswordView.h"

@interface GZCPasswordView() <UIKeyInput>

@property (strong, nonatomic) CADisplayLink *displaylink;
@property (assign, nonatomic) CFTimeInterval beginTime;
@property (assign, nonatomic) CFTimeInterval endTime;

@end

@implementation GZCPasswordView{
    NSMutableArray <NSNumber *>* dotAlphas;
    NSMutableArray <NSNumber *>* dotScans;
}

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    [self commonInit];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    [self commonInit];
    [self setText:self.text];
    
    return self;
}

- (void)commonInit
{
    // Defaults
    self.showDuration = 0.2;
    self.dotColor  = [UIColor grayColor];
    self.dotRadius = 10;
    self.borderWidth = 1;
    self.borderColor = [UIColor lightGrayColor];
    self.boxRadius = 5;
    self.boxCount = 6;
    self.boxMargin = 3;
    self.text = @"";
    self.editable = YES;
    self.textColor = [UIColor darkGrayColor];
    self.fontSize = 17;
    self.font = [UIFont systemFontOfSize:17];
    self.secureTextEntry = YES;
}

#pragma mark - overwrite

// 点击时，获取焦点
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self becomeFirstResponder];
}

// 返回值决定了是否可以获得焦点
-(BOOL)canBecomeFirstResponder{
    return self.editable;
}

// 获得焦点的方法
- (BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    if (result ==  YES) {
        [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
    }
    return result;
}

// 返回值决定是否可以注销焦点
- (BOOL)canResignFirstResponder {
    return YES;
}

// 注销焦点
- (BOOL)resignFirstResponder {
    BOOL result = [super resignFirstResponder];
    [self startTextChangeAnimation];
    
    if (result) {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
    
    return result;
}

#pragma mark - UIKeyInput Protocal
//返回弹出键盘的类型（这里指定只能弹出数字键盘）
- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

//返回是否已经有内容
- (BOOL)hasText {
    return _text != nil && _text.length > 0;
}

//键盘的内容输入时会调用
- (void)insertText:(NSString *)text {
    if (_text.length >= self.boxCount) {
        [self textDidFull];
        return;
    }
    
    if ([text isEqualToString:@" "]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(passwordView:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.delegate passwordView:self shouldChangeCharactersInRange:NSMakeRange(_text.length - 1, 1) replacementString:text] == NO) {
            return;
        }
    }
    
    NSMutableString *str = [NSMutableString stringWithString:_text];
    [str appendString:text];
    _text = str;
    
    if (_text.length >= _boxCount) {
        [str deleteCharactersInRange:NSMakeRange(_boxCount, str.length - _boxCount)];
        if ([self.delegate respondsToSelector:@selector(passwordViewDidChangedText:)]) {
            [self.delegate passwordViewDidChangedText:self];
        }
        [self textDidFull];
    } else {
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
        if ([self.delegate respondsToSelector:@selector(passwordViewDidChangedText:)]) {
            [self.delegate passwordViewDidChangedText:self];
        }
    }
    [self startTextChangeAnimation];
}

- (void)textDidFull{
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    BOOL shouldResign = NO;
    if ([self.delegate respondsToSelector:@selector(passwordViewDidFullText:)]) {
        shouldResign = [self.delegate passwordViewDidFullText:self];
    }
    if (shouldResign == YES) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self resignFirstResponder];
        }];
    }

}

//删除键按下时会调用
- (void)deleteBackward {
    if ([self hasText] == NO)
        return;
    NSMutableString *str = [NSMutableString stringWithString:self.text];
    if (str.length) {
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    }
    self.text = str;
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    [self startTextChangeAnimation];
}

#pragma mark - getter

-(NSMutableArray *)dotAlphas{
    if (dotAlphas == nil) {
        dotAlphas = [NSMutableArray arrayWithCapacity:self.boxCount];
        for (int i = 0; i < self.boxCount; i ++) {
            dotAlphas[i] = @0;
        }
    }
    return dotAlphas;
}

-(NSMutableArray *)dotScans{
    if (dotScans == nil) {
        dotScans = [NSMutableArray arrayWithCapacity:self.boxCount];
        for (int i = 0; i < self.boxCount; i ++) {
            dotScans[i] = @0;
        }
    }
    return dotScans;
}

-(CADisplayLink *)displayLink{
    if (_displaylink == nil) {
        _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateString)];
        _displaylink.paused = YES;
        [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displaylink;
}

#pragma mark - target
- (void)textChange:(UITextField *)textField {
    [self startTextChangeAnimation];
}


#pragma mark - 设置参数
-(void)setText:(NSString *)text{
    if (text.length <= self.boxCount) {
//        [super setText:text];
        _text = text;
        [self startTextChangeAnimation];
        if ([self.delegate respondsToSelector:@selector(passwordViewDidChangedText:)]) {
            [self.delegate passwordViewDidChangedText:self];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(passwordViewDidFullText:)]) {
            [self.delegate passwordViewDidFullText:self];
        }
    }
}

-(void)setBoxCount:(NSInteger)boxCount{
    if (boxCount<1) {
//        NSCAssert(boxCount>0,@"输入位数不可以小于1哦");
        boxCount = 1;
    }else if(boxCount>9){
//        NSCAssert(boxCount<=9,@"输入位数不可以超过9位哦");
        boxCount = 9;
    }
    _boxCount = boxCount;
}

-(void)setDotRadius:(CGFloat)dotRadius{
    float max = [self getMinBoxSide];
    if (dotRadius > max) {
        dotRadius = max;
    }
    _dotRadius = dotRadius;
}

-(void)setBoxRadius:(CGFloat)boxRadius{
    float max = [self getMinBoxSide]/2;
    if (boxRadius > max) {
        boxRadius = max;
    }
    _boxRadius = boxRadius;
}

-(void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    self.font = [UIFont systemFontOfSize:fontSize];
}

#pragma mark - 绘图
-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //调整位置，因为边框如果超出rect会被截取
    CGRect bounds = CGRectInset(rect, _borderWidth * 0.5, _borderWidth * 0.5);
    [self drawBorder:context rect:bounds];
    if (_secureTextEntry) {
        [self drawDot:context rect:bounds];
    }else{
        [self drawString:context rect:bounds];
    }
}

/**
 * 绘制方框
 * context   上下文
 * rect
 **/
-(void)drawBorder:(CGContextRef)context
             rect:(CGRect)rect{
    //设置线的颜色
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    //设置线的宽度
    CGContextSetLineWidth(context, self.borderWidth);
    if (self.boxMargin < 2) {
        //绘制外边框
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_boxRadius];
        CGContextAddPath(context, bezierPath.CGPath);
        
        //绘制分割线
        float boxWidth = CGRectGetWidth(rect) / self.boxCount;
        float boxHeight = CGRectGetHeight(rect);
        for (int i = 1; i < _boxCount ; ++i) {
            CGContextMoveToPoint(context, i * boxWidth , 0);
            CGContextAddLineToPoint(context, i * boxWidth , boxHeight);
        }
    }else{
        for (int i = 0 ; i < self.boxCount; i ++) {
            CGRect boxRect = [self getBoxRect:i size:rect.size];
            boxRect = CGRectInset(boxRect, _borderWidth * 0.5, _borderWidth * 0.5);
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:_boxRadius];
            CGContextAddPath(context, bezierPath.CGPath);
        }
    }
    //绘制
    CGContextDrawPath(context, kCGPathStroke);
}

/**
 * 绘制圆点
 * context   上下文
 * rect
 **/
-(void)drawDot:(CGContextRef)context
          rect:(CGRect)rect{
    for (int i = 0; i < self.boxCount; i ++) {
        //设置填充颜色
        CGContextSetFillColorWithColor(context, [self.dotColor colorWithAlphaComponent:[self.dotAlphas[i] floatValue]].CGColor);
        CGRect dotRect = [self getBoxRect:i size:rect.size];
        //圆心的y坐标
        float cy = CGRectGetMidY(dotRect);
        //圆心的x坐标
        float cx = CGRectGetMidX(dotRect);
        //半径
        float half = self.dotRadius * [self.dotScans[i] floatValue];
        //添加一个圆
        CGContextAddArc(context, cx, cy,half, 0, 2 * M_PI, 0);
        //绘制填充
        CGContextDrawPath(context, kCGPathFill);
    }
}

/**
 * 绘制文字
 * context   上下文
 * rect
 **/
-(void)drawString:(CGContextRef)context
             rect:(CGRect)rect{
    if ([self hasText] == NO) {
        return;
    }
    NSMutableString *str = [NSMutableString stringWithString:_text];
    for (int i = 0; i < _text.length; i++) {
        NSDictionary *attr = @{NSForegroundColorAttributeName:[_textColor colorWithAlphaComponent:[self.dotAlphas[i] floatValue]],
                               NSFontAttributeName: self.font};
        CGRect strRect = [self getBoxRect:i size:rect.size];
        //获取字符
        NSString *subString = [str substringWithRange:NSMakeRange(i, 1)];
        //计算文字大小
        CGSize textSize = [subString sizeWithAttributes:attr];
        //计算绘制区间
        CGRect drawRect = CGRectInset(strRect,(strRect.size.width - textSize.width) / 2,(strRect.size.height - textSize.height) / 2);
        //绘制文字
        [subString drawInRect:drawRect withAttributes:attr];
    }
}


/**
 * 计算方框的坐标
 * i     第几个方框
 * size  总大小（self的size）
 **/
-(CGRect)getBoxRect:(int)i
               size:(CGSize)size{
    //考虑到最后一个box需要顶到右侧，所以需要加上一个_boxMargin
    float boxWidth = (size.width + _boxMargin)/self.boxCount - _boxMargin;
    float boxHeight = size.height;
    float left = (self.boxMargin + boxWidth) * i;
    float top = 0;
    //限制为正方形
    if (_boxSquare) {
        float min = MIN(boxWidth, boxHeight);
        float dw = (boxWidth - min) / 2.0F;
        float dh = (boxHeight - min) / 2.0F;
        left += dw;
        top += dh;
        boxWidth = min;
        boxHeight = min;
    }
    return CGRectMake(left, top , boxWidth , boxHeight);
}

-(float)getMinBoxSide{
    float width = CGRectGetWidth(self.bounds);
    float height = CGRectGetHeight(self.bounds);
    float boxWidth = (width + _boxMargin)/self.boxCount - _boxMargin;
    float min = MIN(height, boxWidth) - _borderWidth;
    return min;
}

#pragma mark - 动画
//开始动画
-(void)startTextChangeAnimation{
//    [self setNeedsDisplay];
#if TARGET_INTERFACE_BUILDER
    //给xib用的
    self.showDuration = 0;
    [self updateString];
#else
    //运行时用的
    self.beginTime = CACurrentMediaTime();
    self.endTime = self.beginTime + self.showDuration;
    self.displayLink.paused = NO;
#endif
}

- (void)updateString
{
    //获取当前时间
    CFTimeInterval now = CACurrentMediaTime();
    NSInteger index = self.text.length - 1;
    for (int i = 0; i < self.boxCount; i ++) {
        //原数值(由于两个值一致，所以就用一个来计算了)
        CGFloat number =  [self.dotAlphas[i] floatValue];
        //变化率
        CGFloat d = 1;
        if (self.showDuration > 0) {
            //计算变化率（总数值／(动画帧数 * 动画时间)），即每次刷新屏幕变化的值
            d = 1/(15.0f*self.showDuration);
        }
        if (i > index) {
            if (number > 0) {
                number -= d;
            }
        }else{
            if (number < 1) {
                number += d;
            }
        }
        self.dotAlphas[i] = @(number);
        self.dotScans[i] = @(number);
    }
    //重绘视图
    [self setNeedsDisplay];
    //如果已经到了动画结束时间，就停止
    if (now > self.endTime) {
        self.displayLink.paused = YES;
    }
}

@end

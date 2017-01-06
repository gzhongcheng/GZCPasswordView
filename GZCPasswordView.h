//
//  GZCPasswordView.h
//  GZCPasswordWindow
//
//  Created by ZhongCheng Guo on 2017/1/4.
//  Copyright © 2017年 ZhongCheng Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GZCPasswordView;
@protocol GZCPasswordViewDelegate <NSObject>

@optional

// 是否能够被改变
-(BOOL)passwordView:(GZCPasswordView *)passwordView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text;

// 内容改变后
-(void)passwordViewDidChangedText:(GZCPasswordView *)passwordView;

// 当输入完成后，是否需要自动取消第一响应者,返回YES则收起键盘（如果有的话）。默认为返回 NO。
-(BOOL)passwordViewDidFullText:(GZCPasswordView *)passwordView;

@end

IB_DESIGNABLE
@interface GZCPasswordView : UIControl

//文本内容
@property (nonatomic, copy ) IBInspectable NSString * text;
// 设置文本字号 默认17
@property (nonatomic,assign) IBInspectable CGFloat fontSize;
// 设置文本字体 默认系统字体17号
@property (nonatomic,strong) UIFont *font;
//设置文本颜色，默认为黑色。
@property (nonatomic,strong) IBInspectable UIColor *textColor;

//密文显示时，圆点的半径大小,不超过每个格子的大小
@property (nonatomic,assign) IBInspectable CGFloat dotRadius;
//密文显示时，圆点的颜色
@property (nonatomic,strong) IBInspectable UIColor * dotColor;

//可以输入几位数(范围为1～9,超出范围无效)
@property (nonatomic,assign) IBInspectable NSInteger boxCount;
//输入框的间距（如果小于2，则为连续的框）
@property (nonatomic,assign) IBInspectable CGFloat boxMargin;
//输入框的圆角半径,不超过最短边的一半
@property (nonatomic,assign) IBInspectable CGFloat boxRadius;
//是否限制为正方形
@property (nonatomic,assign) IBInspectable BOOL boxSquare;

//输入框边框宽度
@property (nonatomic,assign) IBInspectable CGFloat borderWidth;
//输入框边框颜色
@property (nonatomic,strong) IBInspectable UIColor * borderColor;

//圆点的动画时间，默认为0.2s
@property (nonatomic,assign) CFTimeInterval showDuration;

//是否为密码输入框，为YES时显示圆点，默认为YES
@property (nonatomic,assign) IBInspectable BOOL secureTextEntry;

//代理
@property (nonatomic, weak ) id <GZCPasswordViewDelegate> delegate;

//是否可以编辑,默认为YES
@property (nonatomic,assign) IBInspectable BOOL editable;


@end

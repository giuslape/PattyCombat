

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"

typedef enum{
	kBarRounded,
	kBarRectangle,
} kBarTypes;


@class GPBar;

@protocol GPBarDelegate

-(void)barDidEmpty:(GPBar *)bar;

@end


@interface GPBar : GameObject {
    
    NSString *bar, *inset, *mask;
    CCSprite *barSprite, *maskSprite, *insetSprite, *masked;
    CCSpriteFrame* greenBar;
    CCSpriteFrame* redBar;
    CCRenderTexture *renderMasked, *renderMaskNegative;
    kBarTypes type;
    float progress;
    float oldProgress;
    BOOL active, spritesheet;
    BOOL barLR;
    CGPoint screenMid;
    
#if __has_feature(objc_arc_weak)
    __weak id <GPBarDelegate> _delegate;
#elif __has_feature(objc_arc)
    __unsafe_unretained  id <GPBarDelegate> _delegate;
#else
     id <GPBarDelegate> _delegate;  
#endif
}
@property (nonatomic, strong ,readonly)	NSString *bar, *inset, *mask;
@property (nonatomic) float progress;
@property kBarTypes type;
@property BOOL active;

#if __has_feature(objc_arc_weak)
@property (nonatomic, weak) id <GPBarDelegate> delegate;
#elif __has_feature(objc_arc)
@property (nonatomic, unsafe_unretained) id <GPBarDelegate> delegate;
#else
@property (nonatomic, assign) id <GPBarDelegate> delegate;
#endif


+(id) barWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m;
-(id) initBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m;
+(id) barWithBarFrameName:(NSString *)b insetFrameName:(NSString *)i maskFrameName:(NSString *)m;
-(id) initBarWithBarFrame:(NSString *)b insetFrame:(NSString *)i maskFrame:(NSString *)m;

-(void) hide;
-(void) show;
-(void) setTransparency:(float)trans;
-(void) setProgress:(float)lv;
-(void) clearRender;
-(void) maskBar;

@end

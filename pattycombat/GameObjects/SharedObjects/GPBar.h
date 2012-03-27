

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"

typedef enum{
	kBarRounded,
	kBarRectangle,
} kBarTypes;


@protocol GPBarDelegate

-(void)barDidEmpty:(id)bar;

@end


@interface GPBar : GameObject {
    
    NSString *bar, *inset, *mask;
    CCSprite *barSprite, *maskSprite, *insetSprite, *masked;
    CCRenderTexture *renderMasked, *renderMaskNegative;
    kBarTypes type;
    float progress;
    float oldProgress;
    BOOL active, spritesheet;
    BOOL barLR;
    CGPoint screenMid;
    __weak id <GPBarDelegate> _delegate;
}
@property (nonatomic, strong ,readonly)	NSString *bar, *inset, *mask;
@property (nonatomic, weak) id <GPBarDelegate> delegate;
@property (nonatomic) float progress;
@property kBarTypes type;
@property BOOL active;

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

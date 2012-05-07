//
//  Player.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 08/09/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameCharacter.h"
#import "GameManager.h"

@interface Player : GameCharacter

{
    CGRect rectLeft;
    CGRect rectRight;
    CGRect rectLeftFoot;
    CGRect rectRightFoot;
    CGRect rectLeftCross;
    CGRect rectRightCross;
    
#if __has_feature(objc_arc_weak)
    __weak CCSpriteBatchNode* _spriteBatchNode;
    __weak CCSpriteBatchNode* _spriteHitUnderBatchNode;
    __weak CCSpriteBatchNode* _spriteHitOverBatchNode;
    
    __weak id <PlayerDelegate> _delegate;
#elif __has_feature(objc_arc)
    __unsafe_unretained CCSpriteBatchNode* _spriteBatchNode;
    __unsafe_unretained CCSpriteBatchNode* _spriteHitUnderBatchNode;
    __unsafe_unretained CCSpriteBatchNode* _spriteHitOverBatchNode;
    
    __unsafe_unretained id <PlayerDelegate> _delegate;
#else
     CCSpriteBatchNode* _spriteBatchNode;
     CCSpriteBatchNode* _spriteHitUnderBatchNode;
     CCSpriteBatchNode* _spriteHitOverBatchNode;
    
     id <PlayerDelegate> _delegate;
#endif

    
    
    int cnt;
    double currentTime;
        
}


@property(nonatomic, strong)CCAnimation* manoDestraApre;
@property(nonatomic, strong)CCAnimation* manoDestraChiude;
@property(nonatomic, strong)CCAnimation* manoSinistraApre;
@property(nonatomic, strong)CCAnimation* manoSinistraChiude;
@property(nonatomic, strong)CCAnimation* manoDestraColpita;
@property(nonatomic, strong)CCAnimation* manoSinistraColpita;
@property(nonatomic, strong)CCAnimation* manoSinistraCrossApre;
@property(nonatomic, strong)CCAnimation* manoSinistraCrossChiude;
@property(nonatomic, strong)CCAnimation* manoDestraCrossApre;
@property(nonatomic, strong)CCAnimation* manoDestraCrossChiude;
@property(nonatomic, strong)CCAnimation* manoSinistraCrossColpita;
@property(nonatomic, strong)CCAnimation* manoDestraCrossColpita;
@property(nonatomic, strong)CCAnimation* feedBody;
@property(nonatomic, strong)CCAnimation* feedBodyErr;
@property(nonatomic, strong)CCAnimation* manoSinistraHitUnder;
@property(nonatomic, strong)CCAnimation* manoSinistraHitOver;
@property(nonatomic, strong)CCAnimation* manoDestraHitUnder;
@property(nonatomic, strong)CCAnimation* manoDestraHitOver;
@property(nonatomic, strong)CCAnimation* manoSinistraCrossHitUnder;
@property(nonatomic, strong)CCAnimation* manoSinistraCrossHitOver;
@property(nonatomic, strong)CCAnimation* manoDestraCrossHitUnder;
@property(nonatomic, strong)CCAnimation* manoDestraCrossHitOver;

@property(nonatomic, strong) NSMutableArray* pattern;
@property(nonatomic, strong) NSString* name;


#if __has_feature(objc_arc_weak)
@property(nonatomic, weak) CCSpriteBatchNode* spriteBatchNode;
@property(nonatomic, weak) CCSpriteBatchNode* spriteHitUnderBatchNode;
@property(nonatomic, weak) CCSpriteBatchNode* spriteHitOverBatchNode;
@property(nonatomic, weak) id <PlayerDelegate> delegate;

#elif __has_feature(objc_arc)
@property(nonatomic, unsafe_unretained) CCSpriteBatchNode* spriteBatchNode;
@property(nonatomic, unsafe_unretained) CCSpriteBatchNode* spriteHitUnderBatchNode;
@property(nonatomic, unsafe_unretained) CCSpriteBatchNode* spriteHitOverBatchNode;
@property(nonatomic, unsafe_unretained) id <PlayerDelegate> delegate;
#else
@property(nonatomic, assign) CCSpriteBatchNode* spriteBatchNode;
@property(nonatomic, assign) CCSpriteBatchNode* spriteHitUnderBatchNode;
@property(nonatomic, assign) CCSpriteBatchNode* spriteHitOverBatchNode;
@property(nonatomic, assign) id <PlayerDelegate> delegate;
#endif

@property(readwrite) int currentItem;
@property(readwrite) BOOL handIsOpen;
@property(readwrite) BOOL handsAreOpen;
@property(readwrite) BOOL touchOk;

+(id)playerWithDictionary:(NSDictionary *)playerSettings;
-(id)initWithDictionary:(NSMutableDictionary*)playerSettings;


@end

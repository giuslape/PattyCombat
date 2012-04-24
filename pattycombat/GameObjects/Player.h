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
    
    __weak CCSpriteBatchNode* _spriteBatchNode;
    __weak CCSpriteBatchNode* _spriteHitUnderBatchNode;
    __weak CCSpriteBatchNode* _spriteHitOverBatchNode;
    
    __weak id <PlayerDelegate> _delegate;

    
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
@property(nonatomic, weak) CCSpriteBatchNode* spriteBatchNode;
@property(nonatomic, weak) CCSpriteBatchNode* spriteHitUnderBatchNode;
@property(nonatomic, weak) CCSpriteBatchNode* spriteHitOverBatchNode;
@property(nonatomic, strong) NSMutableArray* pattern;
@property(nonatomic, strong) NSString* name;

@property(nonatomic, weak) id <PlayerDelegate> delegate;



@property(readwrite) int currentItem;
@property(readwrite) BOOL handIsOpen;
@property(readwrite) BOOL handsAreOpen;
@property(readwrite) BOOL touchOk;

+(id)playerWithDictionary:(NSDictionary *)playerSettings;
-(id)initWithDictionary:(NSMutableDictionary*)playerSettings;


@end

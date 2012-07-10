//
//  MainIntro.h
//  pattycombat
//
//  Created by Vincenzo Lapenta on 14/06/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "SimpleAudioEngine.h"
#import "CDXPropertyModifierAction.h"


@interface GinoScappelloni : CCLayer
@end

@interface MainIntro : CCLayer <CCScrollLayerDelegate>{
    
    CDSoundSource* sound1;
    CDSoundSource* sound2;
}

-(void)fadeSound:(CDSoundSource *)sender;

@end

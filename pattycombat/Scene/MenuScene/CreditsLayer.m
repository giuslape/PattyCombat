//
//  CreditsLayer.m
//  pattycombat
//
//  Created by Giuseppe Lapenta on 22/04/12.
//  Copyright 2012. All rights reserved.
//

#import "CreditsLayer.h"


@implementation CreditsLayer

@synthesize delegate = _delegate;


-(id)initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h{

        if( (self=[super initWithColor:color width:w height:h]) ) {
            
            CGSize size = [CCDirectorIOS sharedDirector].winSize;
            
            self.isTouchEnabled = YES;
            
         //   [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
            
            CCSprite* logoSprite = [CCSprite spriteWithFile:@"logo_balzo_4444.png"];
            
            CCMenuItemSprite* logoBalzo = [CCMenuItemSprite itemWithNormalSprite:logoSprite 
                                                                  selectedSprite:nil
                                                                  disabledSprite:nil
                                                                          target:self 
                                                                        selector:@selector(showWebSite:)];            
            CCMenu* menu = [CCMenu menuWithItems:logoBalzo, nil];
            
            CCLabelTTF* team = [CCLabelTTF labelWithString:@" Software development:\n Giuseppe Lapenta \n\n Graphic design:\n Vincenzo Santalucia \n\n Sound design:\n Dario Trovato \n\n\n Help us to continue \n Rate Patty Combat"
                                                dimensions:CGSizeMake(130, 180) 
                                                hAlignment:kCCTextAlignmentLeft 
                                                vAlignment:kCCVerticalTextAlignmentTop
                                                lineBreakMode:kCCLineBreakModeCharacterWrap 
                                                fontName:@"Helvetica"
                                                  fontSize:12];
            
            
            CCSprite* icon = [CCSprite spriteWithFile:@"Icon.png"];
            
            CCSprite* closeButton = [CCSprite spriteWithFile:@"FBDialog.bundle/images/close.png"];
            
            CCLabelTTF* creditsLabel = [CCLabelTTF labelWithString:@"The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps. Bawds jog, flick quartz, vex nymphs. Waltz, bad nymph, for quick jigs vex! Fox nymphs grab quick-jived waltz.\n\n Beta Tester: \n\n"
                @"How quickly daft jumping zebras vex. Two driven jocks help fax my big quiz. Quick, Baz, get my woven flax jodhpurs! \"Now fax quiz Jack! \" my brave ghost pled. \n Five quacking zephyrs jolt my wax bed. Flummoxed by job, kvetching W. zaps Iraq. Cozy sphinx waves quart jug of bad milk. A very bad quack might jinx zippy fowls. Few quips galvanized the mock jury box. Quick brown dogs jump over the lazy fox. The jay, pig, fox, zebra, and my wolves quack! Blowzy red vixens fight for a quick jump. Joaquin Phoenix was gazed by MTV for luck. It showed a lady fitted out with a fur hat and fur boa who sat upright, raising a heavy fur muff that covered the whole of her lower arm towards the viewer. Gregor then turned to look out the window at the dull weather. Drops" 
                                        
                                                   dimensions:CGSizeMake(250, 220) 
                                                   hAlignment:kCCTextAlignmentLeft 
                                                lineBreakMode:kCCLineBreakModeClip
                                                     fontName:@"Helvetica"
                                                     fontSize:12];
            
            [self addChild:menu];
            [self addChild:team];
            [self addChild:icon];
            [self addChild:creditsLabel];
            [self addChild:closeButton z:3 tag:10];
            
            [menu setAnchorPoint:ccp(0, 0)];
            [team setAnchorPoint:ccp(0, 0)];
            [icon setAnchorPoint:ccp(0, 0)];
            [creditsLabel setAnchorPoint:ccp(0, 0)];
            
            [menu setPosition:ccp(size.width * 0.16f, size.height * 0.85f)];
            [team setPosition:ccp(size.width * 0.05f, 30)];
            [icon setPosition:ccp(size.width * 0.30f, size.height * 0.10f)];
            [closeButton setPosition:ccp(size.width * 0.97f, size.height * 0.95f)];
            [creditsLabel setPosition:ccp(size.width * 0.45f, size.height * 0.10f)];
            
           // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        }
        return self;

}

-(void) registerWithTouchDispatcher
{
    [[CCDirectorIOS sharedDirector].touchDispatcher addTargetedDelegate:self priority:INT_MIN + 1
     
                                              swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirectorIOS sharedDirector] convertToGL:location];
    
    CCSprite* closeButton = (CCSprite *)[self getChildByTag:10];
    
    if (CGRectContainsPoint([closeButton boundingBox], location)) {
        
        [_delegate creditsLayerDidClose:self];
        return  YES;
    }
    
    return NO;
}

-(void)showWebSite:(id)sender{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
    NSURL *urlToOpen = nil;
    
    urlToOpen = [NSURL URLWithString:@"http://balzo.eu"];
    
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        CCLOG(@"%@%@",@"Failed to open url:",[urlToOpen description]);
    }
    
}

- (void)dealloc
{
    _delegate = nil;
}

@end

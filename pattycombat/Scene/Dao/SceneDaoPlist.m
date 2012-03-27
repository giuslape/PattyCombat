//
//  SceneDaoPlist.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 07/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "SceneDaoPlist.h"


@implementation SceneDaoPlist

#pragma mark Load Scene

-(NSDictionary*) loadScene:(int)sceneNumber
{
    
    NSString* scena = [NSString stringWithFormat:@"Scena%d",sceneNumber];
    NSString *fullFileName = 
    [NSString stringWithString:@"Scene.plist"];
    NSString *plistPath;
    
    // 1: Prende il path dal file Plist
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:@"Scene" ofType:@"plist"];
    }
    
    // 2: Legge nel Plist
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3:Controlla se il dizionario è vuoto.
    if (plistDictionary == nil) {
        NSLog(@"Error reading plist: Players.plist");
        return nil;
    }
    
    // 4: mini-dizionario per Scena
    NSDictionary * sceneSettings = 
    [plistDictionary objectForKey:scena];
    if (sceneSettings == nil) {
        NSLog(@"Could not locate:%@",scena);
        return nil;
    }

    return sceneSettings;
}

#pragma mark Load Animation

-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className {
    
    CCAnimation *animationToReturn = nil;
    NSString *fullFileName = 
    [NSString stringWithFormat:@"%@.plist",className];
    NSString *plistPath;
    
    // 1: Prende il path dal file Plist
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:className ofType:@"plist"];
    }
    
    // 2: Legge nel Plist
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3:Controlla se il dizionario è vuoto.
    if (plistDictionary == nil) {
        CCLOG(@"Error reading plist: %@.plist", className);
        return nil; // No Plist Dictionary or file found
    }
    
    // 4: mini-dizionario per animazione
    NSDictionary *animationSettings = 
    [plistDictionary objectForKey:animationName];
    if (animationSettings == nil) {
        CCLOG(@"Could not locate AnimationWithName:%@",animationName);
        return nil;
    }
    
    // 5:Prende il valore del ritardo dell'animazione
    float animationDelay = 
    [[animationSettings objectForKey:@"delay"] floatValue];
    animationToReturn = [CCAnimation animation];
    [animationToReturn setDelayPerUnit:animationDelay];
    
    // 6: Aggiunge i frames all'animazione
    NSString *animationFramePrefix = 
    [animationSettings objectForKey:@"filenamePrefix"];
    NSString *animationFrames = 
    [animationSettings objectForKey:@"animationFrames"];
    NSArray *animationFrameNumbers = 
    [animationFrames componentsSeparatedByString:@","];
    
    for (NSString *frameNumber in animationFrameNumbers) {
        NSString *frameName = 
        [NSString stringWithFormat:@"%@%@.png",
         animationFramePrefix,frameNumber];
        [animationToReturn addSpriteFrame:
         [[CCSpriteFrameCache sharedSpriteFrameCache] 
          spriteFrameByName:frameName]];
    }
    
    return animationToReturn;
}

#pragma mark Load Player

-(NSDictionary *)loadPlayerWithName:(NSString *)name{
    
    NSString* scena = [NSString stringWithString:@"player"];
    NSString *fullFileName = 
    [NSString stringWithFormat:@"%@.plist",name];
    NSString *plistPath;
    
    // 1: Prende il path dal file Plist
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:@"Scene" ofType:@"plist"];
    }
    
    // 2: Legge nel Plist
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3:Controlla se il dizionario è vuoto.
    if (plistDictionary == nil) {
        NSLog(@"Error reading plist: Players.plist");
        return nil;
    }
    
    // 4: mini-dizionario per Scena
    NSDictionary * sceneSettings = 
    [plistDictionary objectForKey:scena];
    if (sceneSettings == nil) {
        NSLog(@"Could not locate:%@",scena);
        return nil;
    }
    
    return sceneSettings;
}
#pragma mark Load Pattern


-(NSMutableArray*)loadPlistForPatternWithLevel:(int)sceneId{
    
    NSMutableArray *patternToReturn = nil;
    NSString *fullFileName = 
    [NSString stringWithString:@"Patterns.plist"];
    NSString *plistPath;
    NSString* className = [NSString stringWithFormat:@"Scena%d",sceneId];
    
    // 1: Prende il path dal file plist
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:@"Patterns" ofType:@"plist"];
    }
    
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    if (plistDictionary == nil) {
        CCLOG(@"Error reading plist: %@.plist", className);
        return nil; // Non trova il dizionario
    }
    
    NSString* pattern = [plistDictionary objectForKey:className];
    
    patternToReturn = (NSMutableArray*)[pattern componentsSeparatedByString:@","];
    
    if ([patternToReturn count] > 1) {
        
        for (NSUInteger shuffleIndex = [patternToReturn count] - 1; shuffleIndex > 0; shuffleIndex--)
            [patternToReturn exchangeObjectAtIndex:shuffleIndex withObjectAtIndex:arc4random() % (shuffleIndex + 1)];
    }
    
    return patternToReturn;
}

#pragma mark Load Background

-(NSString*)loadBackgroundIntro:(NSString*)className atLevel:(int)currentLevel{
    
    
    NSString *fullFileName = [NSString stringWithString:className];
    NSString *plistPath;
    
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) 
     objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:@"BackgroundIntro" ofType:@"plist"];
    }
    
    // Legge il plist
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString* nameBackground = [NSString stringWithFormat:@"Intro%d",currentLevel];
    
    NSString* introBackground = [plistDictionary objectForKey:nameBackground];
    
    return introBackground;
}

-(NSString*)loadBackgroundGame:(NSString*)className atLevel:(int)currentLevel{
    
    
    NSString *fullFileName = [NSString stringWithString:className];
    NSString *plistPath;
    
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) 
     objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:@"BackgroundGameLayer" ofType:@"plist"];
    }
    
    // Legge il plist
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString* nameBackground = [NSString stringWithFormat:@"Background%d",currentLevel];
    
    NSString* introBackground = [plistDictionary objectForKey:nameBackground];
    
    return introBackground;
}

-(NSString *)loadBackgroundEnd:(NSString *)className atLevel:(int)currentLevel andWin:(BOOL)win{
    
    NSString *fullFileName = [NSString stringWithString:className];
    NSString *plistPath;
    
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) 
     objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:className ofType:@"plist"];
    }
    
    // Legge il plist
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    if (plistDictionary == nil) {
        CCLOG(@"Error reading plist: %@.plist", className);
        return nil; // Non trova il dizionario
    }
    
    NSDictionary* backgrounds = [plistDictionary objectForKey:[NSString stringWithFormat:@"EndBackground%d",currentLevel]];
    
    if (backgrounds == nil) {
        CCLOG(@"Error reading plist: EndBackGround.plist");
        return nil; // Non trova il dizionario
    }
    
    NSString* endBackground = nil;
    
    endBackground =  (win) ? [backgrounds objectForKey:@"win"] : [backgrounds objectForKey:@"loose"];
    
    return endBackground;

    
}


@end

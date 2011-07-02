//
//  DiamondsGame.m
//  Diamonds

#import "DiamondsGame.h"

#import "Engine.h"
#import "Sprite.h"
#import "SpriteBatch.h"
#import "ResourceManager.h"

@implementation DiamondsGame
{
    SpriteBatch* batch;
    
    Sprite* sprite1;
    Sprite* sprite2;
}

- (void) loadResources: (ResourceManager*) resources
{        
    sprite1 = [[Sprite alloc] initWithTextureName: @"diamond" from: resources];
    sprite2 = [[Sprite alloc] initWithTextureName: @"ruby" from: resources];
    
    [sprite1 moveTo: CGPointMake(0, 0)];
    [sprite2 moveTo: CGPointMake(200, 0)];
}

- (void) draw
{
    batch = [[SpriteBatch alloc] initWithEngine: self.engine];
    
    [batch begin];
    
    [sprite1 drawIn: batch];
    [sprite2 drawIn: batch];
    
    [batch end];
}

@end
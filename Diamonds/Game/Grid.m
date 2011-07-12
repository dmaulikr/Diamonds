//
//  Grid.m
//  Diamonds

#import "Grid.h"

GridPosition MakePosition(int column, int row)
{
    GridPosition position = { column, row };
    return position;
}

@implementation Grid
{
    NSMutableSet* gems;
}

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    gems = [NSMutableSet new];
    
    return self;
}

- (bool) isEmpty
{
    return [gems count] == 0;
}

- (void) put: (GemType) type at: (GridPosition) position
{
    if ([[self get: position] type] != EmptyGem)
    {
        @throw [NSException exceptionWithName:@"Grid" reason: @"Grid position is not empty" userInfo: nil];
    }
    
    [gems addObject: [[Gem alloc] initWithType: type at: position resources: nil]];
}

- (Gem*) get: (GridPosition) position
{
    for (Gem* gem in gems)
    {
        if (gem.position.column == position.column &&
            gem.position.row == position.row)
        {
            return gem;
        }
    }
    
    return [[Gem alloc] initWithType: EmptyGem at: MakePosition(0, 0) resources: nil];
}


@end
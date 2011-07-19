//
//  Gem.m
//  Diamonds

#import "Gem.h"

#import "Sprite.h"
#import "SpriteBatch.h"
#import "ResourceManager.h"
#import "Grid.h"

@implementation Droppable
{
    int width;
    int height;
    
@protected
    GridCell cell;
    GemState state;
    
@private
     Droppable* __weak parent;
}

@synthesize width;
@synthesize height;

@synthesize cell;
@synthesize state;
@synthesize cellHeight;

@synthesize parent;

- (id) initAt: (GridCell) cell_ width: (int) width_ height: (int) height_;
{
    self = [super init];
    if (self == nil)
    {
        return nil;
    }
    
    cell = cell_;
    width = width_;
    height = height_;
    
    state = Stopped;    
    cellHeight = 0.0f;
    
    return self;    
}

- (void) detachFromParent
{
    cell.column += self.parent.cell.column;
    cell.row += self.parent.cell.row;

    self.parent = nil;
}

- (bool) contains: (GridCell) cell_
{
    GridCell droppableCell = self.cell;
    return 
        cell_.row >= droppableCell.row && cell_.column >= droppableCell.column &&
        cell_.row < droppableCell.row + self.height && cell_.column < droppableCell.column + self.width;
}

- (bool) canMoveRight: (Grid*) grid
{
    GridCell newCell = self.cell;
    newCell.column += 1;
    
    if (![grid isCellValid: newCell])
        return false;
    
    return [grid isCellEmpty: newCell];    
}

- (bool) canMoveLeft: (Grid*) grid
{
    GridCell newCell = self.cell;
    newCell.column -= 1;
    
    if (![grid isCellValid: newCell])
        return false;
    
    return [grid isCellEmpty: newCell];    
}

- (bool) canMoveDown: (Grid*) grid
{
    GridCell newCell = self.cell;
    newCell.row -= 1;
    
    if (![grid isCellValid: newCell])
        return false;
    
    return [grid isCellEmpty: newCell];    
}

- (void) moveRightOn: (Grid*) grid
{
    if ([self canMoveRight: grid])
    {
        cell.column += 1;
    }
}

- (void) moveLeftOn: (Grid*) grid
{
    if ([self canMoveLeft: grid])
    {
        cell.column -= 1;
    }
}

- (void) updateWithGravity: (float) gravity onGrid: (Grid*) grid
{
    if (state == Falling)
    {
        cellHeight -= gravity;
        
        if (cellHeight < 0.00f)
        {
            cellHeight += 1.00f;
            
            if ([self canMoveDown: grid])
            {
                cell.row -= 1;
            }
            else
            {
                state = Stopped;
                cellHeight = 0.00f;
            }
        }
    }    
    else
    if (state == Stopped)
    {
        if ([self canMoveDown: grid])
        {
            cell.row -= 1;
            cellHeight = 1.00f - gravity;
            if (cellHeight > 0.0)
            {
                state = Falling;
            }
        }
    }
}

- (void) drawIn: (SpriteBatch*) batch info: (GridPresentationInfo) info
{
}

- (GridCell) relativeCell
{
    return cell;
}

- (GridCell) cell
{
    GridCell absoluteCell = cell;
    GridCell parentCell = parent.cell;

    absoluteCell.row += parentCell.row;
    absoluteCell.column += parentCell.column;
    
    return absoluteCell;
}

- (float) cellHeight
{
    return cellHeight + parent.cellHeight;
}

- (void) setCellHeight: (float) height_
{
    cellHeight = height_;
}

@end

@interface Gem (private)
@property (readonly) Sprite* sprite;
@end

@implementation Gem
{
    GemType type; 
        
    Sprite* sprite;
}

@synthesize type;

- (NSString*) getTextureNameFromType: (GemType) gemType
{
    if (gemType == Diamond)
        return @"diamond";
    if (gemType == Ruby)
        return @"ruby";
    if (gemType == Sapphire)
        return @"sapphire";
    
    return nil;
}

- (Texture*) getTextureFromType: (GemType) gemType resources: (ResourceManager*) resources
{
    if (gemType == EmptyGem)
        return nil;
    
    return [resources loadTexture: [self getTextureNameFromType: gemType]];
}

- (void) initSpriteForType: (GemType) gemType resources: (ResourceManager*) resources   
{
    sprite = [[Sprite alloc] initWithTexture: [self getTextureFromType: gemType resources: resources]];

    [sprite setSourceRectangle: CGRectMake(0, 0, 32, 32)];
    [sprite resizeTo: CGSizeMake(32, 32)];
}

- (id) initWithType: (GemType) gemType at: (GridCell) cell_ resources: (ResourceManager*) resources
{
    self = [super initAt: cell_ width: 1 height: 1];
    if (self == nil)
        return nil;
    
    type = gemType;
    
    [self initSpriteForType: gemType resources: resources];
    
    return self;
}

- (void) drawIn: (SpriteBatch*) batch info: (GridPresentationInfo) info;
{ 
    CGPoint spritePosition = info.origin;
    
    spritePosition.x += info.cellSize.width * self.cell.column; 
    spritePosition.y -= info.cellSize.height * self.cell.row - (info.cellSize.height * (info.heightInCells - 1)); 
    spritePosition.y += (-self.cellHeight) * info.cellSize.height;
    
    [sprite moveTo: spritePosition];
    [sprite drawIn: batch];
}

- (NSString*) description
{
    NSString* typeString = @"NoType";
    
    if (type == Diamond)
        typeString =  @"Diamond";
    if (type == Ruby)
        typeString =  @"Ruby";
    if (type == Sapphire)
        typeString =  @"Sapphire";
    
    return [NSString stringWithFormat: @"[%p] %@ (%d %d)", self, typeString, self.cell.column, self.cell.row]; 
}

- (Sprite*) sprite
{
    return sprite;
}

@end

@implementation GemAggregate
{
    NSMutableArray* droppables;
}

- (id) initAt: (GridCell) cell_ width: (int) width_ height: (int) height_
{
    self = [super initAt: cell_ width: width_ height: height_];
    if (self == nil)
        return nil;
    
    droppables = [NSMutableArray arrayWithCapacity: self.width * self.height];
    
    return self;    
}

- (bool) isCellInBounds: (GridCell) cell_
{
    return 
        cell_.column >= 0 && cell_.column < self.width &&
        cell_.row >= 0 && cell_.row < self.height;
}

- (bool) isCellEmpty: (GridCell) cell_
{
    for (Droppable* droppable in droppables)
    {
        if (
            droppable.relativeCell.row == cell_.row && 
            droppable.relativeCell.column == cell_.column)
        {
            return false;
        }
    }
    
    return true;
}

- (bool) isDroppableValid: (Droppable*) droppable
{
    return 
        [self isCellEmpty: droppable.relativeCell] &&
        [self isCellInBounds: droppable.relativeCell];
    
}

- (void) add: (Droppable*) droppable
{
    if (![self isDroppableValid: droppable])
    {
        @throw [NSException exceptionWithName:@"GemAggregate" reason: @"Aggregate cell is not empty" userInfo: nil];        
    }
    
    droppable.parent = self;
    [droppables addObject: droppable];    
}

- (Gem*) gem: (int) index
{
    return (Gem*) [droppables objectAtIndex: index];
}

- (void) releaseOn: (Grid*) grid
{
    [grid remove: self];
    
    for (Droppable* droppable in droppables)
    {
        [droppable detachFromParent];
        [grid put: droppable];
    }
}

@end

@implementation DroppablePair
{
    Gem* buddy;
    Gem* pivot;
}

@synthesize pivot;
@synthesize buddy;

- (Gem*) addGem: (GemType) gemType at: (GridCell) cell_ resources: (ResourceManager*) resources;
{
    Gem* gem = [[Gem alloc] initWithType: gemType at: cell_ resources: resources];
    [self add: gem];
    return gem;    
}

- (id) initAt: (GridCell) cell_ with: (GemType[]) gems resources: (ResourceManager*) resources
{
    self = [super initAt: cell_ width: 1 height: 2];
    if (self == nil)
    {
        return nil;
    }

    pivot = [self addGem: gems[0] at: MakeCell(0, 0) resources: resources];
    buddy = [self addGem: gems[1] at: MakeCell(0, 1) resources: resources];

    return self;
}

- (void) drawIn: (SpriteBatch*) batch info: (GridPresentationInfo) info
{
    [pivot drawIn: batch info: info];
    [buddy drawIn: batch info: info];
}

- (NSString*) description
{
    return [NSString stringWithFormat: @"[%p] DroppablePair <%@, %@>", self, pivot, buddy];
}

@end
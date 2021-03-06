//
//  Texture.m
//  Diamonds

#import "Texture.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation Texture
{    
    GLuint texture;
}

@synthesize size;
@synthesize name;

- (id) initWithName: (NSString*) textureName
{
    self = [super init];
    if (self == nil)
    {
        return nil;
    }

    name = textureName;
    
    return self;
}

- (void) load: (NSString*) folder
{
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    NSString *path = [[NSBundle mainBundle] pathForResource: self.name ofType: @"png" inDirectory: folder];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    
    NSLog(@"Loading %@...", path);
    if (image == nil)
    {
        NSLog(@"Do real error checking here");
    }
    
    size.width = CGImageGetWidth(image.CGImage);
    size.height = CGImageGetHeight(image.CGImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    void* imageData = malloc(size.height * size.width * 4);
    
    CGContextRef context = CGBitmapContextCreate(imageData, size.width, size.height, 8, 4 * size.width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    CGColorSpaceRelease( colorSpace );
    
    CGContextClearRect( context, CGRectMake(0, 0, size.width, size.height ) );
    
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(context);
    
    free(imageData);    
}

- (void) bind
{
    glBindTexture(GL_TEXTURE_2D, texture);
}

- (NSString*) description
{
    return [NSString stringWithFormat: @"Texture: %@ [%d %d]", name, size.width, size.height];
}

@end

@implementation TextureFactory
{
    CGSize textureSize;
}

- (Texture*) create: (NSString*) name
{
    return [[Texture alloc] initWithName: name];
}

@end

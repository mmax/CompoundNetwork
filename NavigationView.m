//
//  NavigationView.m
//  CompoundNetwork
//
//  Created by Maximilian Marcoll on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NavigationView.h"
#import "NodeNavigation.h"

@implementation NavigationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor colorWithDeviceRed:.5 green:.6 blue:.6 alpha:1]set];
    [NSBezierPath fillRect:dirtyRect];
    [[NSGraphicsContext currentContext]setShouldAntialias:YES];
    int i;
    NSDictionary * d = [navigation valueForKey:@"activeMaterial"];
    
    
        
    for(i=0;i<[[d valueForKey:@"connectionCount"]intValue];i++){
        NSMutableDictionary * sd = [[d valueForKey:@"secondaryBrowseNodes"]objectAtIndex:i];
        
        [[NSColor blackColor]set];
        [[sd valueForKey:@"line"]stroke];

        NSBezierPath * p = [sd valueForKey:@"nodePath"];
        [[NSColor whiteColor]set];
        [p fill];
        [[NSColor blackColor]set];
        [p stroke];
        
        [self drawStringForNode:sd];		
        
    }
    
    NSMutableDictionary * pd = [d valueForKey:@"primaryBrowseNode"];
    NSBezierPath * p = [pd valueForKey:@"nodePath"];
    [[NSColor whiteColor]set];
    [p fill];
    [[NSColor blackColor]set];
    [p stroke];
    [self drawStringForNode:pd];

}


-(void)drawStringForNode:(NSMutableDictionary *)d{

    NSMutableAttributedString *s = [[[NSMutableAttributedString alloc]initWithString:[d valueForKey:@"name"]]autorelease];
    NSBezierPath * p = [d valueForKey:@"nodePath"];
    NSRect textRec = [p bounds];
    int stringOffset = textRec.size.width*.2;
    textRec.origin.x += stringOffset;
    textRec.origin.y += stringOffset;
    textRec.size.width -= 2*stringOffset;
    textRec.size.height -= 2*stringOffset;
    
    NSRange tRange = NSMakeRange(0, [s length]);	
    [s addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:tRange];
    [s addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:11] range:tRange];
    [s drawInRect:textRec];
    
}

/*s = [[[NSMutableAttributedString alloc]initWithString:[currentNode name]]autorelease];
 //  NSLog(@"no");
 tRange = NSMakeRange(0, [s length]);	
 [s addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:tRange];
[s addAttribute:NSFontAttributeName value:font range:tRange];*/




@end

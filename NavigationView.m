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
    
    NSDictionary * d = [[navigation valueForKey:@"materialConnections"]objectAtIndex:0];
    
    [[NSColor blackColor]set];
    
    for(NSBezierPath * p in [d valueForKey:@"browseConnectionPaths"])
        [p stroke];
    
    for(NSBezierPath * p in [d valueForKey:@"secondaryBrowseNodes"]){
    
        [[NSColor whiteColor]set];
        [p fill];
        [[NSColor blackColor]set];
        [p stroke];
    }
    
    NSBezierPath * p = [d valueForKey:@"primaryBrowseNode"];
    
    [[NSColor whiteColor]set];
    [p fill];
    [[NSColor blackColor]set];
    [p stroke];

}






@end

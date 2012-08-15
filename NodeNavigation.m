//
//  NodeNavigation.m
//  CompoundNetwork
//
//  Created by Maximilian Marcoll on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeNavigation.h"
#import "MyDocument.h"
#import "Material.h"
#import "NavigationView.h"

@implementation NodeNavigation



-(NodeNavigation *)init{
    
    
	if((self = [super init])){
        
		dict = [[NSMutableDictionary alloc]init];
        
	}
	return self;
}

-(void)dealloc{
    
	[dict removeAllObjects];
	[dict release];
	[super dealloc];
}

-(void)setValue:(id)value forKey:(NSString *)key{
	
	[dict setValue:value forKey:key];
}

-(id)valueForKey:(NSString *)key{
	
	return [dict valueForKey:key];
}

-(void)renderFlatMap{
    [navigationMaterialArrayController bind:@"contentArray" toObject:doc withKeyPath:@"materials" options:nil];
    
    [doc setProgressTask:@"computing connections..."];
    [doc setProgress:0];
    [doc displayProgress:YES];

    NSMutableArray * materialConnections = [[[NSMutableArray alloc]init]autorelease];
    [dict setValue:materialConnections forKey:@"materialConnections"];
    
    NSArray * materials = [doc materials];
    
    for(Material * m in materials)
        [self createRawEntryForMaterial:m];
    
    [self renderConnections];
    
    [self renderBrowsePaths];
    
    //[self setValue:[[self valueForKey:@"materialConnections"]objectAtIndex:0] forKey:@"activeMaterial"];
    [self setActiveMaterialToMaterialNamed:[materialPopUp titleOfSelectedItem]];
    [[view window]makeKeyAndOrderFront:nil];
    [doc displayProgress:NO];
}

-(void)renderBrowsePaths{

    [doc setProgress:0];
    [doc setProgressTask:@"rendering graphics..."];

    NSPoint center = [self center];
    float x, y, r, primaryR = 80, secondaryR = 50, offset= 100, secondaryRComposite, width, progress=0, matCount = [[self valueForKey:@"materialConnections"]count];
    int a=0;
    secondaryRComposite = primaryR+offset+secondaryR;
    
    for (NSMutableDictionary *d in [self valueForKey:@"materialConnections"]){
        
        progress = a/ matCount*100.0;
        [doc setProgress:progress];
        
        NSMutableArray * nodes = [[[NSMutableArray alloc]init]autorelease];
        
        int n = [[d valueForKey:@"connectionCount"]intValue], secondaryN;
        //NSLog(@"rendering: %@ with %d connections", [d valueForKey:@"name"], n);
        for(int i=0;i<n;i++){
            
            // COMPUTE CENTER OF SECONDARY POLYGON

            x = secondaryRComposite * sin((2*M_PI*i)/n) + center.x;
            y = secondaryRComposite * cos((2*M_PI*i)/n) + center.y;
           
            // CREATE SECONDARY POLYGON
            secondaryN =[[[[[d valueForKey:@"connections"]objectAtIndex:i]valueForKey:@"targetDictionary"]valueForKey:@"connectionCount"]intValue];
            NSPoint secondaryCenter = NSMakePoint(x, y);
            r = n > 3 ? 2*M_PI*secondaryRComposite/(n*3) : secondaryR;
            NSBezierPath * secondary = [self createPolygonAroundCenter:secondaryCenter withNAngles:secondaryN andRadius:r];

            // CREATE CONNECTION (LINE)
            NSBezierPath * connection =[[[NSBezierPath alloc]init]autorelease];
            width = [[[[[d valueForKey:@"connections"]objectAtIndex:i]valueForKey:@"targetDictionary"]valueForKey:@"connectionCount"]intValue];
            [self createLineInPath:connection fromCenterTo:secondaryCenter withLineWidth:width];
            //[connections addObject:connection];

            // STORE DATA
            NSMutableDictionary * sd = [NSMutableDictionary dictionary];
            [sd setValue:secondary forKey:@"nodePath"];
            [sd setValue:[[[[d valueForKey:@"connections"]objectAtIndex:i]valueForKey:@"targetDictionary"]valueForKey:@"name"] forKey:@"name"];
            [sd setValue:connection forKey:@"line"];
            [sd setValue:[[[[d valueForKey:@"connections"]objectAtIndex:i]valueForKey:@"targetDictionary"]valueForKey:@"connectionCount"] forKey:@"strength"];
            [nodes addObject:sd];
        }
        // CREATE PRIMARY POLYGON
        NSBezierPath * primary = [self createPolygonAroundCenter:center withNAngles:n andRadius:primaryR];
        [primary closePath];
        
        // STORE DATA
        NSMutableDictionary * pd = [NSMutableDictionary dictionary];
        [pd setValue:primary forKey:@"nodePath"];
        [pd setValue:[d valueForKey:@"name"] forKey:@"name"];
        [d setValue:pd forKey:@"primaryBrowseNode"];
        [d setValue:nodes forKey:@"secondaryBrowseNodes"];
        
    }
}

-(void)createLineInPath:(NSBezierPath *)p fromCenterTo:(NSPoint)target withLineWidth:(float)width{
   
    [p moveToPoint:[self center]];
    [p lineToPoint:target];
    [p setLineWidth:width];
    [p closePath];
}

-(NSBezierPath *)createPolygonAroundCenter:(NSPoint)center withNAngles:(int)n andRadius:(float)r{
   
    float x, y;
    NSBezierPath * p;
    
    if(n<3){
        NSRect rect = NSMakeRect(center.x-r, center.y-r, r*2, r*2);
        p = [NSBezierPath bezierPathWithOvalInRect:rect];
    }
    else{
        p = [NSBezierPath bezierPath];
        [p moveToPoint:NSMakePoint(center.x, center.y+r)];
        for(int i=0;i<n;i++){
            x = r * sin((2*M_PI*i)/n);
            y = r * cos((2*M_PI*i)/n);
            [p lineToPoint:NSMakePoint(center.x+x, center.y+y)];
        }
        [p closePath];
    }
    return p;
}



-(void)renderConnections{

    NSMutableArray * materialConnections = (NSMutableArray *)[self valueForKey:@"materialConnections"];

    int i=0;
    float progress=0, matCount = [materialConnections count];
        
    for(NSMutableDictionary * tempCenter in materialConnections){
        
        progress = i/matCount * 100.0;
        [doc setProgress:progress];
        
        Material * m = [tempCenter valueForKey:@"material"];
        [tempCenter setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"connections"];
        
        if(!m){
            NSLog(@"ERROR: NodeNavigation: renderConnections: NO MATERIAL FOUND! Aborting.");
            return;
        }
    
        NSArray * tagArray = [m valueForKey:@"tags"];
        // simply store each materialDict and tag in a dictionary and add it to the connections array
        
        for(NSDictionary * tag in tagArray){
            for(NSMutableDictionary * connector in materialConnections){
                if(![connector isEqual:tempCenter]){
                    if([[connector valueForKey:@"material"]hasTag:[tag valueForKey:@"name"]]){
                        NSMutableDictionary * connection = [[[NSMutableDictionary alloc]init]autorelease];
                        [connection setValue:connector forKey:@"materialDictionary"];
                        [connection setValue:tag forKey:@"tag"];
                        [[tempCenter valueForKey:@"connections"]addObject:connection];
                    }
                }
            }
        }

        [tempCenter setValue:[self sortConnections:[tempCenter valueForKey:@"connections"]] forKey:@"connections"];
        [tempCenter setValue:[NSNumber numberWithInt:[[tempCenter valueForKey:@"connections"]count]] forKey:@"connectionCount"];
                                                       
        i++;
    }
}

-(NSArray *)sortConnections:(NSArray *)unsorted{

    NSMutableArray * sorted = [[NSMutableArray alloc]init];
    
    for (NSDictionary * connection in unsorted){
        NSDictionary * matDict = [connection valueForKey:@"materialDictionary"];
        NSMutableDictionary * connector  = [self dictionaryForMaterialNamed:[matDict valueForKey:@"name"] inArray:sorted withKey:@"targetDictionary"];
        
        if(!connector){
            connector = [[[NSMutableDictionary alloc]init]autorelease];
            [connector setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"tags"];
            [connector setValue:[NSNumber numberWithInt:0] forKey:@"strength"];
            [sorted addObject:connector];
        }
        
        [[connector valueForKey:@"tags"]addObject:[connection valueForKey:@"tag"]];
        [connector setValue:[NSNumber numberWithInt:[[connector valueForKey:@"strength"]intValue]+1] forKey:@"strength"];
        [connector setValue:matDict forKey:@"targetDictionary"];
    }
    
    return [sorted autorelease];
}



-(NSMutableDictionary *)dictionaryForMaterialNamed:(NSString *)name inArray:(NSArray *)array withKey:(NSString *)key{
   
    for(NSMutableDictionary * d in array){
        if([[[d valueForKey:key]valueForKey:@"name"] isEqualToString:name])
            return d;
    }
    
    return nil;    
}


-(void)createRawEntryForMaterial:(Material *)m{ // write
    
    NSMutableDictionary * d = [[[NSMutableDictionary alloc]init] autorelease];
    [d setValue:m forKey:@"material"];
    [d setValue:[m name] forKey:@"name"];
    [d setValue:[NSArray arrayWithArray:[m valueForKey:@"tags"]] forKey:@"tags"]; // dictionaries, tags are stored in the "name" field
    
    [(NSMutableArray *)[self valueForKey:@"materialConnections"]addObject:d];

}

-(NSSize)size{return [view bounds].size;}

-(NSPoint)center{return NSMakePoint([self size].width*.5, [self size].height*.5/* -(kNodeSize*.5) */);}

-(IBAction)activeMaterialChanged:(id)sender{

//    NSLog(@"%@", [materialPopUp titleOfSelectedItem]);
    [self setActiveMaterialToMaterialNamed:[materialPopUp titleOfSelectedItem]];
    [view setNeedsDisplay:YES]; 
}

-(void)setActiveMaterialToMaterialNamed:(NSString *)name{

    for(NSDictionary * d in [self valueForKey:@"materialConnections"]){
    
        if([[d valueForKey:@"name"]isEqualToString:name]){
            [self setValue:d forKey:@"activeMaterial"];
            return;
        }
    }
}
@end

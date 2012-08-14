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
    
    [doc setProgressTask:@"computing connections..."];
    [doc setProgress:0];
    [doc displayProgress:YES];

    NSMutableArray * materialConnections = [[[NSMutableArray alloc]init]autorelease];
    [dict setValue:materialConnections forKey:@"materialConnections"];
    
    NSArray * materials = [doc materials];
    
    for(Material * m in materials)
        [self createRawEntryForMaterial:m];
    
    [self renderConnections];
    
    [doc displayProgress:NO];
}

-(void)renderConnections{

    NSMutableArray * materialConnections = (NSMutableArray *)[self valueForKey:@"materialConnections"];

    int i=0;
    float progress=0, matCount = [materialConnections count];
        
    for(NSMutableDictionary * tempCenter in materialConnections){
        
        progress = i/matCount * 100.0;
        NSLog(@"progress: %f", progress);
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
        //NSLog(@"unsorted fresh: %@", [tempCenter valueForKey:@"connections"]);

        [tempCenter setValue:[self sortConnections:[tempCenter valueForKey:@"connections"]] forKey:@"connections"];
        i++;
        //NSLog(@"done: %@", [tempCenter valueForKey:@"name"]);
    }
}

-(NSArray *)sortConnections:(NSArray *)unsorted{

    //NSLog(@"sorting connection array with %lu elements", [unsorted count]);
    NSMutableArray * sorted = [[NSMutableArray alloc]init];
    
    for (NSDictionary * connection in unsorted){
        NSDictionary * matDict = [connection valueForKey:@"materialDictionary"];
        NSMutableDictionary * connector  = [self dictionaryForMaterialNamed:[matDict valueForKey:@"name"] inArray:sorted withKey:@"targetDictionary"];
        
        if(!connector){
            //NSLog(@"searched unsuccessfuly for %@, FRESH ENTRY", [matDict valueForKey:@"name"]);
            connector = [[[NSMutableDictionary alloc]init]autorelease];
            [connector setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"tags"];
            [connector setValue:[NSNumber numberWithInt:0] forKey:@"strength"];
            [sorted addObject:connector];
        }
        //else
        //    NSLog(@"found %@!", [matDict valueForKey:@"name"]);
        
        [[connector valueForKey:@"tags"]addObject:[connection valueForKey:@"tag"]];
        [connector setValue:[NSNumber numberWithInt:[[connector valueForKey:@"strength"]intValue]+1] forKey:@"strength"];
        [connector setValue:matDict forKey:@"targetDictionary"];
    }
    
    //NSLog(@"sorted: %lu entries", [sorted count]);
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

@end

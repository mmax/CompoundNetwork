//
//  NodeNavigation.h
//  CompoundNetwork
//
//  Created by Maximilian Marcoll on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyDocument, Graph, Node, Material;

@interface NodeNavigation : NSObject {

    NSMutableDictionary * dict;
    IBOutlet MyDocument * doc;
    
}

-(void)renderFlatMap;
-(void)createRawEntryForMaterial:(Material *)m;
-(NSArray *)sortConnections:(NSArray *)unsorted;
-(void)renderConnections;

-(NSMutableDictionary *)dictionaryForMaterialNamed:(NSString *)name inArray:(NSArray *)array withKey:(NSString *)key;
//-(BOOL)isMaterialNamed:(NSString *)name inConnectionArray:(NSArray *)array;
-(id)valueForKey:(NSString *)key;
-(void)setValue:(id)v forKey:(NSString *)key;

@end


/* 
 
 ein array für alle materialien
    darin: dictionaries
        felder: name, connectionCount, tags, material (actual object), connections
            connections: ein array mit allen verbindungen
            jede verbindung besteht aus einem dictionary mit dem (navigation)dict des targetMaterials, der stärke der verbindung und dem (den) verbindenen tag(s)

*/
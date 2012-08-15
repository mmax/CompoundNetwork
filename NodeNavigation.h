//
//  NodeNavigation.h
//  CompoundNetwork
//
//  Created by Maximilian Marcoll on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyDocument, Graph, Node, Material, NavigationView;

@interface NodeNavigation : NSObject {

    NSMutableDictionary * dict;
    IBOutlet MyDocument * doc;
    IBOutlet NavigationView * view;
    IBOutlet NSArrayController * navigationMaterialArrayController;
    IBOutlet NSPopUpButton * materialPopUp;
    
}

-(IBAction)activeMaterialChanged:(id)sender;
-(void)setActiveMaterialToMaterialNamed:(NSString *)name;

-(void)renderFlatMap;
-(void)createRawEntryForMaterial:(Material *)m;
-(NSArray *)sortConnections:(NSArray *)unsorted;
-(void)renderConnections;
-(void)renderBrowsePaths;
-(void)createLineInPath:(NSBezierPath *)p fromCenterTo:(NSPoint)target withLineWidth:(float)width;
-(NSBezierPath *)createPolygonAroundCenter:(NSPoint)center withNAngles:(int)n andRadius:(float)r andRotation:(float)rot;
-(NSMutableDictionary *)dictionaryForMaterialNamed:(NSString *)name inArray:(NSArray *)array withKey:(NSString *)key;

-(id)valueForKey:(NSString *)key;
-(void)setValue:(id)v forKey:(NSString *)key;

-(NSSize)size;

-(NSPoint)center;


@end


/* 
 
 ein array für alle materialien
    darin: dictionaries
        felder: name, connectionCount, tags, material (actual object), connections
            connections: ein array mit allen verbindungen
            jede verbindung besteht aus einem dictionary mit dem (navigation)dict des targetMaterials, der stärke der verbindung und dem (den) verbindenen tag(s)

*/
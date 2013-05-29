//
//  NSManagedObject+JSONHelpers.m
//
//  Created by Saul Mora on 6/28/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "CoreData+MagicalRecord.h"
#import <objc/runtime.h>

void MR_swapMethodsFromClass(Class c, SEL orig, SEL new);

NSString * const kMagicalRecordImportCustomDateFormatKey            = @"dateFormat";
NSString * const kMagicalRecordImportDefaultDateFormatString        = @"yyyy-MM-dd'T'HH:mm:ss'Z'";

NSString * const kMagicalRecordImportAttributeKeyMapKey             = @"mappedKeyName";
NSString * const kMagicalRecordImportAttributeValueClassNameKey     = @"attributeValueClassName";

NSString * const kMagicalRecordImportRelationshipMapKey             = @"mappedKeyName";
NSString * const kMagicalRecordImportRelationshipLinkedByKey        = @"relatedByAttribute";
NSString * const kMagicalRecordImportRelationshipTypeKey            = @"type";  //this needs to be revisited

NSString * const kMagicalRecordImportAttributeUseDefaultValueWhenNotPresent = @"useDefaultValueWhenNotPresent";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation NSManagedObject (MagicalRecord_DataImport)

- (BOOL) MR_importValue:(id)value forKey:(NSString *)key
{
    NSString *selectorString = [NSString stringWithFormat:@"import%@:", [key MR_capitalizedFirstCharacterString]];
    SEL selector = NSSelectorFromString(selectorString);
    if ([self respondsToSelector:selector])
    {
        [self performSelector:selector withObject:value];
        return YES;
    }
    return NO;
}

- (void) MR_setAttributes:(NSDictionary *)attributes forKeysWithObject:(id)objectData
{    
    for (NSString *attributeName in attributes) 
    {
        NSAttributeDescription *attributeInfo = [attributes valueForKey:attributeName];
        NSString *lookupKeyPath = [objectData MR_lookupKeyForAttribute:attributeInfo];
        
        if (lookupKeyPath) 
        {
            id value = [attributeInfo MR_valueForKeyPath:lookupKeyPath fromObjectData:objectData];
            if (![self MR_importValue:value forKey:attributeName])
            {
                [self setValue:value forKey:attributeName];
            }
        } 
        else 
        {
            if ([[[attributeInfo userInfo] objectForKey:kMagicalRecordImportAttributeUseDefaultValueWhenNotPresent] boolValue]) 
            {
                id value = [attributeInfo defaultValue];
                if (![self MR_importValue:value forKey:attributeName])
                {
                    [self setValue:value forKey:attributeName];
                }
            }
        }
    }
}

- (NSArray *)MR_findObjectsForRelationship:(NSRelationshipDescription *)relationshipInfo withData:(id)relatedObjectData
{
    NSEntityDescription *destinationEntity = [relationshipInfo destinationEntity];
    Class managedObjectClass = NSClassFromString([destinationEntity managedObjectClassName]);
    NSArray *managedObjects = [managedObjectClass YG_importFromArrayOnCurrentThread:relatedObjectData inContext:self.managedObjectContext primaryKey:[relationshipInfo MR_primaryKey]];
    return managedObjects;
}

- (NSManagedObject *) MR_findObjectForRelationship:(NSRelationshipDescription *)relationshipInfo withData:(id)singleRelatedObjectData
{
    NSEntityDescription *destinationEntity = [relationshipInfo destinationEntity];
    NSManagedObject *objectForRelationship = nil;
    id relatedValue = [singleRelatedObjectData MR_relatedValueForRelationship:relationshipInfo];

    if (relatedValue) 
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        Class managedObjectClass = NSClassFromString([destinationEntity managedObjectClassName]);
        NSString *primaryKey = [relationshipInfo MR_primaryKey];
        objectForRelationship = [managedObjectClass MR_findFirstByAttribute:primaryKey
                                                               withValue:relatedValue
                                                               inContext:context];
    }

    return objectForRelationship;
}

- (void) MR_addObject:(NSManagedObject *)relatedObject forRelationship:(NSRelationshipDescription *)relationshipInfo
{
    NSAssert2(relatedObject != nil, @"Cannot add nil to %@ for attribute %@", NSStringFromClass([self class]), [relationshipInfo name]);
    NSAssert2([relatedObject entity] == [relationshipInfo destinationEntity], @"related object entity %@ not same as destination entity %@", [relatedObject entity], [relationshipInfo destinationEntity]);
    
    //add related object to set
    NSString *addRelationMessageFormat = @"set%@:";
    id relationshipSource = self;
    if ([relationshipInfo isToMany])
    {
        addRelationMessageFormat = @"add%@Object:";
        
        // (AS 5/13)
        /*if ([relationshipInfo respondsToSelector:@selector(isOrdered)] && [relationshipInfo isOrdered])
         {
         //Need to get the ordered set
         NSString *selectorName = [[relationshipInfo name] stringByAppendingString:@"Set"];
         relationshipSource = [self performSelector:NSSelectorFromString(selectorName)];
         addRelationMessageFormat = @"addObject:";
         }*/
    }
    
    NSString *addRelatedObjectToSetMessage = [NSString stringWithFormat:addRelationMessageFormat, attributeNameFromString([relationshipInfo name])];
    
    SEL selector = NSSelectorFromString(addRelatedObjectToSetMessage);
    
    @try
    {
        [relationshipSource performSelector:selector withObject:relatedObject];
    }
    @catch (NSException *exception)
    {
        MRLog(@"Adding object for relationship failed: %@\n", relationshipInfo);
        MRLog(@"relatedObject.entity %@", [relatedObject entity]);
        MRLog(@"relationshipInfo.destinationEntity %@", [relationshipInfo destinationEntity]);
        MRLog(@"Add Relationship Selector: %@", addRelatedObjectToSetMessage);
        MRLog(@"perform selector error: %@", exception);
    }
}

- (void) MR_addObjects:(NSArray *)relatedObjects forRelationship:(NSRelationshipDescription *)relationshipInfo
{
    NSAssert2(relatedObjects != nil, @"Cannot add nil to %@ for attribute %@", NSStringFromClass([self class]), [relationshipInfo name]);
//    NSAssert2([relatedObject entity] == [relationshipInfo destinationEntity], @"related object entity %@ not same as destination entity %@", [relatedObject entity], [relationshipInfo destinationEntity]);
    
    if ([relationshipInfo isToMany])
    {
        MRLog(@"ERROR: relationship is not toMany");
        return;
    }
    
    id set;
    if ([relationshipInfo respondsToSelector:@selector(isOrdered)] && [relationshipInfo isOrdered])
         set = [[NSOrderedSet alloc] initWithArray:relatedObjects];
    else
        set = [[NSSet alloc] initWithArray:relatedObjects];
    
    //add related object to set
    id relationshipSource = self;
    
    NSString *addRelatedObjectToSetMessage = [NSString stringWithFormat:@"add%@:", attributeNameFromString([relationshipInfo name])];
    
    SEL selector = NSSelectorFromString(addRelatedObjectToSetMessage);
    
    @try
    {
        [relationshipSource performSelector:selector withObject:set];
    }
    @catch (NSException *exception)
    {
        MRLog(@"Adding object for relationship failed: %@\n", relationshipInfo);
//        MRLog(@"relatedObject.entity %@", [relatedObject entity]);
        MRLog(@"relationshipInfo.destinationEntity %@", [relationshipInfo destinationEntity]);
        MRLog(@"Add Relationship Selector: %@", addRelatedObjectToSetMessage);
        MRLog(@"perform selector error: %@", exception);
    }
}



- (void) MR_setRelationships:(NSDictionary *)relationships forKeysWithObject:(id)relationshipData withBlock:(void(^)(NSRelationshipDescription *,id))setRelationshipBlock
{
    for (NSString *relationshipName in relationships) 
    {
        if ([self MR_importValue:relationshipData forKey:relationshipName]) 
        {
            continue;
        }
        
        NSRelationshipDescription *relationshipInfo = [relationships valueForKey:relationshipName];
        
        NSString *lookupKey = [[relationshipInfo userInfo] valueForKey:kMagicalRecordImportRelationshipMapKey] ?: relationshipName;
        
#warning AS - added method to lookup key if it is already a string
        id relatedObjectData = ([relationshipData isKindOfClass:[NSString class]]) ? relationshipData :[relationshipData valueForKeyPath:lookupKey];
        
        if (relatedObjectData == nil || [relatedObjectData isEqual:[NSNull null]]) 
        {
            continue;
        }
        
        SEL shouldImportSelector = NSSelectorFromString([NSString stringWithFormat:@"shouldImport%@:", [relationshipName MR_capitalizedFirstCharacterString]]);
        BOOL implementsShouldImport = (BOOL)[self respondsToSelector:shouldImportSelector];
        void (^establishRelationship)(NSRelationshipDescription *, id) = ^(NSRelationshipDescription *blockInfo, id blockData)
        {
            if (!(implementsShouldImport && !(BOOL)[self performSelector:shouldImportSelector withObject:relatedObjectData]))
            {
                setRelationshipBlock(blockInfo, blockData);
            }
        };
        
        // (AS) Changed method for optimization and paging- When object data is an array, we importFromArray
        /*if ([relationshipInfo isToMany])
        {
            for (id singleRelatedObjectData in relatedObjectData) 
            {
                
                establishRelationship(relationshipInfo, singleRelatedObjectData);
            }
        }
        else
        {*/
            establishRelationship(relationshipInfo, relatedObjectData);
//        }
    }
}

- (BOOL) MR_preImport:(id)objectData;
{
    if ([self respondsToSelector:@selector(shouldImport:)])
    {
        BOOL shouldImport = (BOOL)[self performSelector:@selector(shouldImport:) withObject:objectData];
        if (!shouldImport) 
        {
            return NO;
        }
    }   

    if ([self respondsToSelector:@selector(willImport:)])
    {
        [self performSelector:@selector(willImport:) withObject:objectData];
    }
    MR_swapMethodsFromClass([objectData class], @selector(valueForUndefinedKey:), @selector(MR_valueForUndefinedKey:));
    return YES;
}

- (BOOL) MR_postImport:(id)objectData;
{
    MR_swapMethodsFromClass([objectData class], @selector(valueForUndefinedKey:), @selector(MR_valueForUndefinedKey:));
    if ([self respondsToSelector:@selector(didImport:)])
    {
        [self performSelector:@selector(didImport:) withObject:objectData];
    }
    return YES;
}

- (BOOL) MR_performDataImportFromObject:(id)objectData relationshipBlock:(void(^)(NSRelationshipDescription*, id))relationshipBlock;
{
    BOOL didStartimporting = [self MR_preImport:objectData];
    if (!didStartimporting) return NO;
    
    NSDictionary *attributes = [[self entity] attributesByName];
    [self MR_setAttributes:attributes forKeysWithObject:objectData];
    
    NSDictionary *relationships = [[self entity] relationshipsByName];
    [self MR_setRelationships:relationships forKeysWithObject:objectData withBlock:relationshipBlock];
    
    return [self MR_postImport:objectData];  
}

- (BOOL) MR_importValuesForKeysWithObject:(id)objectData
{
    typeof(self) weakself = self;
    return [self MR_performDataImportFromObject:objectData
                              relationshipBlock:^(NSRelationshipDescription *relationshipInfo, id localObjectData) {
                                  if ([relationshipInfo isToMany] && [localObjectData isKindOfClass:[NSArray class]]) {
                                      NSArray *relatedObjects = [weakself MR_relatedObjectsForRelationshipInfo:relationshipInfo withData:localObjectData];
                                      [weakself MR_addObjects:relatedObjects forRelationship:relationshipInfo];
                                  }
                                  else {
                                      NSManagedObject *relatedObject = [weakself MR_relatedObjectForRelationshipInfo:relationshipInfo withData:localObjectData];
                                      [weakself MR_addObject:relatedObject forRelationship:relationshipInfo];
                                  }
    } ];
}

- (NSArray *)MR_relatedObjectsForRelationshipInfo:(NSRelationshipDescription *)relationshipInfo withData:(id)localObjectData
{
    // TODO finish this method
    NSArray *relatedObjects = [self MR_findObjectsForRelationship:relationshipInfo withData:localObjectData];
    return relatedObjects;
}

- (NSManagedObject *)MR_relatedObjectForRelationshipInfo:(NSRelationshipDescription *)relationshipInfo withData:(id)localObjectData
{
    
    NSManagedObject *relatedObject = [self MR_findObjectForRelationship:relationshipInfo withData:localObjectData];
    
    if (relatedObject == nil)
    {
        NSEntityDescription *entityDescription = [relationshipInfo destinationEntity];
        relatedObject = [entityDescription MR_createInstanceInContext:[self managedObjectContext]];
    }
#warning (AS) added this here so newly created objects don't try to import from strings. EX: YGGroup {creatorGuid = XXXY} creates a user, and we try to import values with localObjectData which is: XXXY
    if ([localObjectData isKindOfClass:[NSString class]]) {
        [relatedObject setValue:localObjectData forKey:[relationshipInfo MR_primaryKey] ];
    }
    else if ([localObjectData isKindOfClass:[NSDictionary class]]) {
        [relatedObject MR_importValuesForKeysWithObject:localObjectData];
    }
    return relatedObject;
}

+ (id) MR_importFromObject:(id)objectData inContext:(NSManagedObjectContext *)context;
{
    NSAttributeDescription *primaryAttribute = [[self MR_entityDescription] MR_primaryAttributeToRelateBy];
    
    id value = [objectData MR_valueForAttribute:primaryAttribute];
    
    NSManagedObject *managedObject = [self MR_findFirstByAttribute:[primaryAttribute name] withValue:value inContext:context];
    if (managedObject == nil) 
    {
        managedObject = [self MR_createInContext:context];
    }

    [managedObject MR_importValuesForKeysWithObject:objectData];

    return managedObject;
}

+ (id) MR_importFromObject:(id)objectData
{
    return [self MR_importFromObject:objectData inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray *) MR_importFromArray:(NSArray *)listOfObjectData
{
    return [self MR_importFromArray:listOfObjectData inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray *) MR_importFromArray:(NSArray *)listOfObjectData inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *objectIDs = [NSMutableArray array];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) 
    {    
        [listOfObjectData enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
        {
            NSDictionary *objectData = (NSDictionary *)obj;

            NSManagedObject *dataObject = [self MR_importFromObject:objectData inContext:localContext];

            if ([context obtainPermanentIDsForObjects:[NSArray arrayWithObject:dataObject] error:nil])
            {
              [objectIDs addObject:[dataObject objectID]];
            }
        }];
    }];
    
    return [self MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@", objectIDs] inContext:context];
}

#pragma mark YG added optimization methods

+ (NSDictionary *)YG_createKeysAndObjectDictionaryFromResponseArray:(NSArray *)responseArray primaryKey:(NSString *)key
{
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithCapacity:[responseArray count]];
    for (NSDictionary *dictionary in responseArray)
    {
        if (![dictionary isKindOfClass:[NSDictionary class]]) continue;
        responseDictionary[dictionary[key]] = dictionary;
    }
    return responseDictionary;
}


+ (NSArray *)YG_importFromArrayOnCurrentThread:(NSArray *)listOfObjectData inContext:(NSManagedObjectContext *)context
{
    NSString *primaryKey = [[[self MR_entityDescription] userInfo] valueForKey:kMagicalRecordImportRelationshipLinkedByKey];
    return [self YG_importFromArrayOnCurrentThread:listOfObjectData inContext:context primaryKey:primaryKey];
}

+ (NSArray *)YG_importFromArrayOnCurrentThread:(NSArray *)listOfObjectData inContext:(NSManagedObjectContext *)context primaryKey:(NSString *)primaryKey
{
    NSDictionary *responseMap = [self YG_createKeysAndObjectDictionaryFromResponseArray:listOfObjectData primaryKey:primaryKey];
    
    NSDictionary *objectMap = [self YG_findOrCreateObjectsWithPrimaryKey:primaryKey ids:[[NSSet alloc] initWithArray:[responseMap allKeys]] inContext:context];
    
    [objectMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [obj MR_importValuesForKeysWithObject:responseMap[key]];
    }];
    return [objectMap allValues];
}


//taken from HomeRun

+ (NSMutableDictionary *)YG_findOrCreateObjectsWithPrimaryKey:(NSString *)key ids:(NSSet *)importIdSet inContext:(NSManagedObjectContext *)context
{
    
    if (!context || importIdSet.count == 0) return nil;
    
    NSArray *importIds = [importIdSet sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@", key, importIds];
    
    NSArray *existingObjects = [self MR_findAllSortedBy:key ascending:YES withPredicate:predicate inContext:context];
    
    NSEnumerator *existingEnumerator = [existingObjects objectEnumerator];
    NSManagedObject *existingObject = [existingEnumerator nextObject];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:importIds.count];
    for (NSString *importId in importIds) {
        if (![[existingObject valueForKey:key] isEqualToString:importId]) {
            id newObject = [self MR_createInContext:context];
            [newObject setValue:importId forKey:key];
            [result setObject:newObject forKey:importId];
        } else {
            [result setObject:existingObject forKey:importId];
            existingObject = [existingEnumerator nextObject];
        }
    }
    
    return result;
}

+ (NSManagedObject *)YG_findOrCreateObjectWithPrimaryKey:(NSString *)key id:(NSString *)importedId inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, importedId];
    
    NSManagedObject *existingObject = [self MR_findFirstWithPredicate:predicate inContext:context];
    if (!existingObject) {
        existingObject = [self MR_createInContext:context];
        [existingObject setValue:importedId forKey:key];
    }
    return existingObject;
}


+ (NSMutableDictionary *)YG_findObjectsWithId:(NSString *)key ids:(NSSet *)findSet inContext:(NSManagedObjectContext *)context
{
    if (!context) return nil;
    
    NSArray *findIds = [findSet allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@", key, findIds];
    
    NSArray *existingObjects = [self MR_findAllWithPredicate:predicate inContext:context];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:findSet.count];
    for (id existingObject in existingObjects) {
        NSString *existingKey = [existingObject valueForKey:key];
        result[existingKey] = existingObject;
    }
    
    return result;
}



@end

#pragma clang diagnostic pop

void MR_swapMethodsFromClass(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

//
//  NSAttributeDescription+MagicalDataImport.m
//  Magical Record
//
//  Created by Saul Mora on 9/4/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "NSAttributeDescription+MagicalDataImport.h"
#import "NSManagedObject+MagicalDataImport.h"
#import "MagicalImportFunctions.h"

@implementation NSAttributeDescription (MagicalRecord_DataImport)

- (NSString *) MR_primaryKey;
{
    return nil;
}

- (id) MR_valueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;
{
    id value = [objectData valueForKeyPath:keyPath];
    
    NSAttributeType attributeType = [self attributeType];
    NSString *desiredAttributeType = [[self userInfo] valueForKey:kMagicalRecordImportAttributeValueClassNameKey];
    if (desiredAttributeType) 
    {
        if ([desiredAttributeType hasSuffix:@"Color"])
        {
            value = colorFromString(value);
        }
    }
    else 
    {
        if (attributeType == NSDateAttributeType && [value isKindOfClass:[NSNumber class]])
            value = [NSDate dateWithTimeIntervalSince1970:[value intValue]];
    }
    
    return value == [NSNull null] ? nil : value;   
}

@end

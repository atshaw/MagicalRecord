//
//  NSString+MagicalRecord_MagicalDataImport.h
//  Magical Record
//
//  Created by Saul Mora on 12/10/11.
//  Copyright (c) 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MagicalRecord_DataImport)

- (NSString *) MR_capitalizedFirstCharacterString;
- (id) MR_valueForAttribute:(NSAttributeDescription *)attributeInfo;
- (NSString *) MR_lookupKeyForAttribute:(NSAttributeDescription *)attributeInfo;
- (id) MR_relatedValueForRelationship:(NSRelationshipDescription *)relationshipInfo;

@end

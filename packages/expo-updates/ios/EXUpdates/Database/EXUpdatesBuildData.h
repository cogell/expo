//  Copyright © 2021 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesDatabase.h>
#import <EXUpdates/EXUpdatesConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXUpdatesBuildData : NSObject

+ (BOOL)isBuildDataConsistent:(NSDictionary *)staticBuildData config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
+ (void)ensureBuildDataIsConsistent:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
+ (nullable NSDictionary *)getBuildData:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey error:(NSError ** _Nullable)error;
+ (void)setBuildData:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
+ (void)clearAllUpdates:(EXUpdatesConfig *)config database:(EXUpdatesDatabase *)database;

@end

NS_ASSUME_NONNULL_END

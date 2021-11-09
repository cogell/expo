//  Copyright © 2021 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesDatabase.h>
#import <EXUpdates/EXUpdatesConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXUpdatesBuildData : NSObject

+ (void)ensureBuildDataIsConsistent:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey config:(EXUpdatesConfig *)config error:(NSError ** _Nullable)error;
+ (nullable NSDictionary *)getBuildDataFromDatabase:(EXUpdatesDatabase *)database scopeKey:(NSString *)scopeKey error:(NSError ** _Nullable)error;
+ (nullable NSDictionary *)getBuildDataFromConfig:(EXUpdatesConfig *)config;
+ (void)setBuildDataInDatabase:(EXUpdatesDatabase *)database config:(EXUpdatesConfig *)config;
+ (void)clearAllUpdates:(EXUpdatesConfig *)config database:(EXUpdatesDatabase *)database;

@end

NS_ASSUME_NONNULL_END

#import "MapsAppDelegate.h"
#import "MWMSettings.h"

#include "platform/platform.hpp"

typedef void (^FolderDeletionCallback)(BOOL success, NSError * _Nullable error);

void DeleteFolderInDocumentsDirectory(NSString *folderName, FolderDeletionCallback callback) {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *documentsURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
  NSURL *targetFolderURL = [documentsURL URLByAppendingPathComponent:folderName];

  if ([fileManager fileExistsAtPath:targetFolderURL.path]) {
    NSError *error = nil;
    BOOL success = [fileManager removeItemAtURL:targetFolderURL error:&error];
    if (callback) {
      callback(success, error);
    }
  } else {
    if (callback) {
      callback(NO, [NSError errorWithDomain:@"AppFolderDomain"
                                       code:404
                                   userInfo:@{NSLocalizedDescriptionKey : @"Folder does not exist"}]);
    }
  }
}

int main(int argc, char * argv[])
{
  DeleteFolderInDocumentsDirectory(@"190910", ^(BOOL success, NSError * _Nullable error) {
    if (success) {
      NSLog(@"✅ Successfully deleted folder.");
    } else {
      NSLog(@"❌ Failed to delete folder: %@", error.localizedDescription);
    }
  });
  
  [MWMSettings initializeLogging];

  NSBundle * mainBundle = [NSBundle mainBundle];
  NSString * appName = [mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
  NSString * bundleId = mainBundle.bundleIdentifier;
  auto & p = GetPlatform();
  LOG(LINFO, (appName.UTF8String, bundleId.UTF8String, p.Version(), "started, detected CPU cores:", p.CpuCores()));

  int retVal;
  @autoreleasepool
  {
    retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([MapsAppDelegate class]));
  }
  return retVal;
}

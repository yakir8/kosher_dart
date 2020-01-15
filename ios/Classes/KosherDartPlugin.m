#import "KosherDartPlugin.h"
#if __has_include(<kosher_dart/kosher_dart-Swift.h>)
#import <kosher_dart/kosher_dart-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "kosher_dart-Swift.h"
#endif

@implementation KosherDartPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKosherDartPlugin registerWithRegistrar:registrar];
}
@end

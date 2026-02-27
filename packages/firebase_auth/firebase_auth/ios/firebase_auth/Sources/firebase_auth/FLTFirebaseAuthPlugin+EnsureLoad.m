#import "include/Public/FLTFirebaseAuthPlugin.h"

// This file ensures the FLTFirebaseAuthPlugin Objective-C class symbol is
// referenced/retained in iOS builds so that GeneratedPluginRegistrant can
// link against it. Some packaging or build configurations can omit the
// class symbol from the final binary; referencing the class from a
// constructor function prevents that trimming.

__attribute__((constructor))
static void FLTFirebaseAuthPlugin_ensure_symbol_exists(void) {
  // Reference the class to force the linker to keep it.
  (void)[FLTFirebaseAuthPlugin class];
}

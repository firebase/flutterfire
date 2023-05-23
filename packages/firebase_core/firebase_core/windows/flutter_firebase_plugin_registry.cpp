#include "flutter_firebase_plugin_registry.h"
#include <exception>
#include "firebase/app.h"
#include <any>
#include "firebase/util.h"

std::unordered_map<std::string, FlutterFirebasePlugin*>
    FlutterFirebasePluginRegistry::registeredPlugins;

void FlutterFirebasePluginRegistry::registerPlugin(
    std::string channelName, FlutterFirebasePlugin* flutterFirebasePlugin) {
  registeredPlugins[channelName] = flutterFirebasePlugin;
}

static bool quit = false;

bool ProcessEvents(int msec) {
#ifdef _WIN32
  Sleep(msec);
#else
  usleep(msec * 1000);
#endif  // _WIN32
  return quit;
}


static bool WaitForFuture(const firebase::FutureBase& future) {
  // Note if the future has not be started properly.
  if (future.status() == ::firebase::kFutureStatusInvalid) {
    return false;
  }


     while (future.status() == ::firebase::kFutureStatusPending) {
      if (ProcessEvents(100)) return true;
    }

     return false;
  }


std::map<std::string, std::any>
FlutterFirebasePluginRegistry::getPluginConstantsForFirebaseApp(
    firebase::App firebaseApp) {
    std::map<std::string, std::any> pluginConstants;

    try {
      for (const auto& entry : registeredPlugins) {
        std::string channelName = entry.first;
        FlutterFirebasePlugin* plugin = entry.second;

        firebase::Future future =
            plugin->getPluginConstantsForFirebaseApp(firebaseApp);
        WaitForFuture(future);
        pluginConstants[channelName] = future.result();
      }
    } catch (std::exception& e) {
      throw;
    }

    return pluginConstants;
}


firebase::Future<void>
FlutterFirebasePluginRegistry::didReinitializeFirebaseCore() {
    try {
      for (const auto& entry : registeredPlugins) {
        FlutterFirebasePlugin* plugin = entry.second;
        WaitForFuture(plugin->didReinitializeFirebaseCore());
      }
    } catch (std::exception& e) {
      throw;
    }

    return firebase::Future<void>();
}

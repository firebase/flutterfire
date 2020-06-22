# Firebase Machine Learning
  
New Firebase ML plugin will support cloud apis for custom models.  
Currently under development.  
  
## Usage of classes:  
### FirebaseRemoteModel
FirebaseRemoteModel cannot be constructed on its own. Construct FirebaseCustomRemoteModel, which is an extension of FirebaseRemoteModel.
```
FirebaseCustomRemoteModel remoteModel = FirebaseCustomRemoteModel('myModelName');
print(remoteModel.modelName);
```
### FirebaseModelDownloadConditions
Parameters requireCharging, requireDeviceIdle and requireWifi are optional and default to false.
```
FirebaseModelDownloadConditions conditions = FirebaseModelDownloadConditions(requireCharging: true);
print(conditions.requireCharging);
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

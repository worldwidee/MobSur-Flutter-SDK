# MobSur Flutter SDK
More information on https://mobsur.com

## Usage

1. Add this package as a dependency in the `pubspec.yaml` file:
```
  dependencies:
    mobsur_flutter_sdk: ^1.0.4
```
  
>Then run `flutter pub get`  
  
2. Import it in your project:
```
import 'package:mobsur_flutter_sdk/mobsur_flutter_sdk.dart';
```

3. Call the setup method:
```
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // You can call this method somewhere else in the app instead,
  // but it should not be right before an event, that should trigger a survey
  MobSurSDK().setup('YOUR-APP-ID', 'user-id');
  
  runApp(const MyApp());
}
```

4. Call the event method, passing the build context.
```
MobSurSDK().logEvent('event-name-here', context);
```

5. If you do not know the client id during the setup, you can pass it later. The client id can't be an empty string.
```
  MobSurSDK().updateClientId('client-id-here');
```

## Sample project

A complete project with the SDK can be found in our [GitHub repository](https://github.com/eden-tech-labs/MobSur-Flutter-App).

### Important!!!
For the Android platform, we have minimum SDK version requirements.  
If you need to use the app on lower version than 32, please contact us.

```
// android/app/build.gradle:
...
android {
  compileSdkVersion 32 // or higher
  ...

  defaultConfig {
    ...
    minSdkVersion 32 // or higher
    ...
  }
}

```

### Recommendation 
Call the event method in a wrapper class that manages your events.
If you already have events in the app, it's a good idea to call the method for all the events and then, the correct one will be selected in the dashboard.

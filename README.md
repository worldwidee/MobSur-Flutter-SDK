# MobSur Flutter SDK
More information on https://mobsur.com

## Usage

1. Add this package as dependency in `pubspec.yml`
```
  dependencies:
    mobsur_flutter_sdk: ^1.0.0
```
  
>Then run `flutter pub get`  
  
2. Import it in your project
```
import 'package:mobsur_flutter_sdk/mobsur_flutter_sdk.dart';
```

3. Call the setup method.
```
void main() {
  WidgetsFlutterBinding.ensureInitialized()

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

5. If you do not know the client id during the setup, you can pass it later. The client id can't be empty string.
```
  MobSurSDK().updateClientId('client-id-here');
```

### Recommendation 
Call the event method in a wrapper class that manages your events.
If you already have events in the app, it's a good idea to call the method for all the events and then, the correct one will be selected in the dashboard.

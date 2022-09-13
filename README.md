# MobSur Flutter SDK
More information on https://mobsur.com

## Usage

1. Add this package as dependency in `pubspec.yml`
2. Import it in your project
```
import 'package:mobsur_flutter_sdk/mobsur_flutter_sdk.dart';
```

3. Call the setup method.
```
  MobSurSDK().setup('your-app-id-here', 'client-id-here');
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

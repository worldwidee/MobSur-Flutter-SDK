import 'package:flutter_test/flutter_test.dart';

import 'package:mobsur_flutter_sdk/mobsur_flutter_sdk.dart';

void main() {
  test('Test getting survey data', () {
    MobSurSDK().setup('fae2cee4-e185-4762-baf9-f62c82ddc979', '1234');

    expectAsyncUntil0(() { 
      return MobSurSDK().availableSurveys(); 
    }, (){
      return MobSurSDK().availableSurveys()?.isNotEmpty ?? false;
    });
  });
}

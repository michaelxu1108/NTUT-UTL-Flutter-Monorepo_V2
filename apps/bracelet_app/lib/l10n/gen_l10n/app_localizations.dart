import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'UTL Amulet App'**
  String get appName;

  /// No description provided for @downloadFileFinishedNotification.
  ///
  /// In en, this message translates to:
  /// **'Download {format} file finished.'**
  String downloadFileFinishedNotification(Object format);

  /// No description provided for @connectBluetoothButtonText.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectBluetoothButtonText;

  /// No description provided for @disconnectBluetoothButtonText.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectBluetoothButtonText;

  /// No description provided for @tabBluetoothScanner.
  ///
  /// In en, this message translates to:
  /// **'BT Scan'**
  String get tabBluetoothScanner;

  /// No description provided for @tabDataList.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get tabDataList;

  /// No description provided for @tabControlPanel.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get tabControlPanel;

  /// No description provided for @dataRecording.
  ///
  /// In en, this message translates to:
  /// **'Data Recording'**
  String get dataRecording;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// No description provided for @stopAndExportCSV.
  ///
  /// In en, this message translates to:
  /// **'Stop & Export CSV'**
  String get stopAndExportCSV;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @stopRecordingHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: CSV will auto-export after stopping'**
  String get stopRecordingHint;

  /// No description provided for @bluetoothCommand.
  ///
  /// In en, this message translates to:
  /// **'BT Command'**
  String get bluetoothCommand;

  /// No description provided for @enterCommand.
  ///
  /// In en, this message translates to:
  /// **'Enter command...'**
  String get enterCommand;

  /// No description provided for @sendCommand.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendCommand;

  /// No description provided for @pleaseEnterCommand.
  ///
  /// In en, this message translates to:
  /// **'Please enter command'**
  String get pleaseEnterCommand;

  /// No description provided for @commandSent.
  ///
  /// In en, this message translates to:
  /// **'Command sent: 0x{command}'**
  String commandSent(String command);

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed'**
  String get sendFailed;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(String error);

  /// No description provided for @lastCommandSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last: 0x{command} (OK)'**
  String lastCommandSuccess(String command);

  /// No description provided for @lastCommandFailed.
  ///
  /// In en, this message translates to:
  /// **'Last: 0x{command} (Failed)'**
  String lastCommandFailed(String command);

  /// No description provided for @commandDescription.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get commandDescription;

  /// No description provided for @commandExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 70D612D90003C5'**
  String get commandExample;

  /// No description provided for @commandBLEMode.
  ///
  /// In en, this message translates to:
  /// **'BLE Mode'**
  String get commandBLEMode;

  /// No description provided for @commandSetParam.
  ///
  /// In en, this message translates to:
  /// **'Set Param'**
  String get commandSetParam;

  /// No description provided for @commandCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate'**
  String get commandCalibrate;

  /// No description provided for @commandMagnetometer.
  ///
  /// In en, this message translates to:
  /// **'Magnetometer'**
  String get commandMagnetometer;

  /// No description provided for @commandLowHeadMode.
  ///
  /// In en, this message translates to:
  /// **'Low Head Mode'**
  String get commandLowHeadMode;

  /// No description provided for @commandBreathMode.
  ///
  /// In en, this message translates to:
  /// **'Breath Mode'**
  String get commandBreathMode;

  /// No description provided for @commandBindBand.
  ///
  /// In en, this message translates to:
  /// **'Bind Band'**
  String get commandBindBand;

  /// No description provided for @commandUnbindBand.
  ///
  /// In en, this message translates to:
  /// **'Unbind Band'**
  String get commandUnbindBand;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'id'**
  String get id;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'device ID'**
  String get deviceId;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get time;

  /// No description provided for @accX.
  ///
  /// In en, this message translates to:
  /// **'accX'**
  String get accX;

  /// No description provided for @accY.
  ///
  /// In en, this message translates to:
  /// **'accY'**
  String get accY;

  /// No description provided for @accZ.
  ///
  /// In en, this message translates to:
  /// **'accZ'**
  String get accZ;

  /// No description provided for @accTotal.
  ///
  /// In en, this message translates to:
  /// **'accTotal'**
  String get accTotal;

  /// No description provided for @gyroX.
  ///
  /// In en, this message translates to:
  /// **'gyroX'**
  String get gyroX;

  /// No description provided for @gyroY.
  ///
  /// In en, this message translates to:
  /// **'gyroY'**
  String get gyroY;

  /// No description provided for @gyroZ.
  ///
  /// In en, this message translates to:
  /// **'gyroZ'**
  String get gyroZ;

  /// No description provided for @gyroTotal.
  ///
  /// In en, this message translates to:
  /// **'gyroTotal'**
  String get gyroTotal;

  /// No description provided for @magX.
  ///
  /// In en, this message translates to:
  /// **'magX'**
  String get magX;

  /// No description provided for @magY.
  ///
  /// In en, this message translates to:
  /// **'magY'**
  String get magY;

  /// No description provided for @magZ.
  ///
  /// In en, this message translates to:
  /// **'magZ'**
  String get magZ;

  /// No description provided for @magTotal.
  ///
  /// In en, this message translates to:
  /// **'magTotal'**
  String get magTotal;

  /// No description provided for @pitch.
  ///
  /// In en, this message translates to:
  /// **'pitch'**
  String get pitch;

  /// No description provided for @roll.
  ///
  /// In en, this message translates to:
  /// **'roll'**
  String get roll;

  /// No description provided for @yaw.
  ///
  /// In en, this message translates to:
  /// **'yaw'**
  String get yaw;

  /// No description provided for @gValue.
  ///
  /// In en, this message translates to:
  /// **'gValue'**
  String get gValue;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'altitude'**
  String get pressure;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'temperature'**
  String get temperature;

  /// No description provided for @posture.
  ///
  /// In en, this message translates to:
  /// **'posture'**
  String get posture;

  /// No description provided for @beaconRssi.
  ///
  /// In en, this message translates to:
  /// **'beacon RSSI'**
  String get beaconRssi;

  /// No description provided for @adc.
  ///
  /// In en, this message translates to:
  /// **'adc'**
  String get adc;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'battery'**
  String get battery;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'area'**
  String get area;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'step'**
  String get step;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'direction'**
  String get direction;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'point'**
  String get point;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

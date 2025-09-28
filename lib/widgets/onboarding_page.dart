build-apk
failed 2 minutes ago in 7m 10s
Search logs
3s
1s
0s
33s
15s
15s
16s
5m 42s
Run flutter build apk --release
Running Gradle task 'assembleRelease'...                        
Checking the license for package Android SDK Build-Tools 30.0.3 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Build-Tools 30.0.3 accepted.
Preparing "Install Android SDK Build-Tools 30.0.3 (revision: 30.0.3)".
"Install Android SDK Build-Tools 30.0.3 (revision: 30.0.3)" ready.
Installing Android SDK Build-Tools 30.0.3 in /usr/local/lib/android/sdk/build-tools/30.0.3
"Install Android SDK Build-Tools 30.0.3 (revision: 30.0.3)" complete.
"Install Android SDK Build-Tools 30.0.3 (revision: 30.0.3)" finished.
Checking the license for package Android SDK Platform 33 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Platform 33 accepted.
Preparing "Install Android SDK Platform 33 (revision: 3)".
"Install Android SDK Platform 33 (revision: 3)" ready.
Installing Android SDK Platform 33 in /usr/local/lib/android/sdk/platforms/android-33
"Install Android SDK Platform 33 (revision: 3)" complete.
"Install Android SDK Platform 33 (revision: 3)" finished.
Checking the license for package Android SDK Platform 31 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Platform 31 accepted.
Preparing "Install Android SDK Platform 31 (revision: 1)".
"Install Android SDK Platform 31 (revision: 1)" ready.
Installing Android SDK Platform 31 in /usr/local/lib/android/sdk/platforms/android-31
"Install Android SDK Platform 31 (revision: 1)" complete.
"Install Android SDK Platform 31 (revision: 1)" finished.
Note: /home/runner/.pub-cache/hosted/pub.dev/cloud_firestore-4.15.8/android/src/main/java/io/flutter/plugins/firebase/firestore/FlutterFirebaseFirestorePlugin.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
lib/widgets/onboarding_page.dart:4:8: Error: Error when reading 'lib/widgets/onboarding_screen.dart': No such file or directory
import 'onboarding_screen.dart';
       ^
lib/models/user_model.dart:4:6: Error: Error when reading 'lib/models/user_model.g.dart': No such file or directory
part 'user_model.g.dart';
     ^
lib/models/conversion_model.dart:3:6: Error: Error when reading 'lib/models/conversion_model.g.dart': No such file or directory
part 'conversion_model.g.dart';
     ^
lib/models/user_model.dart:4:6: Error: Can't use 'lib/models/user_model.g.dart' as a part, because it has no 'part of' declaration.
part 'user_model.g.dart';
     ^
lib/models/conversion_model.dart:3:6: Error: Can't use 'lib/models/conversion_model.g.dart' as a part, because it has no 'part of' declaration.
part 'conversion_model.g.dart';
     ^
../../../.pub-cache/hosted/pub.dev/google_fonts-6.2.0/lib/src/google_fonts_base.dart:69:8: Error: Type 'FontFeature' not found.
  List<FontFeature>? fontFeatures,
       ^^^^^^^^^^^
lib/widgets/onboarding_page.dart:7:9: Error: Type 'OnboardingData' not found.
  final OnboardingData data;
        ^^^^^^^^^^^^^^
lib/screens/profile_screen.dart:208:28: Error: The getter 'context' isn't defined for the class 'ProfileScreen'.
 - 'ProfileScreen' is from 'package:heic_converter_pro/screens/profile_screen.dart' ('lib/screens/profile_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'context'.
    final theme = Theme.of(context);
                           ^^^^^^^
../../../.pub-cache/hosted/pub.dev/google_fonts-6.2.0/lib/src/google_fonts_base.dart:69:8: Error: 'FontFeature' isn't a type.
  List<FontFeature>? fontFeatures,
       ^^^^^^^^^^^
lib/widgets/onboarding_page.dart:7:9: Error: 'OnboardingData' isn't a type.
  final OnboardingData data;
        ^^^^^^^^^^^^^^
lib/models/user_model.dart:30:60: Error: Method not found: '_$UserModelFromJson'.
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
                                                           ^^^^^^^^^^^^^^^^^^^
lib/models/user_model.dart:31:36: Error: The method '_$UserModelToJson' isn't defined for the class 'UserModel'.
 - 'UserModel' is from 'package:heic_converter_pro/models/user_model.dart' ('lib/models/user_model.dart').
Try correcting the name to the name of an existing method, or defining a method named '_$UserModelToJson'.
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
                                   ^^^^^^^^^^^^^^^^^
lib/models/conversion_model.dart:35:66: Error: Method not found: '_$ConversionModelFromJson'.
  factory ConversionModel.fromJson(Map<String, dynamic> json) => _$ConversionModelFromJson(json);
                                                                 ^^^^^^^^^^^^^^^^^^^^^^^^^
lib/models/conversion_model.dart:36:36: Error: The method '_$ConversionModelToJson' isn't defined for the class 'ConversionModel'.
 - 'ConversionModel' is from 'package:heic_converter_pro/models/conversion_model.dart' ('lib/models/conversion_model.dart').
Try correcting the name to the name of an existing method, or defining a method named '_$ConversionModelToJson'.
  Map<String, dynamic> toJson() => _$ConversionModelToJson(this);
                                   ^^^^^^^^^^^^^^^^^^^^^^^
Target kernel_snapshot failed: Exception
FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.16.0-x64/bin/flutter'' finished with non-zero exit value 1
* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
* Get more help at https://help.gradle.org
BUILD FAILED in 5m 41s
Running Gradle task 'assembleRelease'...                          341.8s
Gradle task assembleRelease failed with exit code 1
Error: Process completed with exit code 1.
0s
0s
0s
Post job cleanup.
0s
Post job cleanup.
0s
Post job cleanup.
/usr/bin/git version
git version 2.51.0
Temporarily overriding HOME='/home/runner/work/_temp/13f6d6df-22c4-48df-a15d-2eb715260be5' before making global git config changes
Adding repository directory to the temporary git global config as a safe directory
/usr/bin/git config --global --add safe.directory /home/runner/work/heic-converter-pro1/heic-converter-pro1
/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
http.https://github.com/.extraheader
/usr/bin/git config --local --unset-all http.https://github.com/.extraheader
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"

#!/usr/bin/env bash
set -u
mkdir -p android-test-logs
adb -s emulator-5554 logcat -c
set +e
flutter test integration_test/study_flow_test.dart -d emulator-5554 --verbose > android-test-logs/flutter.log 2>&1
result=$?
adb -s emulator-5554 logcat -d -v threadtime > android-test-logs/logcat.log 2>&1
cat android-test-logs/flutter.log
exit "$result"

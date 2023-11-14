Project: /docs/test-lab/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{% include "_shared/apis/console/_local_variables.html" %}
{% include "_local_variables.html" %}
{% include "docs/test-lab/_local_variables.html" %}
{% include "docs/ios/_local_variables.html" %}
{% include "_shared/firebase/_snippet_include_comment.html" %}

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />


# Integration Testing with Flutter

To test Flutter apps with {{firebase_testlab}}, you can write Flutter
integration tests, build Android APKs or iOS test zip files, and run as
regular Android instrumentation tests or iOS XCTests.


# Flutter integration test types {: #test-types}

Flutter supports three types of tests: unit tests, widget tests, and
integration tests. A *unit test* verifies the behavior of a method or class.
A *widget test* verifies the behavior of Flutter widgets without running the
app itself. An *integration test*, also called end-to-end testing or GUI
testing, runs the full app.

To learn more about integration tests, see [Flutter integration testing](https://docs.flutter.dev/testing/integration-tests){:.external}.


# Write Flutter integration tests {: #write-flutter-integration-tests}

To learn how to write integration tests, see the [project setup](https://docs.flutter.dev/testing/integration-tests#project-setup){:.external}
section of the Flutter integration tests documentation. Optionally, you can
follow [running using Flutter command](https://docs.flutter.dev/testing/integration-tests#running-using-the-flutter-command){:.external}
to run and verify the tests locally.


# Test on {{testlab}} {: #test-on-test-lab}

You can use {{testlab}} with both Android and iOS targets.


## Android setup {: #android-setup}

Follow the instructions in the
[Android Device Testing](https://github.com/flutter/flutter/tree/main/packages/integration_test#android-device-testing){:.external}
section of the README.


## iOS setup {: #ios-setup}

Follow the instructions in the
[iOS Device Testing](https://github.com/flutter/flutter/tree/main/packages/integration_test#ios-device-testing){:.external}
section of the README.

## Robo test support {: #robo-test-support}

[Robo tests](/docs/test-lab/android/robo-ux-test) do not natively support
Flutter. To improve crawling of your app, use [Robo scripts](/docs/test-lab/android/run-robo-scripts),
which are tests that automate manual QA tasks for mobile apps, and enable
continuous integration (CI) and pre-launch testing strategies.
For example, to control Robo behavior in a more precise and robust way, you can
use clicks with [visionText](/docs/test-lab/android/robo-scripts-reference#click).


# Analyze test results {: #analyze-test-results}

You can run Flutter integration tests as an Android instrumentation test or an
iOS XCTest. To analyze the result of an integration test, see the
documentation for [Android](https://firebase.google.com/docs/test-lab/android/analyzing-results){:.external}
and [iOS](https://firebase.google.com/docs/test-lab/ios/analyzing-results){:.external},
depending on your platform.


## Limitations {: #limitations}

Test timing information for individual test cases is not available, which means
that features like test case duration and videos for individual test cases
don't work as expected.

## Troubleshooting {: #troubleshooting}

If you encounter issues, check the [public issue tracker for integration tests](https://github.com/flutter/flutter/issues?q=is%3Aopen+is%3Aissue+label%3Aintegration_test){:.external}.

If you encounter a new issue caused by the integration test framework,
file a new issue in the public issue tracker following the guidance in
[Creating useful bug reports](https://docs.flutter.dev/resources/bug-reports){:.external}.

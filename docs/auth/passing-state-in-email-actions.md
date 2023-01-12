Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Passing State in Email Actions

You can pass state via a continue URL when sending email actions for password
resets or verifying a user's email. This provides the user the ability to be
returned to the app after the action is completed. In addition, you can specify
whether to handle the email action link directly from a mobile application when
it is installed instead of a web page.

This can be extremely useful in the following common scenarios:

* A user, not currently logged in, may be trying to access content that
  requires the user to be signed in. However, the user might have forgotten
  their password and therefore trigger the reset password flow. At the end of
  the flow, the user expects to go back to the section of the app they were
  trying to access.

* An application may only offer access to verified accounts. For
  example, a newsletter app may require the user to verify their email before
  subscribing. The user would go through the email verification flow and expect
  to be returned to the app to complete their subscription.

* In general, when a user begins a password reset or email verification flow on
  an Apple app they expect to complete the flow within the app; the ability to
  pass state via continue URL makes this possible.

Having the ability to pass state via a continue URL is a powerful feature that
Firebase Auth provides and which can significantly enhance the user experience.


## Passing state/continue URL in email actions

In order to securely pass a continue URL, the domain for the URL will need to
be allowlisted in the Firebase console.
This is done in the <b>Authentication</b> section by adding this domain to the
list of <b>Authorized domains</b> under the <b>Sign-in method</b> tab if it is not already there.

An `ActionCodeSettings` instance needs to be provided when sending
a password reset email or a verification email. This interface takes the
following parameters:

<table>
  <tr>
    <th>Parameter</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>url</code></td>
    <td>String</td>
    <td><p>Sets the link (state/continue URL) which has different meanings
      in different contexts:</p>
      <ul>
        <li>When the link is handled in the web action widgets, this is the deep
          link in the <code>continueUrl</code> query parameter.</li>
        <li>When the link is handled in the app directly, this is the
          <code>continueUrl</code> query parameter in the deep link of the
          Dynamic Link.</li>
      </ul></td>
  </tr>
  <tr>
    <td><code>iOSBundleId</code></td>
    <td>String</td>
    <td>Sets the bundle ID. This will try to open the link in an Apple app if
      it is installed. The app needs to be registered in the Console. If no
      Bundle ID is provided, the value of this field is set to the bundle ID of
      the App's main bundle.</td>
  </tr>
  <tr>
    <td><code>androidPackageName</code></td>
    <td>String</td>
    <td>Sets the Android package name. This will try to open the link in an
      android app if it is installed.</td>
  </tr>
   <tr>
    <td><code>androidInstallApp</code></td>
    <td>bool</td>
    <td>Specifies whether to install the Android app if the device supports it
      and the app is not already installed. If this field is provided without a
      packageName, an error is thrown explaining that the packageName must be
      provided in conjunction with this field.</td>
  </tr>
  <tr>
    <td><code>androidMinimumVersion</code></td>
    <td>String</td>
    <td>The minimum version of the app that is supported in this flow. If
      minimumVersion is specified, and an older version of the app is installed,
      the user is taken to the Play Store to upgrade the app. The Android app
      needs to be registered in the Console.</td>
  </tr>
  <tr>
    <td><code>handleCodeInApp</code></td>
    <td>bool</td>
    <td>Whether the email action link will be opened in a mobile app or a web
      link first. The default is false. When set to true, the action code link
      will be be sent as a Universal Link or Android App Link and will be opened
      by the app if installed. In the false case, the code will be sent to the
      web widget first and then on continue will redirect to the app if
      installed.</td>
  </tr>
  <tr>
    <td><code>dynamicLinkDomain</code></td>
    <td>String</td>
    <td>Sets the dynamic link domain (or subdomain) to use for the current link
      if it is to be opened using Firebase Dynamic Links. As multiple dynamic
      link domains can be configured per project, this field provides the
      ability to explicitly choose one. If none is provided, the first domain
      is used by default.</td>
  </tr>
</table>

The following example illustrates how to send an email verification link that
will open in a mobile app first as a Firebase Dynamic Link using the custom
dynamic link domain `example.page.link`
(iOS app `com.example.ios` or Android app `com.example.android` where the app
will install if not already installed and the minimum version is `12`). The
deep link will contain the continue URL payload
`https://www.example.com/?email=user@example.com`.

```dart
final user = FirebaseAuth.instance.currentUser;

final actionCodeSettings = ActionCodeSettings(
  url: "http://www.example.com/verify?email=${user?.email}",
  iOSBundleId: "com.example.ios",
  androidPackageName: "com.example.android",
);

await user?.sendEmailVerification(actionCodeSettings);
```

## Configuring Firebase Dynamic Links

Firebase Auth uses [Firebase Dynamic Links](/docs/dynamic-links/) when sending a
link that is meant to be opened in a mobile application. In order to use this
feature, Dynamic Links need to be configured in the Firebase Console.

1.  Enable Firebase Dynamic Links:

    1.  In the Firebase console, open the <b>Dynamic Links</b> section.

    1.  If you have not yet accepted the Dynamic Links terms and created a Dynamic Links
        domain, do so now.

    1.  If you already created a Dynamic Links domain, take note of it. A Dynamic Links
        domain typically looks like the following example: <pre>example.page.link</pre>

    1.  You will need this value when you configure your Apple or Android app to
        intercept the incoming link.

1.  Configuring Android applications:
    1.  If you plan on handling these links from your Android application, the
        Android package name needs to be specified in the Firebase Console
        project settings. In addition, the SHA-1 and SHA-256 of the application
        certificate need to be provided.
    1.  You will also need to configure the intent filter for the deep link in
        you AndroidManifest.xml file.
    1.  For more on this, refer to
        [Receiving Android Dynamic Links instructions](/docs/dynamic-links/android/receive).

1.  Configuring Apple applications:
    1.  If you plan on handling these links from your application, the
        bundle ID needs to be specified in the Firebase Console
        project settings. In addition, the App Store ID and the Apple Developer
        Team ID also need to be specified.
    1.  You will also need to configure the FDL universal link domain as an
        Associated Domain in your application capabilities.
    1.  If you plan to distribute your application to iOS versions 8 and under,
        you will need to set your bundle ID as a custom scheme for incoming
        URLs.
    1.  For more on this, refer to
        [Receiving Apple platforms Dynamic Links instructions](/docs/dynamic-links/ios/receive).

## Handling email actions in a web application

You can specify whether you want to handle the action code link from a web
application first and then redirect to another web page or mobile application
after successful completion, provided the mobile application is available.
This is done by setting `handleCodeInApp` to `false` in the `ActionCodeSettings` object. While
a bundle ID
or Android package name are not required, providing them will allow the user
to redirect back to the specified app on email action code completion.

The web URL used here, is the one configured in the email action templates
section. A default one is provisioned for all projects. Refer to
[customizing email handlers](/docs/auth/custom-email-handler) to learn more on
how to customize the email action handler.

In this case, the link within the `continueURL` query parameter will be
an FDL link whose payload is the `URL` specified in the `ActionCodeSettings`
object. While you can intercept and handle the incoming link from your app
without any additional dependency, we recommend using the FDL client library to
parse the deep link for you.

<p>When handling email actions such as email verification, the action code from the
<code>oobCode</code> query parameter needs to be parsed from the deep link and then applied
via <code>applyActionCode</code> for the change to take effect, i.e. email to be verified.</p>


## Handling email actions in a mobile application

You can specify whether you want to handle the action code link within your
mobile application first, provided it is installed. With Android applications,
you also have the ability to specify via the `androidInstallApp` that
the app is to be installed if the device supports it and it is not already
installed.
If the link is clicked from a device that does not support the mobile
application, it is opened from a web page instead.
This is done by setting `handleCodeInApp` to `true` in the `ActionCodeSettings` object. The
mobile application's Android package name or bundle ID will also need to be
specified.The fallback web URL used here, when no mobile app is available, is
the one configured in the email action templates section. A default one is
provisioned for all projects. Refer to
[customizing email handlers](/docs/auth/custom-email-handler) to learn more on
how to customize the email action handler.

In this case, the mobile app link sent to the user will be an FDL link whose
payload is the action code URL, configured in the Console, with the query
parameters `oobCode`, `mode`, `apiKey` and `continueUrl`. The latter will be the
original `URL` specified in the
`ActionCodeSettings` object. While you can intercept and handle the
incoming link from your app without any additional dependency, we recommend
using the FDL client library to parse the deep link for you. The action code can
be applied directly from a mobile application similar to how it is handled from
the web flow described in the
[customizing email handlers](/docs/auth/custom-email-handler) section.


<p>When handling email actions such as email verification, the action code from the
<code>oobCode</code> query parameter needs to be parsed from the deep link and then applied
via <code>applyActionCode</code> for the change to take effect, i.e. email to be verified.</p>

Project: /docs/dynamic-links/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{% include "_local_variables.html" %}
{% include "docs/cpp/_local_variables.html" %}
{% include "docs/dynamic-links/_local_variables.html" %}

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Create Dynamic Links in a Flutter app

You can create short or long Dynamic Links with the Firebase Dynamic Links Builder API.
This API accepts either a long Dynamic Link or an object containing Dynamic Link
parameters, and returns URLs like the following examples:

```
https://example.com/link/WXYZ
https://example.page.link/WXYZ
```

## Set up Firebase and the Dynamic Links SDK

Before you can create Dynamic Links in your Android app, you must include the
Firebase SDK. If your app is set up to receive Dynamic Links, you have already
completed these steps and you can skip this section.

1.  [Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup) if you
    haven't already done so.

1.  From the root direcctory of your Flutter project, run the following
    command to install the Dynamic Links plugin:

    ```
    flutter pub add firebase_dynamic_links
    ```

1.  If you're building an Android app, open the [Project settings](https://console.firebase.google.com/project/_/settings/general/)
    page of the Firebase console and make sure you've specified your SHA-1
    signing key. If you use App Links, also specify your SHA-256 key.

1.  In the Firebase console, open the [Dynamic Links](https://console.firebase.google.com/project/_/durablelinks)
    section.

    1.  If you have not already set up a domain for your Dynamic Links, click the
        **Get Started** button and follow the prompts.

        If you already have a Dynamic Links domain, take note of it. You need to
        provide a Dynamic Links domain when you programmatically create Dynamic Links.
        <img src="/docs/dynamic-links/images/dynamic-links-domain.png"></img>

    1.  **Recommended**: From the "More" (&vellip;) menu, specify the URL
        patterns allowed in your deep links and fallback links. By doing so,
        you prevent unauthorized parties from creating Dynamic Links that redirect
        from your domain to sites you don't control.

        See <a href="https://support.google.com/firebase/answer/9021429">Allow specific URL patterns</a>.

## Create a Dynamic Link from parameters

To create a Dynamic Link, create a new `DynamicLinkParameters` object and pass it to
`buildLink()` or `buildShortLink()`.

The following minimal example creates a long Dynamic Link to
`https://www.example.com/` that opens with `com.example.app.android` on Android
and the app `com.example.app.ios` on iOS:

```dart
final dynamicLinkParams = DynamicLinkParameters(
  link: Uri.parse("https://www.example.com/"),
  uriPrefix: "https://example.page.link",
  androidParameters: const AndroidParameters(packageName: "com.example.app.android"),
  iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
);
final dynamicLink =
    await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
```

To create a short Dynamic Link, pass the `DynamicLinkParameters` object to
`buildShortLink()`. Building the short link requires a network call.
For example:

```dart
final dynamicLinkParams = DynamicLinkParameters(
  link: Uri.parse("https://www.example.com/"),
  uriPrefix: "https://example.page.link",
  androidParameters: const AndroidParameters(packageName: "com.example.app.android"),
  iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
);
final dynamicLink =
    await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
```

By default, short Dynamic Links are generated with suffixes that are only a few
characters long. Although this makes links more compact, it also introduces
the possibility that someone could guess a valid short link. Often, there's no
harm if someone does so, because the link leads to public information.

However, if your short links lead to user-specific information, you should
create longer links with 17-character suffixes that make it very unlikely that
someone can guess a valid Dynamic Link. To do so, pass `ShortDynamicLinkType.unguessable`
to the `buildShortLink()` method:

```dart
final unguessableDynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
    dynamicLinkParams,
    shortLinkType: ShortDynamicLinkType.unguessable,
);
```

<h3>Dynamic Link parameters</h3>

You can use the Dynamic Link Builder API to create Dynamic Links with any of the
supported parameters. See the [API reference](https://pub.dev/documentation/firebase_dynamic_links_platform_interface/latest/firebase_dynamic_links_platform_interface/DynamicLinkParameters-class.html).

The following example creates a Dynamic Link with several common parameters
set:

```dart
final dynamicLinkParams = DynamicLinkParameters(
  link: Uri.parse("https://www.example.com/"),
  uriPrefix: "https://example.page.link",
  androidParameters: const AndroidParameters(
    packageName: "com.example.app.android",
    minimumVersion: 30,
  ),
  iosParameters: const IOSParameters(
    bundleId: "com.example.app.ios",
    appStoreId: "123456789",
    minimumVersion: "1.0.1",
  ),
  googleAnalyticsParameters: const GoogleAnalyticsParameters(
    source: "twitter",
    medium: "social",
    campaign: "example-promo",
  ),
  socialMetaTagParameters: SocialMetaTagParameters(
    title: "Example of a Dynamic Link",
    imageUrl: Uri.parse("https://example.com/image.png"),
  ),
);
final dynamicLink =
    await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
```

You can set Dynamic Link parameters with the following methods:

<table>
  <tr><th colspan="2" id="general-params">DynamicLink parameters</th></tr>
  <tr>
    <td>setLink</td>
    <td>The link your app will open. Specify a URL that your app can handle,
        typically the app's content or payload, which initiates app-specific
        logic (such as crediting the user with a coupon or displaying a
        welcome screen). This link must be a well-formatted URL, be properly
        URL-encoded, use either HTTP or HTTPS, and cannot be another Dynamic
        Link.
        <aside>When users open a Dynamic Link on a desktop web browser, they
            will load this URL (unless the ofl parameter is specified). If you
            don't have a web equivalent to the linked content, the URL doesn't
            need to point to a valid web resource. In this situation, you
            should set up a redirect from this URL to, for example, your home
            page.
        </aside>
    </td>
  </tr>
  <tr>
    <td>setDomainUriPrefix</td>
    <td>Your Dynamic Link URL prefix, which you can find in the Firebase console. A
      Dynamic Link domain looks like the following examples:
      <pre>
https://example.com/link
https://example.page.link
</pre>
    </td>
  </tr>
</table>

<table id="android-params">
  <tr><th colspan="2">AndroidParameters</th></tr>
  <tr>
    <td>setFallbackUrl</td>
    <td>The link to open when the app isn't installed. Specify this to do
        something other than install your app from the Play Store when the app
        isn't installed, such as open the mobile web version of the content, or
        display a promotional page for your app.</td>
  </tr>
  <tr>
    <td>setMinimumVersion</td>
    <td>The versionCode of the minimum version of your app that can open the
        link. If the installed app is an older version, the user is taken to
        the Play Store to upgrade the app.</td>
  </tr>
</table>

<table id="ios-params">
  <tr><th colspan="2">IosParameters</th></tr>
  <tr>
    <td>setAppStoreId</td>
    <td>Your app's App Store ID, used to send users to the App Store when the
        app isn't installed</td>
  </tr>
  <tr>
    <td>setFallbackUrl</td>
    <td>The link to open when the app isn't installed. Specify this to do
        something other than install your app from the App Store when the app
        isn't installed, such as open the mobile web version of the content, or
        display a promotional page for your app.</td>
  </tr>
  <tr>
    <td>setCustomScheme</td>
    <td>Your app's custom URL scheme, if defined to be something other than
        your app's bundle ID</td>
  </tr>
  <tr>
    <td>setIpadFallbackUrl</td>
    <td>The link to open on iPads when the app isn't installed. Specify this to
        do something other than install your app from the App Store when the
        app isn't installed, such as open the web version of the content, or
        display a promotional page for your app.</td>
  </tr>
  <tr>
    <td>setIpadBundleId</td>
    <td>The bundle ID of the iOS app to use on iPads to open the link. The app
        must be connected to your project from the Overview page of the
        Firebase console.</td>
  </tr>
  <tr>
    <td>setMinimumVersion</td>
    <td>The version number of the minimum version of your app that can open the
        link. This flag is passed to your app when it is opened, and your app
        must decide what to do with it.</td>
  </tr>
</table>

<table>
  <tr><th colspan="2">NavigationInfoParameters</th></tr>
  <tr>
    <td>setForcedRedirectEnabled</td>
    <td>If set to '1', skip the app preview page when the Dynamic Link is
        opened, and instead redirect to the app or store. The app preview page
        (enabled by default) can more reliably send users to the most
        appropriate destination when they open Dynamic Links in apps; however,
        if you expect a Dynamic Link to be opened only in apps that can open
        Dynamic Links reliably without this page, you can disable it with this
        parameter. This parameter will affect the behavior of the Dynamic Link
        only on iOS.</td>
  </tr>
</table>

<table id="social-params">
  <tr><th colspan="2">SocialMetaTagParameters</th></tr>
  <tr>
    <td>setTitle</td>
    <td>The title to use when the Dynamic Link is shared in a social post.</td>
  </tr>
  <tr>
    <td>setDescription</td>
    <td>The description to use when the Dynamic Link is shared in a social post.</td>
  </tr>
  <tr>
    <td>setImageUrl</td>
    <td>The URL to an image related to this link. The image should be at least
        300x200 px, and less than 300 KB.</td>
  </tr>
</table>

<table id="google-analytics-params">
  <tr><th colspan="2">GoogleAnalyticsParameters</th></tr>
  <tr>
    <td>setSource<br/>setMedium<br/>setCampaign<br/>setTerm<br/>setContent</td>
    <td>Google Play analytics parameters. These parameters
     (`utm_source`, `utm_medium`,
     `utm_campaign`, `utm_term`, `utm_content`)
     are passed on to the Play Store as well as appended to the link payload.
    </td>
  </tr>
</table>

<table id="itunes-analytics-params">
  <tr><th colspan="2">ItunesConnectAnalyticsParameters</th></tr>
  <tr>
    <td>setProviderToken<br/>setAffiliateToken<br/>setCampaignToken</td>
    <td>iTunes Connect analytics parameters. These parameters (`pt`,
      `at`, `ct`) are passed to the App Store.</td>
  </tr>
</table>

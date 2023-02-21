// Copyright 2023 Google Inc. All Rights Reserved.

#ifndef FIREBASE_ANALYTICS_CLIENT_CPP_INCLUDE_FIREBASE_ANALYTICS_EVENT_NAMES_H_
#define FIREBASE_ANALYTICS_CLIENT_CPP_INCLUDE_FIREBASE_ANALYTICS_EVENT_NAMES_H_

/// @brief Namespace that encompasses all Firebase APIs.
namespace firebase {
/// @brief Firebase Analytics API.
namespace analytics {



/// @defgroup event_names Analytics Events
///
/// Predefined event names.
///
/// An Event is an important occurrence in your app that you want to
/// measure. You can report up to 500 different types of Events per app
/// and you can associate up to 25 unique parameters with each Event type.
/// Some common events are suggested below, but you may also choose to
/// specify custom Event types that are associated with your specific app.
/// Each event type is identified by a unique name. Event names can be up
/// to 40 characters long, may only contain alphanumeric characters and
/// underscores ("_"), and must start with an alphabetic character. The
/// "firebase_", "google_", and "ga_" prefixes are reserved and should not
/// be used.
/// @{


/// Ad Impression event. This event signifies when a user sees an ad
/// impression. Note: If you supply the @c AnalyticsParameterValue
/// parameter, you must also supply the @c AnalyticsParameterCurrency
/// parameter so that revenue metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterAdPlatform (String) (optional)</li>
///  <li>@c AnalyticsParameterAdFormat (String) (optional)</li>
///  <li>@c AnalyticsParameterAdSource (String) (optional)</li>
///  <li>@c AnalyticsParameterAdUnitName (String) (optional)</li>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventAdImpression  =
    "ad_impression";

/// Add Payment Info event. This event signifies that a user has submitted
/// their payment information. Note: If you supply the @c
/// AnalyticsParameterValue parameter, you must also supply the @c
/// AnalyticsParameterCurrency parameter so that revenue metrics can be
/// computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCoupon (String) (optional)</li>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterPaymentType (String) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventAddPaymentInfo  =
    "add_payment_info";

/// Add Shipping Info event. This event signifies that a user has
/// submitted their shipping information. Note: If you supply the @c
/// AnalyticsParameterValue parameter, you must also supply the @c
/// AnalyticsParameterCurrency parameter so that revenue metrics can be
/// computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCoupon (String) (optional)</li>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterShippingTier (String) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventAddShippingInfo  =
    "add_shipping_info";

/// E-Commerce Add To Cart event. This event signifies that an item(s) was
/// added to a cart for purchase. Add this event to a funnel with @c
/// AnalyticsEventPurchase to gauge the effectiveness of your
/// checParameter(kout, If you supply the @c AnalyticsParameterValue
/// parameter), you must also supply the @c AnalyticsParameterCurrency
/// parameter so that revenue metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventAddToCart  = "add_to_cart";

/// E-Commerce Add To Wishlist event. This event signifies that an item
/// was added to a wishlist. Use this event to identify popular gift
/// items. Note: If you supply the @c AnalyticsParameterValue parameter,
/// you must also supply the @c AnalyticsParameterCurrency parameter so
/// that revenue metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventAddToWishlist  =
    "add_to_wishlist";

/// App Open event. By logging this event when an App becomes active,
/// developers can understand how often users leave and return during the
/// course of a Session. Although Sessions are automatically reported,
/// this event can provide further clarification around the continuous
/// engagement of app-users.
static const char*const kEventAppOpen  = "app_open";

/// E-Commerce Begin Checkout event. This event signifies that a user has
/// begun the process of checking out. Add this event to a funnel with
/// your @c AnalyticsEventPurchase event to gauge the effectiveness of
/// your checkout process. Note: If you supply the @c
/// AnalyticsParameterValue parameter, you must also supply the @c
/// AnalyticsParameterCurrency parameter so that revenue metrics can be
/// computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCoupon (String) (optional)</li>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventBeginCheckout  =
    "begin_checkout";

/// Campaign Detail event. Log this event to supply the referral details
/// of a re-engagement campaign. Note: you must supply at least one of the
/// required parameters AnalyticsParameterSource, AnalyticsParameterMedium
/// or AnalyticsParameterCampaign. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterSource (String)</li>
///  <li>@c AnalyticsParameterMedium (String)</li>
///  <li>@c AnalyticsParameterCampaign (String)</li>
///  <li>@c AnalyticsParameterTerm (String) (optional)</li>
///  <li>@c AnalyticsParameterContent (String) (optional)</li>
///  <li>@c AnalyticsParameterAdNetworkClickID (String) (optional)</li>
///  <li>@c AnalyticsParameterCP1 (String) (optional)</li>
///  <li>@c AnalyticsParameterCampaignID (String) (optional)</li>
///  <li>@c AnalyticsParameterCreativeFormat (String) (optional)</li>
///  <li>@c AnalyticsParameterMarketingTactic (String) (optional)</li>
///  <li>@c AnalyticsParameterSourcePlatform (String) (optional)</li>
/// </ul>
static const char*const kEventCampaignDetails  =
    "campaign_details";

/// Earn Virtual Currency event. This event tracks the awarding of virtual
/// currency in your app. Log this along with @c
/// AnalyticsEventSpendVirtualCurrency to better understand your virtual
/// economy. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterVirtualCurrencyName (String)</li>
///  <li>@c AnalyticsParameterValue (Int or Double)</li>
/// </ul>
static const char*const kEventEarnVirtualCurrency
     = "earn_virtual_currency";

/// Generate Lead event. Log this event when a lead has been generated in
/// the app to understand the efficacy of your install and re-engagement
/// campaigns. Note: If you supply the @c AnalyticsParameterValue
/// parameter, you must also supply the @c AnalyticsParameterCurrency
/// parameter so that revenue metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventGenerateLead  =
    "generate_lead";

/// Join Group event. Log this event when a user joins a group such as a
/// guild, team or family. Use this event to analyze how popular certain
/// groups or social features are in your app. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterGroupID (String)</li>
/// </ul>
static const char*const kEventJoinGroup  = "join_group";

/// Level End event. Log this event when the user finishes a level.
/// Params:
///
/// <ul>
///  <li>@c AnalyticsParameterLevelName (String)</li>
///  <li>@c AnalyticsParameterSuccess (String)</li>
/// </ul>
static const char*const kEventLevelEnd  = "level_end";

/// Level Start event. Log this event when the user starts a new level.
/// Params:
///
/// <ul>
///  <li>@c AnalyticsParameterLevelName (String)</li>
/// </ul>
static const char*const kEventLevelStart  = "level_start";

/// Level Up event. This event signifies that a player has leveled up in
/// your gaming app. It can help you gauge the level distribution of your
/// userbase and help you identify certain levels that are difficult to
/// pass. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterLevel (Int)</li>
///  <li>@c AnalyticsParameterCharacter (String) (optional)</li>
/// </ul>
static const char*const kEventLevelUp  = "level_up";

/// Login event. Apps with a login feature can report this event to
/// signify that a user has logged in.
static const char*const kEventLogin  = "login";

/// Post Score event. Log this event when the user posts a score in your
/// gaming app. This event can help you understand how users are actually
/// performing in your game and it can help you correlate high scores with
/// certain audiences or behaviors. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterScore (Int)</li>
///  <li>@c AnalyticsParameterLevel (Int) (optional)</li>
///  <li>@c AnalyticsParameterCharacter (String) (optional)</li>
/// </ul>
static const char*const kEventPostScore  = "post_score";

/// E-Commerce Purchase event. This event signifies that an item(s) was
/// purchased by a user. Note: This is different from the in-app purchase
/// event, which is reported automatically for App Store-based apps. Note:
/// If you supply the @c AnalyticsParameterValue parameter, you must also
/// supply the @c AnalyticsParameterCurrency parameter so that revenue
/// metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterAffiliation (String) (optional)</li>
///  <li>@c AnalyticsParameterCoupon (String) (optional)</li>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterEndDate (String) (optional)</li>
///  <li>@c AnalyticsParameterItemID (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterShipping (Double) (optional)</li>
///  <li>@c AnalyticsParameterStartDate (String) (optional)</li>
///  <li>@c AnalyticsParameterTax (Double) (optional)</li>
///  <li>@c AnalyticsParameterTransactionID (String) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventPurchase  = "purchase";

/// E-Commerce Refund event. This event signifies that a refund was
/// issued. Note: If you supply the @c AnalyticsParameterValue parameter,
/// you must also supply the @c AnalyticsParameterCurrency parameter so
/// that revenue metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterAffiliation (String) (optional)</li>
///  <li>@c AnalyticsParameterCoupon (String) (optional)</li>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterShipping (Double) (optional)</li>
///  <li>@c AnalyticsParameterTax (Double) (optional)</li>
///  <li>@c AnalyticsParameterTransactionID (String) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventRefund  = "refund";

/// E-Commerce Remove from Cart event. This event signifies that an
/// item(s) was removed from a cart. Note: If you supply the @c
/// AnalyticsParameterValue parameter, you must also supply the @c
/// AnalyticsParameterCurrency parameter so that revenue metrics can be
/// computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventRemoveFromCart  =
    "remove_from_cart";

/// Screen View event. This event signifies a screen view. Use this when a
/// screen transition occurs. This event can be logged irrespective of
/// whether automatic screen tracking is enabled. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterScreenClass (String) (optional)</li>
///  <li>@c AnalyticsParameterScreenName (String) (optional)</li>
/// </ul>
static const char*const kEventScreenView  = "screen_view";

/// Search event. Apps that support search features can use this event to
/// contextualize search operations by supplying the appropriate,
/// corresponding parameters. This event can help you identify the most
/// popular content in your app. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterSearchTerm (String)</li>
///  <li>@c AnalyticsParameterStartDate (String) (optional)</li>
///  <li>@c AnalyticsParameterEndDate (String) (optional)</li>
///  <li>@c AnalyticsParameterNumberOfNights (Int) (optional) for hotel bookings</li>
///  <li>@c AnalyticsParameterNumberOfRooms (Int) (optional) for hotel bookings</li>
///  <li>@c AnalyticsParameterNumberOfPassengers (Int) (optional) for travel bookings</li>
///  <li>@c AnalyticsParameterOrigin (String) (optional)</li>
///  <li>@c AnalyticsParameterDestination (String) (optional)</li>
///  <li>@c AnalyticsParameterTravelClass (String) (optional) for travel bookings</li>
/// </ul>
static const char*const kEventSearch  = "search";

/// Select Content event. This general purpose event signifies that a user
/// has selected some content of a certain type in an app. The content can
/// be any object in your app. This event can help you identify popular
/// content and categories of content in your app. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterContentType (String)</li>
///  <li>@c AnalyticsParameterItemID (String)</li>
/// </ul>
static const char*const kEventSelectContent  =
    "select_content";

/// Select Item event. This event signifies that an item was selected by a
/// user from a list. Use the appropriate parameters to contextualize the
/// event. Use this event to discover the most popular items selected.
/// Params:
///
/// <ul>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterItemListID (String) (optional)</li>
///  <li>@c AnalyticsParameterItemListName (String) (optional)</li>
/// </ul>
static const char*const kEventSelectItem  = "select_item";

/// Select promotion event. This event signifies that a user has selected
/// a promotion offer. Use the appropriate parameters to contextualize the
/// event, such as the item(s) for which the promotion applies. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCreativeName (String) (optional)</li>
///  <li>@c AnalyticsParameterCreativeSlot (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterLocationID (String) (optional)</li>
///  <li>@c AnalyticsParameterPromotionID (String) (optional)</li>
///  <li>@c AnalyticsParameterPromotionName (String) (optional)</li>
/// </ul>
static const char*const kEventSelectPromotion  =
    "select_promotion";

/// Share event. Apps with social features can log the Share event to
/// identify the most viral content. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterContentType (String)</li>
///  <li>@c AnalyticsParameterItemID (String)</li>
/// </ul>
static const char*const kEventShare  = "share";

/// Sign Up event. This event indicates that a user has signed up for an
/// account in your app. The parameter signifies the method by which the
/// user signed up. Use this event to understand the different behaviors
/// between logged in and logged out users. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterMethod (String)</li>
/// </ul>
static const char*const kEventSignUp  = "sign_up";

/// Spend Virtual Currency event. This event tracks the sale of virtual
/// goods in your app and can help you identify which virtual goods are
/// the most popular objects of purchase. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterItemName (String)</li>
///  <li>@c AnalyticsParameterVirtualCurrencyName (String)</li>
///  <li>@c AnalyticsParameterValue (Int or Double)</li>
/// </ul>
static const char*const kEventSpendVirtualCurrency
     = "spend_virtual_currency";

/// Tutorial Begin event. This event signifies the start of the
/// on-boarding process in your app. Use this in a funnel with @c
/// AnalyticsEventTutorialComplete to understand how many users complete
/// this process and move on to the full app experience.
static const char*const kEventTutorialBegin  =
    "tutorial_begin";

/// Tutorial End event. Use this event to signify the user's completion of
/// your app's on-boarding process. Add this to a funnel with @c
/// AnalyticsEventTutorialBegin to gauge the completion rate of your
/// on-boarding process.
static const char*const kEventTutorialComplete  =
    "tutorial_complete";

/// Unlock Achievement event. Log this event when the user has unlocked an
/// achievement in your game. Since achievements generally represent the
/// breadth of a gaming experience, this event can help you understand how
/// many users are experiencing all that your game has to offer. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterAchievementID (String)</li>
/// </ul>
static const char*const kEventUnlockAchievement  =
    "unlock_achievement";

/// E-commerce View Cart event. This event signifies that a user has
/// viewed their cart. Use this to analyze your purchase funnel. Note: If
/// you supply the @c AnalyticsParameterValue parameter, you must also
/// supply the @c AnalyticsParameterCurrency parameter so that revenue
/// metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventViewCart  = "view_cart";

/// View Item event. This event signifies that a user has viewed an item.
/// Use the appropriate parameters to contextualize the event. Use this
/// event to discover the most popular items viewed in your app. Note: If
/// you supply the @c AnalyticsParameterValue parameter, you must also
/// supply the @c AnalyticsParameterCurrency parameter so that revenue
/// metrics can be computed accurately. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCurrency (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterValue (Double) (optional)</li>
/// </ul>
static const char*const kEventViewItem  = "view_item";

/// View Item List event. Log this event when a user sees a list of items
/// or offerings. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterItemListID (String) (optional)</li>
///  <li>@c AnalyticsParameterItemListName (String) (optional)</li>
/// </ul>
static const char*const kEventViewItemList  =
    "view_item_list";

/// View Promotion event. This event signifies that a promotion was shown
/// to a user. Add this event to a funnel with the @c
/// AnalyticsEventAddToCart and @c AnalyticsEventPurchase to gauge your
/// conversion process. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterCreativeName (String) (optional)</li>
///  <li>@c AnalyticsParameterCreativeSlot (String) (optional)</li>
///  <li>@c AnalyticsParameterItems ([[String: Any]]) (optional)</li>
///  <li>@c AnalyticsParameterLocationID (String) (optional)</li>
///  <li>@c AnalyticsParameterPromotionID (String) (optional)</li>
///  <li>@c AnalyticsParameterPromotionName (String) (optional)</li>
/// </ul>
static const char*const kEventViewPromotion  =
    "view_promotion";

/// View Search Results event. Log this event when the user has been
/// presented with the results of a search. Params:
///
/// <ul>
///  <li>@c AnalyticsParameterSearchTerm (String)</li>
/// </ul>
static const char*const kEventViewSearchResults  =
    "view_search_results";
/// @}

}  // namespace analytics
}  // namespace firebase

#endif  // FIREBASE_ANALYTICS_CLIENT_CPP_INCLUDE_FIREBASE_ANALYTICS_EVENT_NAMES_H_

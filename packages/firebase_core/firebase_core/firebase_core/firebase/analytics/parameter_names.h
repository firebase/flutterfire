// Copyright 2023 Google Inc. All Rights Reserved.

#ifndef FIREBASE_ANALYTICS_CLIENT_CPP_INCLUDE_FIREBASE_ANALYTICS_PARAMETER_NAMES_H_
#define FIREBASE_ANALYTICS_CLIENT_CPP_INCLUDE_FIREBASE_ANALYTICS_PARAMETER_NAMES_H_

/// @brief Namespace that encompasses all Firebase APIs.
namespace firebase {
/// @brief Firebase Analytics API.
namespace analytics {



/// @defgroup parameter_names Analytics Parameters
///
/// Predefined event parameter names.
///
/// Params supply information that contextualize Events. You can associate
/// up to 25 unique Params with each Event type. Some Params are suggested
/// below for certain common Events, but you are not limited to these. You
/// may supply extra Params for suggested Events or custom Params for
/// Custom events. Param names can be up to 40 characters long, may only
/// contain alphanumeric characters and underscores ("_"), and must start
/// with an alphabetic character. Param values can be up to 100 characters
/// long. The "firebase_", "google_", and "ga_" prefixes are reserved and
/// should not be used.
/// @{


/// Game achievement ID (String).
/// @code
///  let params = [
///    AnalyticsParameterAchievementID : "10_matches_won",
///    // ...
///  ]
/// @endcode
static const char*const kParameterAchievementID  =
    "achievement_id";

/// The ad format (e.g. Banner, Interstitial, Rewarded, Native, Rewarded
/// Interstitial, Instream). (String).
/// @code
///  let params = [
///    AnalyticsParameterAdFormat : "Banner",
///    // ...
///  ]
/// @endcode
static const char*const kParameterAdFormat  =
    "ad_format";

/// Ad Network Click ID (String). Used for network-specific click IDs
/// which vary in format.
/// @code
///  let params = [
///    AnalyticsParameterAdNetworParameter(kClickID, "1234567"),
///    // ...
///  ]
/// @endcode
static const char*const kParameterAdNetworkClickID
     = "aclid";

/// The ad platform (e.g. MoPub, IronSource) (String).
/// @code
///  let params = [
///    AnalyticsParameterAdPlatform : "MoPub",
///    // ...
///  ]
/// @endcode
static const char*const kParameterAdPlatform  =
    "ad_platform";

/// The ad source (e.g. AdColony) (String).
/// @code
///  let params = [
///    AnalyticsParameterAdSource : "AdColony",
///    // ...
///  ]
/// @endcode
static const char*const kParameterAdSource  =
    "ad_source";

/// The ad unit name (e.g. Banner_03) (String).
/// @code
///  let params = [
///    AnalyticsParameterAdUnitName : "Banner_03",
///    // ...
///  ]
/// @endcode
static const char*const kParameterAdUnitName  =
    "ad_unit_name";

/// A product affiliation to designate a supplying company or brick and
/// mortar store location
/// (String). @code
///  let params = [
///    AnalyticsParameterAffiliation : "Google Store",
///    // ...
///  ]
/// @endcode
static const char*const kParameterAffiliation  =
    "affiliation";

/// Campaign custom parameter (String). Used as a method of capturing
/// custom data in a campaign. Use varies by network.
/// @code
///  let params = [
///    AnalyticsParameterCP1 : "custom_data",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCP1  = "cp1";

/// The individual campaign name, slogan, promo code, etc. Some networks
/// have pre-defined macro to capture campaign information, otherwise can
/// be populated by developer. Highly Recommended (String).
/// @code
///  let params = [
///    AnalyticsParameterCampaign : "winter_promotion",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCampaign  =
    "campaign";

/// Campaign ID (String). Used for keyword analysis to identify a specific
/// product promotion or strategic campaign. This is a required key for
/// GA4 data import.
/// @code
///  let params = [
///    AnalyticsParameterCampaignID : "7877652710",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCampaignID  =
    "campaign_id";

/// Character used in game (String).
/// @code
///  let params = [
///    AnalyticsParameterCharacter : "beat_boss",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCharacter  =
    "character";

/// Campaign content (String).
static const char*const kParameterContent  = "content";

/// Type of content selected (String).
/// @code
///  let params = [
///    AnalyticsParameterContentType : "news article",
///    // ...
///  ]
/// @endcode
static const char*const kParameterContentType  =
    "content_type";

/// Coupon code used for a purchase (String).
/// @code
///  let params = [
///    AnalyticsParameterCoupon : "SUMMER_FUN",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCoupon  = "coupon";

/// Creative Format (String). Used to identify the high-level
/// classification of the type of ad served by a specific campaign.
/// @code
///  let params = [
///    AnalyticsParameterCreativeFormat : "display",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCreativeFormat  =
    "creative_format";

/// The name of a creative used in a promotional spot (String).
/// @code
///  let params = [
///    AnalyticsParameterCreativeName : "Summer Sale",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCreativeName  =
    "creative_name";

/// The name of a creative slot (String).
/// @code
///  let params = [
///    AnalyticsParameterCreativeSlot : "summer_banner2",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCreativeSlot  =
    "creative_slot";

/// Currency of the purchase or items associated with the event, in
/// 3-letter
/// <a href="http://en.wikipedia.org/wiki/ISO_4217#Active_codes"> ISO_4217</a> format (String).
/// @code
///  let params = [
///    AnalyticsParameterCurrency : "USD",
///    // ...
///  ]
/// @endcode
static const char*const kParameterCurrency  =
    "currency";

/// Flight or Travel destination (String).
/// @code
///  let params = [
///    AnalyticsParameterDestination : "Mountain View, CA",
///    // ...
///  ]
/// @endcode
static const char*const kParameterDestination  =
    "destination";

/// Monetary value of discount associated with a purchase (Double).
/// @code
///  let params = [
///    AnalyticsParameterDiscount : 2.0,
///    AnalyticsParameterCurrency : "USD",  // e.g. $2.00 USD
///    // ...
///  ]
/// @endcode
static const char*const kParameterDiscount  =
    "discount";

/// The arrival date, check-out date or rental end date for the item. This
/// should be in YYYY-MM-DD format (String).
/// @code
///  let params = [
///    AnalyticsParameterEndDate : "2015-09-14",
///    // ...
///  ]
/// @endcode
static const char*const kParameterEndDate  = "end_date";

/// Indicates that the associated event should either extend the current
/// session or start a new session if no session was active when the event
/// was logged. Specify 1 to extend the current session or to start a new
/// session; any other value will not extend or start a session.
/// @code
///  let params = [
///    AnalyticsParameterExtendSession : 1,
///    // ...
///  ]
/// @endcode
static const char*const kParameterExtendSession  =
    "extend_session";

/// Flight number for travel events (String).
/// @code
///  let params = [
///    AnalyticsParameterFlightNumber : "ZZ800",
///    // ...
///  ]
/// @endcode
static const char*const kParameterFlightNumber  =
    "flight_number";

/// Group/clan/guild ID (String).
/// @code
///  let params = [
///    AnalyticsParameterGroupID : "g1",
///    // ...
///  ]
/// @endcode
static const char*const kParameterGroupID  = "group_id";

/// The index of the item in a list (Int).
/// @code
///  let params = [
///    AnalyticsParameterIndex : 5,
///    // ...
///  ]
/// @endcode
static const char*const kParameterIndex  = "index";

/// Item brand (String).
/// @code
///  let params = [
///    AnalyticsParameterItemBrand : "Google",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemBrand  =
    "item_brand";

/// Item category (context-specific) (String).
/// @code
///  let params = [
///    AnalyticsParameterItemCategory : "pants",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemCategory  =
    "item_category";

/// Item Category (context-specific) (String).
/// @code
///  let params = [
///    AnalyticsParameterItemCategory2 : "pants",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemCategory2  =
    "item_category2";

/// Item Category (context-specific) (String).
/// @code
///  let params = [
///    AnalyticsParameterItemCategory3 : "pants",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemCategory3  =
    "item_category3";

/// Item Category (context-specific) (String).
/// @code
///  let params = [
///    AnalyticsParameterItemCategory4 : "pants",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemCategory4  =
    "item_category4";

/// Item Category (context-specific) (String).
/// @code
///  let params = [
///    AnalyticsParameterItemCategory5 : "pants",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemCategory5  =
    "item_category5";

/// Item ID (context-specific) (String).
/// @code
///  let params = [
///    AnalyticsParameterItemID : "SKU_12345",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemID  = "item_id";

/// The ID of the list in which the item was presented to the
/// user (String).
/// @code
///  let params = [
///    AnalyticsParameterItemListID : "ABC123",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemListID  =
    "item_list_id";

/// The name of the list in which the item was presented to the user
/// (String).
/// @code
///  let params = [
///    AnalyticsParameterItemListName : "Related products",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemListName  =
    "item_list_name";

/// Item Name (context-specific) (String).
/// @code
///  let params = [
///    AnalyticsParameterItemName : "jeggings",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemName  =
    "item_name";

/// Item variant (String).
/// @code
///  let params = [
///    AnalyticsParameterItemVariant : "Black",
///    // ...
///  ]
/// @endcode
static const char*const kParameterItemVariant  =
    "item_variant";

/// The list of items involved in the transaction expressed as `[[String:
/// Any]]`.
/// @code
///  let params = [
///    AnalyticsParameterItems : [
///      [AnalyticsParameterItemName : "jeggings", AnalyticsParameterItemCategory : "pants"],
///      [AnalyticsParameterItemName : "boots", AnalyticsParameterItemCategory : "shoes"],
///    ],
///  ]
/// @endcode
static const char*const kParameterItems  = "items";

/// Level in game (Int).
/// @code
///  let params = [
///    AnalyticsParameterLevel : 42,
///    // ...
///  ]
/// @endcode
static const char*const kParameterLevel  = "level";

/// The name of a level in a game (String).
/// @code
///  let params = [
///    AnalyticsParameterLevelName : "room_1",
///    // ...
///  ]
/// @endcode
static const char*const kParameterLevelName  =
    "level_name";

/// Location (String). The Google <a href="https://developers.google.com/places/place-id">Place ID
/// </a> that corresponds to the associated event. Alternatively, you can supply your own custom
/// Location ID.
/// @code
///  let params = [
///    AnalyticsParameterLocation : "ChIJiyj437sx3YAR9kUWC8QkLzQ",
///    // ...
///  ]
/// @endcode
static const char*const kParameterLocation  =
    "location";

/// The location associated with the event. Preferred to be the Google
/// <a href="https://developers.google.com/places/place-id">Place ID</a> that corresponds to the
/// associated item but could be overridden to a custom location ID
/// string.(String).
/// @code
///  let params = [
///    AnalyticsParameterLocationID : "ChIJiyj437sx3YAR9kUWC8QkLzQ",
///    // ...
///  ]
/// @endcode
static const char*const kParameterLocationID  =
    "location_id";

/// Marketing Tactic (String). Used to identify the targeting criteria
/// applied to a specific campaign.
/// @code
///  let params = [
///    AnalyticsParameterMarParameter(ketingTactic, "Remarketing"),
///    // ...
///  ]
/// @endcode
static const char*const kParameterMarketingTactic
     = "marketing_tactic";

/// The advertising or marParameter(keting, cpc, banner, email), push.
/// Highly recommended (String).
/// @code
///  let params = [
///    AnalyticsParameterMedium : "email",
///    // ...
///  ]
/// @endcode
static const char*const kParameterMedium  = "medium";

/// A particular approach used in an operation; for example, "facebook" or
/// "email" in the context of a sign_up or login event. (String).
/// @code
///  let params = [
///    AnalyticsParameterMethod : "google",
///    // ...
///  ]
/// @endcode
static const char*const kParameterMethod  = "method";

/// Number of nights staying at hotel (Int).
/// @code
///  let params = [
///    AnalyticsParameterNumberOfNights : 3,
///    // ...
///  ]
/// @endcode
static const char*const kParameterNumberOfNights
     = "number_of_nights";

/// Number of passengers traveling (Int).
/// @code
///  let params = [
///    AnalyticsParameterNumberOfPassengers : 11,
///    // ...
///  ]
/// @endcode
static const char*const kParameterNumberOfPassengers
     = "number_of_passengers";

/// Number of rooms for travel events (Int).
/// @code
///  let params = [
///    AnalyticsParameterNumberOfRooms : 2,
///    // ...
///  ]
/// @endcode
static const char*const kParameterNumberOfRooms  =
    "number_of_rooms";

/// Flight or Travel origin (String).
/// @code
///  let params = [
///    AnalyticsParameterOrigin : "Mountain View, CA",
///    // ...
///  ]
/// @endcode
static const char*const kParameterOrigin  = "origin";

/// The chosen method of payment (String).
/// @code
///  let params = [
///    AnalyticsParameterPaymentType : "Visa",
///    // ...
///  ]
/// @endcode
static const char*const kParameterPaymentType  =
    "payment_type";

/// Purchase price (Double).
/// @code
///  let params = [
///    AnalyticsParameterPrice : 1.0,
///    AnalyticsParameterCurrency : "USD",  // e.g. $1.00 USD
///    // ...
///  ]
/// @endcode
static const char*const kParameterPrice  = "price";

/// The ID of a product promotion (String).
/// @code
///  let params = [
///    AnalyticsParameterPromotionID : "ABC123",
///    // ...
///  ]
/// @endcode
static const char*const kParameterPromotionID  =
    "promotion_id";

/// The name of a product promotion (String).
/// @code
///  let params = [
///    AnalyticsParameterPromotionName : "Summer Sale",
///    // ...
///  ]
/// @endcode
static const char*const kParameterPromotionName  =
    "promotion_name";

/// Purchase quantity (Int).
/// @code
///  let params = [
///    AnalyticsParameterQuantity : 1,
///    // ...
///  ]
/// @endcode
static const char*const kParameterQuantity  =
    "quantity";

/// Score in game (Int).
/// @code
///  let params = [
///    AnalyticsParameterScore : 4200,
///    // ...
///  ]
/// @endcode
static const char*const kParameterScore  = "score";

/// Current screen class, such as the class name of the UIViewController,
/// logged with screen_view event and added to every event (String).
/// @code
///  let params = [
///    AnalyticsParameterScreenClass : "LoginViewController",
///    // ...
///  ]
/// @endcode
static const char*const kParameterScreenClass  =
    "screen_class";

/// Current screen name, such as the name of the UIViewController, logged
/// with screen_view event and added to every event (String).
/// @code
///  let params = [
///    AnalyticsParameterScreenName : "LoginView",
///    // ...
///  ]
/// @endcode
static const char*const kParameterScreenName  =
    "screen_name";

/// The search string/keywords used (String).
/// @code
///  let params = [
///    AnalyticsParameterSearchTerm : "periodic table",
///    // ...
///  ]
/// @endcode
static const char*const kParameterSearchTerm  =
    "search_term";

/// Shipping cost associated with a transaction (Double).
/// @code
///  let params = [
///    AnalyticsParameterShipping : 5.99,
///    AnalyticsParameterCurrency : "USD",  // e.g. $5.99 USD
///    // ...
///  ]
/// @endcode
static const char*const kParameterShipping  =
    "shipping";

/// The shipping tier (e.g. Ground, Air, Next-day) selected for delivery
/// of the purchased item (String).
/// @code
///  let params = [
///    AnalyticsParameterShippingTier : "Ground",
///    // ...
///  ]
/// @endcode
static const char*const kParameterShippingTier  =
    "shipping_tier";

/// The origin of your traffic, such as an Ad network (for example,
/// google) or partner (urban airship). Identify the advertiser, site,
/// publication, etc. that is sending traffic to your property. Highly
/// recommended (String).
/// @code
///  let params = [
///    AnalyticsParameterSource : "InMobi",
///    // ...
///  ]
/// @endcode
static const char*const kParameterSource  = "source";

/// Source Platform (String). Used to identify the platform responsible
/// for directing traffic to a given Analytics property (e.g., a buying
/// platform where budgets, targeting criteria, etc. are set, a platform
/// for managing organic traffic data, etc.).
/// @code
///  let params = [
///    AnalyticsParameterSourcePlatform : "sa360",
///    // ...
///  ]
/// @endcode
static const char*const kParameterSourcePlatform  =
    "source_platform";

/// The departure date, check-in date or rental start date for the item.
/// This should be in YYYY-MM-DD format (String).
/// @code
///  let params = [
///    AnalyticsParameterStartDate : "2015-09-14",
///    // ...
///  ]
/// @endcode
static const char*const kParameterStartDate  =
    "start_date";

/// The result of an operation. Specify 1 to indicate success and 0 to
/// indicate failure (Int).
/// @code
///  let params = [
///    AnalyticsParameterSuccess : 1,
///    // ...
///  ]
/// @endcode
static const char*const kParameterSuccess  = "success";

/// Tax cost associated with a transaction (Double).
/// @code
///  let params = [
///    AnalyticsParameterTax : 2.43,
///    AnalyticsParameterCurrency : "USD",  // e.g. $2.43 USD
///    // ...
///  ]
/// @endcode
static const char*const kParameterTax  = "tax";

/// If you're manually tagging keyword campaigns, you should use utm_term
/// to specify the keyword (String).
/// @code
///  let params = [
///    AnalyticsParameterTerm : "game",
///    // ...
///  ]
/// @endcode
static const char*const kParameterTerm  = "term";

/// The unique identifier of a transaction (String).
/// @code
///  let params = [
///    AnalyticsParameterTransactionID : "T12345",
///    // ...
///  ]
/// @endcode
static const char*const kParameterTransactionID  =
    "transaction_id";

/// Travel class (String).
/// @code
///  let params = [
///    AnalyticsParameterTravelClass : "business",
///    // ...
///  ]
/// @endcode
static const char*const kParameterTravelClass  =
    "travel_class";

/// A context-specific numeric value which is accumulated automatically
/// for each event type. This is a general purpose parameter that is
/// useful for accumulating a key metric that pertains to an event.
/// Examples include revenue, distance, time and points. Value should be
/// specified as Int or Double. Notes: Values for pre-defined
/// currency-related events (such as @c AnalyticsEventAddToCart) should be
/// supplied using Double and must be accompanied by a @c
/// AnalyticsParameterCurrency parameter. The valid range of accumulated
/// values is [-9,223,372,036,854.77, 9,223,372,036,854.77]. Supplying a
/// non-numeric value, omitting the corresponding @c
/// AnalyticsParameterCurrency parameter, or supplying an invalid
/// <a href="https://goo.gl/qqX3J2">currency code</a> for conversion events will cause that
/// conversion to be omitted from reporting.
/// @code
///  let params = [
///    AnalyticsParameterValue : 3.99,
///    AnalyticsParameterCurrency : "USD",  // e.g. $3.99 USD
///    // ...
///  ]
/// @endcode
static const char*const kParameterValue  = "value";

/// Name of virtual currency type (String).
/// @code
///  let params = [
///    AnalyticsParameterVirtualCurrencyName : "virtual_currency_name",
///    // ...
///  ]
/// @endcode
static const char*const kParameterVirtualCurrencyName
     = "virtual_currency_name";
/// @}

}  // namespace analytics
}  // namespace firebase

#endif  // FIREBASE_ANALYTICS_CLIENT_CPP_INCLUDE_FIREBASE_ANALYTICS_PARAMETER_NAMES_H_

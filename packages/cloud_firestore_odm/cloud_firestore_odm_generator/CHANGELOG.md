## 1.0.0-dev.50

 - Update a dependency to the latest release.

## 1.0.0-dev.49

 - Update a dependency to the latest release.

## 1.0.0-dev.48

 - Update a dependency to the latest release.

## 1.0.0-dev.47

 - Update a dependency to the latest release.

## 1.0.0-dev.46

 - **REFACTOR**: upgrade project to remove warnings from Flutter 3.7 ([#10344](https://github.com/firebase/flutterfire/issues/10344)). ([e0087c84](https://github.com/firebase/flutterfire/commit/e0087c845c7526c11a4241a26d39d4673b0ad29d))

## 1.0.0-dev.45

 - Update a dependency to the latest release.

## 1.0.0-dev.44

 - Update a dependency to the latest release.

## 1.0.0-dev.43

 - Update a dependency to the latest release.

## 1.0.0-dev.42

 - **FIX**: a bug where the ODM does not respect JSON case renaming ([#9988](https://github.com/firebase/flutterfire/issues/9988)). ([02d394b6](https://github.com/firebase/flutterfire/commit/02d394b6b0917f7dc98711b9939630c0b423ed63))

## 1.0.0-dev.41

 - Update a dependency to the latest release.

## 1.0.0-dev.40

 - **FIX**: Improve error handling if a collection and the associated model are defined in separate files. ([#9827](https://github.com/firebase/flutterfire/issues/9827)). ([294e1085](https://github.com/firebase/flutterfire/commit/294e1085ae7af92573657489b78ae0a82ab5e4b4))

## 1.0.0-dev.39

 - **FIX**: Upgrade analyzer version. ([#9828](https://github.com/firebase/flutterfire/issues/9828)). ([b7f5887d](https://github.com/firebase/flutterfire/commit/b7f5887d76ba11de5041f39d2bb5fdcb8aec288d))

## 1.0.0-dev.38

 - Update a dependency to the latest release.

## 1.0.0-dev.37

 - **FIX**: The ODM correctly no-longer generates query utilities for getters. ([#9766](https://github.com/firebase/flutterfire/issues/9766)). ([cfb56939](https://github.com/firebase/flutterfire/commit/cfb569395cadf6b7bcd8727b680d0b52e4e9297d))

## 1.0.0-dev.36

 - Update a dependency to the latest release.

## 1.0.0-dev.35

 - **FEAT**: Add support for FirebaseFirestore.myNamedQueryGet() ([#9721](https://github.com/firebase/flutterfire/issues/9721)). ([82152a00](https://github.com/firebase/flutterfire/commit/82152a0081343a6f7b7d1f5725818825e2b1191a))

## 1.0.0-dev.34

 - **FEAT**: Add support for FieldValue ([#9684](https://github.com/firebase/flutterfire/issues/9684)). ([467c403a](https://github.com/firebase/flutterfire/commit/467c403aad5dc9a829450eee22750e172e88f90b))

## 1.0.0-dev.33

 - **FIX**: Update ignored lints in generated files ([#9683](https://github.com/firebase/flutterfire/issues/9683)). ([3ab283bb](https://github.com/firebase/flutterfire/commit/3ab283bb3ec6e5dbc0befefb062c5069959f9fb5))
 - **FEAT**: Add transaction utilities to the ODM ([#9670](https://github.com/firebase/flutterfire/issues/9670)). ([7d84d70a](https://github.com/firebase/flutterfire/commit/7d84d70a1120f7751f5ff817d7b10b330dcf7e06))

## 1.0.0-dev.32

 - **FEAT**: Allow injecting the document ID in the ODM model ([#9600](https://github.com/firebase/flutterfire/issues/9600)). ([c7e93cfe](https://github.com/firebase/flutterfire/commit/c7e93cfec14e0e00bcabb232760ae5a968a1c2a1))

## 1.0.0-dev.31

 - **FIX**: a false positive by checking that there are no prefix duplicates.  ([#9576](https://github.com/firebase/flutterfire/issues/9576)). ([d6f619c9](https://github.com/firebase/flutterfire/commit/d6f619c90fadb5057a8db1d69921cd4e2f5c1816))
 - **FIX**: handle query.orderBy(startAt:).orderBy() ([#9185](https://github.com/firebase/flutterfire/issues/9185)). ([62396e8a](https://github.com/firebase/flutterfire/commit/62396e8a4a229dfc096d6280964bb559c00b3511))

## 1.0.0-dev.30

 - **FEAT**: add support for specifying class name prefix ([#9453](https://github.com/firebase/flutterfire/issues/9453)). ([49921a43](https://github.com/firebase/flutterfire/commit/49921a4362c5965d2efeed17eb73775302007ea8))

## 1.0.0-dev.29

 - **FIX**: bump minimum analyzer version ([#9493](https://github.com/firebase/flutterfire/issues/9493)). ([5137a646](https://github.com/firebase/flutterfire/commit/5137a6469fb57fb003757459222cb6c4e39fb0f8))
 - **FEAT**: Add support using Freezed classes as collection models ([#9483](https://github.com/firebase/flutterfire/issues/9483)). ([ce238f71](https://github.com/firebase/flutterfire/commit/ce238f713b250f523890b9e7e42d395f433ed80f))

## 1.0.0-dev.28

 - Update a dependency to the latest release.

## 1.0.0-dev.27

 - **FIX**: replace deprecated elements from analyzer ([#9366](https://github.com/firebase/flutterfire/issues/9366)). ([89c4c429](https://github.com/firebase/flutterfire/commit/89c4c4294dc6fb376caf74704abf738ec664f85f))

## 1.0.0-dev.26

 - Update a dependency to the latest release.

## 1.0.0-dev.25

 - Update a dependency to the latest release.

## 1.0.0-dev.24

> Note: This release has breaking changes.

 - **FEAT**: Add where(arrayContains) support ([#9167](https://github.com/firebase/flutterfire/issues/9167)). ([1a2f2262](https://github.com/firebase/flutterfire/commit/1a2f2262578c6230560761630d017637b99cbd6c))
 - **BREAKING** **FEAT**: The low-level interface of Queries/Document ([#9184](https://github.com/firebase/flutterfire/issues/9184)). ([fad4b0cd](https://github.com/firebase/flutterfire/commit/fad4b0cd0aa09e9161c64deeecf222c14603cd69))

## 1.0.0-dev.23

 - Update a dependency to the latest release.

## 1.0.0-dev.22

 - Update a dependency to the latest release.

## 1.0.0-dev.21

 - **FEAT**: add orderByFieldPath / whereFieldPath ([#8951](https://github.com/firebase/flutterfire/issues/8951)). ([5957c23b](https://github.com/firebase/flutterfire/commit/5957c23b44b235dab9d97449acb9c737da07b8e7))
 - **FEAT**: Add support for DateTime/Timestamp/GeoPoint ([#8563](https://github.com/firebase/flutterfire/issues/8563)). ([f2ea3696](https://github.com/firebase/flutterfire/commit/f2ea36964662d396dbc26bd931bb2662a5898168))
 - **FEAT**: add support for json_serializable's field rename/property ignore ([#9030](https://github.com/firebase/flutterfire/issues/9030)). ([81ec08fd](https://github.com/firebase/flutterfire/commit/81ec08fd64d57b4fbdc8e4fca39b5ab84dcc8669))

## 1.0.0-dev.20

 - Update a dependency to the latest release.

## 1.0.0-dev.19

 - **FEAT**: add whereDocumentId/orderByDocumentId (#8935). ([3769bcca](https://github.com/firebase/flutterfire/commit/3769bccadedc2c12228ec51dfb48561a23055370))

## 1.0.0-dev.18

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

## 1.0.0-dev.17

 - Update a dependency to the latest release.

## 1.0.0-dev.16

 - Update a dependency to the latest release.

## 1.0.0-dev.15

 - **FIX**: ODM should no-longer generates update/query functions for nested objects ([#8661](https://github.com/firebase/flutterfire/issues/8661)). ([84eeed2e](https://github.com/firebase/flutterfire/commit/84eeed2ec8da3aac87befd2028f8052005319730))
 - **FEAT**: Assert that collection.doc(id) does not point to a separate collection ([#8676](https://github.com/firebase/flutterfire/issues/8676)). ([0808205b](https://github.com/firebase/flutterfire/commit/0808205bdca03fc913015f00f5ffc2e1d018adb9))

## 1.0.0-dev.14

 - Update a dependency to the latest release.

## 1.0.0-dev.13

 - **FEAT**: upgrade analyzer, freezed_annotation and json_serializable dependencies (#8465). ([8a27ab21](https://github.com/firebase/flutterfire/commit/8a27ab21279d72998e80aa17b8ec39a9e4a08ec8))

## 1.0.0-dev.12

 - Update a dependency to the latest release.

## 1.0.0-dev.11

 - Update a dependency to the latest release.

## 1.0.0-dev.10

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 1.0.0-dev.9

 - **FIX**: Use descending in orderBy* (#8159). ([0b7b8811](https://github.com/firebase/flutterfire/commit/0b7b88117ac65a0ab164ffcaa0ca7fa69633fcb2))

## 1.0.0-dev.8

 - Update a dependency to the latest release.

## 1.0.0-dev.7

 - **FEAT**: Added error handling for when the Firestore reference and the Model class are defined in two separate files. (#7885). ([43cb91c9](https://github.com/firebase/flutterfire/commit/43cb91c9f22c7b61d7170305b9007c5beccfbdae))

## 1.0.0-dev.6

 - Update a dependency to the latest release.

## 1.0.0-dev.5

 - **FIX**: an issue where invalid code was generated when a model has no queryable fields (#7604).

## 1.0.0-dev.4

 - Update a dependency to the latest release.

## 1.0.0-dev.3

 - Update a dependency to the latest release.

## 1.0.0-dev.2

 - Update a dependency to the latest release.

## 1.0.0-dev.1

 * Initial preview release.

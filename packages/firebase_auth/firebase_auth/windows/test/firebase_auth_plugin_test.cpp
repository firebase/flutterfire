// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_auth_plugin.h"

#include <gtest/gtest.h>
#include <wincrypt.h>
#include <windows.h>

#include <string>

namespace firebase_auth_windows {
namespace test {
namespace {

std::string Token(const std::string& json) {
  DWORD length = 0;
  CryptBinaryToStringA(reinterpret_cast<const BYTE*>(json.data()),
                       static_cast<DWORD>(json.size()),
                       CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF, nullptr,
                       &length);
  std::string payload(length, '\0');
  CryptBinaryToStringA(reinterpret_cast<const BYTE*>(json.data()),
                       static_cast<DWORD>(json.size()),
                       CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF,
                       payload.data(), &length);
  payload.resize(length);
  while (!payload.empty() && payload.back() == '=') payload.pop_back();
  for (auto& c : payload) {
    if (c == '+') c = '-';
    if (c == '/') c = '_';
  }
  return "header." + payload + ".";
}

TEST(FirebaseAuthPlugin, ParsesIdTokenResult) {
  const auto token = Token(
      R"({"auth_time":1,"iat":2,"exp":3,"firebase":{"sign_in_provider":"custom","sign_in_second_factor":"phone"},"orgId":"test-org","roles":["reader",true,null,2,2.5],"unicode":"M\u00fcnchen \ud83d\ude00"})");
  const auto result = FirebaseAuthPlugin::ParseIdTokenResult(token);
  EXPECT_EQ(*result.token(), token);
  ASSERT_NE(result.claims(), nullptr);
  ASSERT_NE(result.auth_timestamp(), nullptr);
  ASSERT_NE(result.issued_at_timestamp(), nullptr);
  ASSERT_NE(result.expiration_timestamp(), nullptr);
  ASSERT_NE(result.sign_in_provider(), nullptr);
  ASSERT_NE(result.sign_in_second_factor(), nullptr);
  EXPECT_EQ(*result.auth_timestamp(), 1000);
  EXPECT_EQ(*result.issued_at_timestamp(), 2000);
  EXPECT_EQ(*result.expiration_timestamp(), 3000);
  EXPECT_EQ(*result.sign_in_provider(), "custom");
  EXPECT_EQ(*result.sign_in_second_factor(), "phone");
  const auto& claims = *result.claims();
  EXPECT_EQ(std::get<std::string>(claims.at(flutter::EncodableValue("orgId"))),
            "test-org");
  EXPECT_EQ(
      std::get<std::string>(claims.at(flutter::EncodableValue("unicode"))),
      "M\xc3\xbcnchen \xf0\x9f\x98\x80");
  EXPECT_EQ(std::get<flutter::EncodableList>(
                claims.at(flutter::EncodableValue("roles")))
                .size(),
            5);
}

TEST(FirebaseAuthPlugin, KeepsTokenWhenClaimsCannotBeDecoded) {
  for (const auto& token :
       {std::string("invalid"), std::string("header.!."), Token("[]"),
        Token("{"), Token("{\"x\":01}"), Token("{\"x\":\"\\ud800\"}")}) {
    const auto result = FirebaseAuthPlugin::ParseIdTokenResult(token);
    EXPECT_EQ(*result.token(), token);
    EXPECT_EQ(result.claims(), nullptr);
    EXPECT_EQ(result.auth_timestamp(), nullptr);
  }
}

TEST(FirebaseAuthPlugin, IgnoresMissingOrInvalidMetadata) {
  const auto result = FirebaseAuthPlugin::ParseIdTokenResult(Token(
      R"({"auth_time":"1","iat":9223372036854775807,"exp":null,"firebase":{"sign_in_provider":false},"ok":true})"));
  ASSERT_NE(result.claims(), nullptr);
  EXPECT_EQ(result.auth_timestamp(), nullptr);
  EXPECT_EQ(result.issued_at_timestamp(), nullptr);
  EXPECT_EQ(result.expiration_timestamp(), nullptr);
  EXPECT_EQ(result.sign_in_provider(), nullptr);
  EXPECT_EQ(result.sign_in_second_factor(), nullptr);
}

}  // namespace
}  // namespace test
}  // namespace firebase_auth_windows

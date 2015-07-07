library firebase.test.jwt;

import 'package:firebase/src/jwt.dart';
import 'package:test/test.dart';

import 'test_shared.dart';

void main() {
  // inputs from http://jwt.io/ with appreciation
  test('create a JWT token', () {
    const header = const {"alg": "HS256", "typ": "JWT"};

    const payload = const {
      "sub": "1234567890",
      "name": "John Doe",
      "admin": true
    };

    const secret = 'secret';

    var newToken = createJwtToken(header, payload, secret);

    const expectedSecret = 'TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ';

    const encodedSections = const <String>[
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9',
      expectedSecret
    ];

    expect(newToken, encodedSections.join('.'));
  });

  test('create a Firebase JWT token', () {
    var token = createFirebaseJwtToken(INVALID_AUTH_TOKEN,
        issuedAtTime: new DateTime.utc(1981, 6, 5));

    var tokenSections = token.split('.');

    expect(tokenSections, [
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      'eyJ2IjowLCJpYXQiOjM2MDU0NzIwMCwiZCI6e319',
      'g3eAUCtVsOq--HknT38L06iTuIWGOL-aI9BIx-PnDqM'
    ]);
  });
}

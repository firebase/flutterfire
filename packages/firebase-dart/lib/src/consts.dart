library firebase.consts;

/// All of these are invalid characters for a Firebase key except `*`.
///
/// `*` is in this list because it is used to escape.
const invalidFirebaseKeyCharsAndStar = const <String>[
  '.',
  '#',
  r'$',
  '/',
  '[',
  ']',
  encodeChar
];

const encodeChar = '*';

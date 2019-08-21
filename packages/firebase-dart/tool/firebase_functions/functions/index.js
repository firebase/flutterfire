'use strict';

const functions = require('firebase-functions');

exports.helloWorld = functions.https.onCall((data) => {
  const text = data.text;

  return {
    text: 'hello world, ' + text
  };
});

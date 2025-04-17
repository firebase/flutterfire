import * as assert from 'assert';
import * as functions from 'firebase-functions';
import * as functionsv2 from 'firebase-functions/v2';


// For example app.
// noinspection JSUnusedGlobalSymbols
export const listFruit = functions.https.onCall(() => {
  return ['Apple', 'Banana', 'Cherry', 'Date', 'Fig', 'Grapes'];
});

export const listfruits2ndgen = functionsv2.https.onCall((res, req) => {
  const fruitList = ['Apple', 'Banana', 'Cherry', 'Date', 'Fig', 'Grapes'];
  const allFruits = fruitList.map(async (fruit) => {
    if (res.acceptsStreaming) {
      req?.sendChunk(fruit)
    }
  })
  return Promise.all(allFruits);
});

// For e2e testing a custom region.
// noinspection JSUnusedGlobalSymbols

export const testFunctionCustomRegion = functions.https.onCall(
  {
    region: 'europe-west1'
  },
  () => 'europe-west1'
);

// For e2e testing timeouts.
export const testFunctionTimeout = functions.https.onCall((req, res) => {
  const data = req.data
  console.log(JSON.stringify({ data }));

  const timeoutMs = parseInt(data?.testTimeout, 10);

  if (isNaN(timeoutMs)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'testTimeout must be provided.'
    );
  }

  if (req.acceptsStreaming) {
    setTimeout(() => {
      res?.sendChunk({ timeLimit: 'exceeded' });
    }, timeoutMs);

    return new Promise((resolve) => {
      setTimeout(resolve, timeoutMs + 100);
    });
  }

  return new Promise((resolve) => {
    setTimeout(() => resolve({ timeLimit: 'exceeded' }), timeoutMs);
  });

});

// For e2e testing errors & return values.
// noinspection JSUnusedGlobalSymbols
export const testFunctionDefaultRegion = functions.https.onCall((req, res) => {
  const data = req.data;
  console.log(JSON.stringify({ data }));

  const sendResponse = (value: any) => {
    if (req.acceptsStreaming && res) {
      res.sendChunk(value);
      return value;
    }
    return value;
  };

  if (typeof data === 'string') {
    return sendResponse('string');
  }

  if (typeof data === 'number') {
    return sendResponse('number');
  }

  if (typeof data === 'boolean') {
    return sendResponse('boolean');
  }

  if (data === null) {
    return sendResponse('null');
  }

  if (Array.isArray(data)) {
    return sendResponse('array');
  }

  if (data.type === 'rawData') {
    return sendResponse(data);
  }

  const sampleData: {
    [key: string]: any;
  } = {
    number: 1234,
    string: 'acde',
    boolean: true,
    null: null,
    map: {
      number: 1234,
      string: 'acde',
      boolean: true,
      null: null,
    },
    list: [1234, 'acde', true, null],
    deepMap: {
      number: 123,
      string: 'foo',
      booleanTrue: true,
      booleanFalse: false,
      null: null,
      list: ['1', 2, true, false],
      map: {
        number: 123,
        string: 'foo',
        booleanTrue: true,
        booleanFalse: false,
        null: null,
      },
    },
    deepList: [
      '1',
      2,
      true,
      false,
      ['1', 2, true, false],
      {
        number: 123,
        string: 'foo',
        booleanTrue: true,
        booleanFalse: false,
        null: null,
      },
    ],
  };

  const {
    type,
    asError,
    inputData,
  }: {
    type: string;
    asError?: boolean;
    inputData?: any;
  } = data;
  if (!Object.hasOwnProperty.call(sampleData, type)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid test requested.'
    );
  }

  const outputData = sampleData[type];

  try {
    assert.deepEqual(outputData, inputData);
  } catch (e) {
    console.error(e);
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Input and Output types did not match.',
      (e as any).message
    );
  }

  // all good
  if (asError) {
    throw new functions.https.HttpsError(
      'cancelled',
      'Response data was requested to be sent as part of an Error payload, so here we are!',
      outputData
    );
  }

  return sendResponse(outputData);
});

export const testMapConvertType = functions.https.onCall((data) => ({
  foo: 'bar',
}));

export const testStream = functions.https.onCall((req, res) => {
  const data = req.data;
  if (data === null || undefined) {
    if (req.acceptsStreaming) {
      res?.sendChunk('null');
    }
    return
  }

  const results = [];
  results.push(data)

  const allResults = results.map(async (result) => {
    if (req.acceptsStreaming) {
      res?.sendChunk(result);
    }
    return result;
  });
  return Promise.all(allResults);
})

export const testStreamResponse = functions.https.onCall(async (request, response) => {
  const fruits = ['Apple', 'Mango', 'Banana']

  const allFruits = fruits.map(async (fruit) => {
    // Stream each fruit as it resolves!
    if (request.acceptsStreaming) {
      response?.sendChunk(fruit);
    }
    return fruit;
  });

  // Fallback for non-streaming clients
  return Promise.all(allFruits);
});
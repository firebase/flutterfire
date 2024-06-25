const { getDataConnect, queryRef, executeQuery, mutationRef, executeMutation } = require('firebase/data-connect');

const connectorConfig = {
  connector: 'movies',
  service: 'dataconnect',
  location: 'us-central1'
};
exports.connectorConfig = connectorConfig;

function addMovieRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'addMovie', inputVars);
}
exports.addMovieRef = addMovieRef;
exports.addMovie = function addMovie(dcOrVars, vars) {
  return executeMutation(addMovieRef(dcOrVars, vars));
};

function listMoviesRef(dc) {
  const { dc: dcInstance} = validateArgs(dc, undefined);
  return queryRef(dcInstance, 'listMovies');
}
exports.listMoviesRef = listMoviesRef;
exports.listMovies = function listMovies(dc) {
  return executeQuery(listMoviesRef(dc));
};

function validateArgs(dcOrVars, vars, validateVars) {
  let dcInstance;
  let realVars;
  // TODO(mtewani); Check what happens if this is undefined.
  if(dcOrVars && 'dataConnectOptions' in dcOrVars) {
      dcInstance = dcOrVars;
      realVars = vars;
  } else {
      dcInstance = getDataConnect(connectorConfig);
      realVars = dcOrVars;
  }
  if(!dcInstance || (!realVars && validateVars)) {
      throw new Error('You didn\t pass in the vars!');
  }
  return { dc: dcInstance, vars: realVars };
}
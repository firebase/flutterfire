const { getDataConnect, queryRef, mutationRef, executeQuery, executeMutation } = require('firebase/data-connect');

exports.connectorConfig = {
  connector: 'movies',
  service: 'dataconnect',
  location: 'us-central1'
};

exports.addMovie = function addMovieRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'addMovie', inputVars);
}
exports.addMovie = function addMovie(dcOrVars, vars) {
  return executeMutation(addMovieRef(dcOrVars, vars));
}

exports.testMovie = function testMovieRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'testMovie', inputVars);
}
exports.testMovie = function testMovie(dcOrVars, vars) {
  return executeMutation(testMovieRef(dcOrVars, vars));
}

exports.listAllMovies = function listAllMoviesRef(dc) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dc, undefined, );
  return queryRef(dcInstance, 'listAllMovies');
}
exports.listAllMovies = function listAllMovies(dc) {
  return executeQuery(listAllMoviesRef(dc));
}

exports.listMovieIds = function listMovieIdsRef(dc) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dc, undefined, );
  return queryRef(dcInstance, 'listMovieIds');
}
exports.listMovieIds = function listMovieIds(dc) {
  return executeQuery(listMovieIdsRef(dc));
}



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
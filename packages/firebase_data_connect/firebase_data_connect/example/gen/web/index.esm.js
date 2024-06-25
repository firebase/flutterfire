import { getDataConnect, queryRef, mutationRef, executeQuery, executeMutation } from 'firebase/data-connect';

export const connectorConfig = {
  connector: 'movies-angular',
  service: 'dataconnect',
  location: 'us-central1'
};

export function addMovieRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'addMovie', inputVars);
}
export function addMovie(dcOrVars, vars) {
  return executeMutation(addMovieRef(dcOrVars, vars));
}


export function testMovieRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'testMovie', inputVars);
}
export function testMovie(dcOrVars, vars) {
  return executeMutation(testMovieRef(dcOrVars, vars));
}


export function listAllMoviesRef(dc) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dc, undefined, );
  return queryRef(dcInstance, 'listAllMovies');
}
export function listAllMovies(dc) {
  return executeQuery(listAllMoviesRef(dc));
}


export function listMovieIdsRef(dc) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dc, undefined, );
  return queryRef(dcInstance, 'listMovieIds');
}
export function listMovieIds(dc) {
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

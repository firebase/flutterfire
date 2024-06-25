import { getDataConnect, queryRef, executeQuery, mutationRef, executeMutation } from 'firebase/data-connect';

export const connectorConfig = {
  connector: 'movies',
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
export function listMoviesRef(dc) {
  const { dc: dcInstance} = validateArgs(dc, undefined);
  return queryRef(dcInstance, 'listMovies');
}
export function listMovies(dc) {
  return executeQuery(listMoviesRef(dc));
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
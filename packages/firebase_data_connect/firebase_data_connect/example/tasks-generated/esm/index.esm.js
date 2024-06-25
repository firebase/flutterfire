import { getDataConnect, queryRef, executeQuery, mutationRef, executeMutation } from 'firebase/data-connect';

export const connectorConfig = {
  connector: 'tasks',
  service: 'task-service',
  location: 'us-central1'
};

export function listTasksRef(dc) {
  const { dc: dcInstance} = validateArgs(dc, undefined);
  return queryRef(dcInstance, 'listTasks');
}
export function listTasks(dc) {
  return executeQuery(listTasksRef(dc));
}
export function listTasksForTodayRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars);
  return queryRef(dcInstance, 'listTasksForToday', inputVars);
}
export function listTasksForToday(dcOrVars, vars) {
  return executeQuery(listTasksForTodayRef(dcOrVars, vars));
}
export function createTaskRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'createTask', inputVars);
}
export function createTask(dcOrVars, vars) {
  return executeMutation(createTaskRef(dcOrVars, vars));
}
export function toggleCompletedRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'toggleCompleted', inputVars);
}
export function toggleCompleted(dcOrVars, vars) {
  return executeMutation(toggleCompletedRef(dcOrVars, vars));
}
export function removeTaskRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars);
  return mutationRef(dcInstance, 'removeTask', inputVars);
}
export function removeTask(dcOrVars, vars) {
  return executeMutation(removeTaskRef(dcOrVars, vars));
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
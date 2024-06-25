const { getDataConnect, queryRef, executeQuery, mutationRef, executeMutation } = require('firebase/data-connect');

const connectorConfig = {
  connector: 'tasks',
  service: 'task-service',
  location: 'us-central1'
};
exports.connectorConfig = connectorConfig;

function listTasksRef(dc) {
  const { dc: dcInstance} = validateArgs(dc, undefined);
  return queryRef(dcInstance, 'listTasks');
}
exports.listTasksRef = listTasksRef;
exports.listTasks = function listTasks(dc) {
  return executeQuery(listTasksRef(dc));
};

function listTasksForTodayRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars);
  return queryRef(dcInstance, 'listTasksForToday', inputVars);
}
exports.listTasksForTodayRef = listTasksForTodayRef;
exports.listTasksForToday = function listTasksForToday(dcOrVars, vars) {
  return executeQuery(listTasksForTodayRef(dcOrVars, vars));
};

function createTaskRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'createTask', inputVars);
}
exports.createTaskRef = createTaskRef;
exports.createTask = function createTask(dcOrVars, vars) {
  return executeMutation(createTaskRef(dcOrVars, vars));
};

function toggleCompletedRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars, true);
  return mutationRef(dcInstance, 'toggleCompleted', inputVars);
}
exports.toggleCompletedRef = toggleCompletedRef;
exports.toggleCompleted = function toggleCompleted(dcOrVars, vars) {
  return executeMutation(toggleCompletedRef(dcOrVars, vars));
};

function removeTaskRef(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars} = validateArgs(dcOrVars, vars);
  return mutationRef(dcInstance, 'removeTask', inputVars);
}
exports.removeTaskRef = removeTaskRef;
exports.removeTask = function removeTask(dcOrVars, vars) {
  return executeMutation(removeTaskRef(dcOrVars, vars));
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
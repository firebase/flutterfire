import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, MutationRef, MutationPromise } from 'firebase/data-connect';
export const connectorConfig: ConnectorConfig;

export type TimestampString = string;

export type UUIDString = string;

export type Int64String = string;

export type DateString = string;


export interface CreateTaskResponse {
  task_insert: Task_Key;
}

export interface CreateTaskVariables {
  description: string;
  date: DateString;
}

export interface ListTasksForTodayResponse {
  tasks: ({
    id: UUIDString;
    description: string;
    completed: boolean;
    date: DateString;
    owner: string;
  } & Task_Key)[];
}

export interface ListTasksForTodayVariables {
  day?: DateString;
}

export interface ListTasksResponse {
  tasks: ({
    description: string;
    id: UUIDString;
    completed: boolean;
    owner: string;
    date: DateString;
  } & Task_Key)[];
}

export interface RemoveTaskResponse {
  task_delete?: Task_Key | null;
}

export interface RemoveTaskVariables {
  id?: UUIDString | null;
}

export interface Task_Key {
  id: UUIDString;
  __typename?: 'Task_Key';
}

export interface ToggleCompletedResponse {
  task_update?: Task_Key | null;
}

export interface ToggleCompletedVariables {
  id: UUIDString;
  completed: boolean;
}



/* Allow users to create refs without passing in DataConnect */
export function listTasksRef(): QueryRef<ListTasksResponse, undefined>;/* Allow users to pass in custom DataConnect instances */
export function listTasksRef(dc: DataConnect): QueryRef<ListTasksResponse,undefined>;

export function listTasks(): QueryPromise<ListTasksResponse, undefined>;
export function listTasks(dc: DataConnect): QueryPromise<ListTasksResponse,undefined>;


/* Allow users to create refs without passing in DataConnect */
export function listTasksForTodayRef(vars?: ListTasksForTodayVariables): QueryRef<ListTasksForTodayResponse, ListTasksForTodayVariables>;
/* Allow users to pass in custom DataConnect instances */
export function listTasksForTodayRef(dc: DataConnect, vars?: ListTasksForTodayVariables): QueryRef<ListTasksForTodayResponse,ListTasksForTodayVariables>;

export function listTasksForToday(vars?: ListTasksForTodayVariables): QueryPromise<ListTasksForTodayResponse, ListTasksForTodayVariables>;
export function listTasksForToday(dc: DataConnect, vars?: ListTasksForTodayVariables): QueryPromise<ListTasksForTodayResponse,ListTasksForTodayVariables>;


/* Allow users to create refs without passing in DataConnect */
export function createTaskRef(vars: CreateTaskVariables): MutationRef<CreateTaskResponse, CreateTaskVariables>;
/* Allow users to pass in custom DataConnect instances */
export function createTaskRef(dc: DataConnect, vars: CreateTaskVariables): MutationRef<CreateTaskResponse,CreateTaskVariables>;

export function createTask(vars: CreateTaskVariables): MutationPromise<CreateTaskResponse, CreateTaskVariables>;
export function createTask(dc: DataConnect, vars: CreateTaskVariables): MutationPromise<CreateTaskResponse,CreateTaskVariables>;


/* Allow users to create refs without passing in DataConnect */
export function toggleCompletedRef(vars: ToggleCompletedVariables): MutationRef<ToggleCompletedResponse, ToggleCompletedVariables>;
/* Allow users to pass in custom DataConnect instances */
export function toggleCompletedRef(dc: DataConnect, vars: ToggleCompletedVariables): MutationRef<ToggleCompletedResponse,ToggleCompletedVariables>;

export function toggleCompleted(vars: ToggleCompletedVariables): MutationPromise<ToggleCompletedResponse, ToggleCompletedVariables>;
export function toggleCompleted(dc: DataConnect, vars: ToggleCompletedVariables): MutationPromise<ToggleCompletedResponse,ToggleCompletedVariables>;


/* Allow users to create refs without passing in DataConnect */
export function removeTaskRef(vars?: RemoveTaskVariables): MutationRef<RemoveTaskResponse, RemoveTaskVariables>;
/* Allow users to pass in custom DataConnect instances */
export function removeTaskRef(dc: DataConnect, vars?: RemoveTaskVariables): MutationRef<RemoveTaskResponse,RemoveTaskVariables>;

export function removeTask(vars?: RemoveTaskVariables): MutationPromise<RemoveTaskResponse, RemoveTaskVariables>;
export function removeTask(dc: DataConnect, vars?: RemoveTaskVariables): MutationPromise<RemoveTaskResponse,RemoveTaskVariables>;



import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, MutationRef, MutationPromise } from 'firebase/data-connect';
export const connectorConfig: ConnectorConfig;

export type TimestampString = string;

export type UUIDString = string;

export type Int64String = string;

export type DateString = string;


export interface AddMovieResponse {
  movie_insert: Movie_Key;
}

export interface AddMovieVariables {
  genre: string;
  title: string;
  rating?: number | null;
}

export interface ListMoviesResponse {
  movies: ({
    id: UUIDString;
    genre: string;
    title: string;
    rating: number;
  } & Movie_Key)[];
}

export interface Movie_Key {
  id: UUIDString;
  __typename?: 'Movie_Key';
}



/* Allow users to create refs without passing in DataConnect */
export function addMovieRef(vars: AddMovieVariables): MutationRef<AddMovieResponse, AddMovieVariables>;
/* Allow users to pass in custom DataConnect instances */
export function addMovieRef(dc: DataConnect, vars: AddMovieVariables): MutationRef<AddMovieResponse,AddMovieVariables>;

export function addMovie(vars: AddMovieVariables): MutationPromise<AddMovieResponse, AddMovieVariables>;
export function addMovie(dc: DataConnect, vars: AddMovieVariables): MutationPromise<AddMovieResponse,AddMovieVariables>;


/* Allow users to create refs without passing in DataConnect */
export function listMoviesRef(): QueryRef<ListMoviesResponse, undefined>;/* Allow users to pass in custom DataConnect instances */
export function listMoviesRef(dc: DataConnect): QueryRef<ListMoviesResponse,undefined>;

export function listMovies(): QueryPromise<ListMoviesResponse, undefined>;
export function listMovies(dc: DataConnect): QueryPromise<ListMoviesResponse,undefined>;



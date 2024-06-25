import { ConnectorConfig, DataConnect, getDataConnect, QueryRef, MutationRef, QueryPromise, MutationPromise } from 'firebase/data-connect';
export const connectorConfig: ConnectorConfig;


export interface AddMovieResponse {
  
   
   movie_insert: Movie_Key;
    

  
}


export interface AddMovieVariables {
  
   
   name: string;
    
   
   genre: string;
    
   
   description: string;
    

  
}


export interface ListAllMoviesResponse {
  
   
   movies:  {
      
   
   id: string;
    
   
   name: string;
    
   
   genre: string;
    
   
   description: string;
    
   
   release:  {
      

    };
    
    

    }& Movie_Key[];
    
    

  
}


export interface ListMovieIdsResponse {
  
   
   movies:  {
      
   
   id: string;
    

    }& Movie_Key[];
    
    

  
}


export interface Movie_Key {
  
   
   id: string;
    

  
  __typename?: 'Movie_Key';
  
}


export interface TestMovieResponse {
  
   
   movie_update: Movie_Key;
    

  
}


export interface TestMovieVariables {
  
   
   key: Movie_Key;
    
   
   description: string;
    

  
}





export function addMovieRef(dc: DataConnect, vars: AddMovieVariables): MutationRef<AddMovieResponse,AddMovieVariables>;
export function addMovieRef(vars: AddMovieVariables): MutationRef<AddMovieResponse, AddMovieVariables>;

export function addMovie(dc: DataConnect, vars: AddMovieVariables): MutationPromise<AddMovieResponse,AddMovieVariables>;
export function addMovie(vars: AddMovieVariables): MutationPromise<AddMovieResponse, AddMovieVariables>;



export function testMovieRef(dc: DataConnect, vars: TestMovieVariables): MutationRef<TestMovieResponse,TestMovieVariables>;
export function testMovieRef(vars: TestMovieVariables): MutationRef<TestMovieResponse, TestMovieVariables>;

export function testMovie(dc: DataConnect, vars: TestMovieVariables): MutationPromise<TestMovieResponse,TestMovieVariables>;
export function testMovie(vars: TestMovieVariables): MutationPromise<TestMovieResponse, TestMovieVariables>;



export function listAllMoviesRef(dc: DataConnect): QueryRef<ListAllMoviesResponse,undefined>;

export function listAllMoviesRef(): QueryRef<ListAllMoviesResponse, undefined>;


export function listAllMovies(dc: DataConnect): QueryPromise<ListAllMoviesResponse,undefined>;

export function listAllMovies(): QueryPromise<ListAllMoviesResponse, undefined>;




export function listMovieIdsRef(dc: DataConnect): QueryRef<ListMovieIdsResponse,undefined>;

export function listMovieIdsRef(): QueryRef<ListMovieIdsResponse, undefined>;


export function listMovieIds(dc: DataConnect): QueryPromise<ListMovieIdsResponse,undefined>;

export function listMovieIds(): QueryPromise<ListMovieIdsResponse, undefined>;






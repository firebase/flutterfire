part of movies;







class AddDirectorToMovie {
  String name = "addDirectorToMovie";
  AddDirectorToMovie({required this.dataConnect});

  Deserializer<AddDirectorToMovieData> dataDeserializer = (String json) =>
      AddDirectorToMovieData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddDirectorToMovieVariables> varsSerializer =
      (AddDirectorToMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddDirectorToMovieData, AddDirectorToMovieVariables> ref({
    AddDirectorToMovieVariablesPersonId? personId,
    String? movieId,
  }) {
    AddDirectorToMovieVariables vars = AddDirectorToMovieVariables(
      personId: personId,
      movieId: movieId,
    );

    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

    return dataConnect.mutation(this.name, dataDeserializer, varsSerializer, vars);
  }
  FirebaseDataConnect dataConnect;
}


  


class AddDirectorToMovieDirectedByInsert {
  
    
    
    
   late  String directedbyId;
   
  
    
    
    
   late  String movieId;
   
  
  
    AddDirectorToMovieDirectedByInsert.fromJson(Map<String, dynamic> json):
          directedbyId = 
            json['directedbyId'],
    
          movieId = 
            json['movieId']
     {
      
        
      
        
      
    }


  // TODO: Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['directedbyId'] = 
  
    directedbyId
  
;
      
    
      
      json['movieId'] = 
  
    movieId
  
;
      
    
    return json;
  }

  AddDirectorToMovieDirectedByInsert({
    
    required this.directedbyId,
  
    required this.movieId,
  }) {
    // TODO: Only show this if there are optional fields.
  }

}

class AddDirectorToMovieData {
  late AddDirectorToMovieDirectedByInsert directedBy_insert;

  AddDirectorToMovieData.fromJson(Map<String, dynamic> json)
      : directedBy_insert = AddDirectorToMovieDirectedByInsert.fromJson(
            json['directedBy_insert']) {}

  // TODO: Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['directedBy_insert'] = 
  
    directedBy_insert.toJson()
  
;
      
    
    return json;
  }

  AddDirectorToMovieData({
    required this.directedBy_insert,
  }) {
    // TODO: Only show this if there are optional fields.
  }

}




  


class AddDirectorToMovieVariablesPersonId {
  
    
    
    
   late  String id;
   
  
  
    AddDirectorToMovieVariablesPersonId.fromJson(Map<String, dynamic> json):
          id = 
            json['id']
     {
      
        
      
    }


  // TODO: Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    id
  
;
      
    
    return json;
  }

  AddDirectorToMovieVariablesPersonId({
    
    required this.id,
  }) {
    // TODO: Only show this if there are optional fields.
  }

}




  


class AddDirectorToMovieVariables {
  
    
    
    
   late  AddDirectorToMovieVariablesPersonId? personId;
   
  
    
    
    
   late  String? movieId;
   
  
  
    AddDirectorToMovieVariables.fromJson(Map<String, dynamic> json):
          personId = 
            AddDirectorToMovieVariablesPersonId.fromJson(json['personId'])
          ,
    
          movieId = 
            json['movieId']
     {
      
        
      
        
      
    }


  // TODO: Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
        if (personId != null) {
          json['personId'] = 
  
    personId!.toJson()
  
;
        }
      
    
      
        if (movieId != null) {
          json['movieId'] = 
  
    movieId
  
;
        }
      
    
    return json;
  }

  AddDirectorToMovieVariables({
    this.personId,
    this.movieId,
  }) {
    // TODO: Only show this if there are optional fields.
  }

}







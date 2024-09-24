part of movies;







class DeleteMovie {
  String name = "deleteMovie";
  DeleteMovie({required this.dataConnect});

  Deserializer<DeleteMovieData> dataDeserializer = (String json) =>
      DeleteMovieData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<DeleteMovieVariables> varsSerializer =
      (DeleteMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<DeleteMovieData, DeleteMovieVariables> ref({
    required String id,
  }) {
    DeleteMovieVariables vars = DeleteMovieVariables(
      id: id,
    );

    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

    return dataConnect.mutation(this.name, dataDeserializer, varsSerializer, vars);
  }
  FirebaseDataConnect dataConnect;
}


  


class DeleteMovieMovieDelete {
  
    
    
    
   late  String id;
   
  
  
    DeleteMovieMovieDelete.fromJson(Map<String, dynamic> json):
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

  DeleteMovieMovieDelete({
    
    required this.id,
  }) {
    // TODO: Only show this if there are optional fields.
  }

}

class DeleteMovieData {
  late DeleteMovieMovieDelete? movie_delete;

  DeleteMovieData.fromJson(Map<String, dynamic> json)
      : movie_delete = DeleteMovieMovieDelete.fromJson(json['movie_delete']) {}

  // TODO: Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
        if (movie_delete != null) {
          json['movie_delete'] = 
  
    movie_delete!.toJson()
  
;
        }
      
    
    return json;
  }

  DeleteMovieData({
    this.movie_delete,
  }) {
    // TODO: Only show this if there are optional fields.
  }

}




  


class DeleteMovieVariables {
  
    
    
    
   late  String id;
   
  
  
    DeleteMovieVariables.fromJson(Map<String, dynamic> json):
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

  DeleteMovieVariables({
    
    required this.id,
  }) {
    // TODO: Only show this if there are optional fields.
  }

}







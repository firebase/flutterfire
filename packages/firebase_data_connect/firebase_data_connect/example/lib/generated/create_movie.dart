part of movies;







class CreateMovie {
  String name = "createMovie";
  CreateMovie({required this.dataConnect});

  Deserializer<CreateMovieData> dataDeserializer = (String json)  => CreateMovieData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<CreateMovieVariables> varsSerializer = (CreateMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<CreateMovieData, CreateMovieVariables> ref(
      {required String title,required int releaseYear,required String genre,double? rating,String? description,}) {
    CreateMovieVariables vars=CreateMovieVariables(title: title,releaseYear: releaseYear,genre: genre,rating: rating,description: description,);

    return dataConnect.mutation(this.name, dataDeserializer, varsSerializer, vars);
  }
  FirebaseDataConnect dataConnect;
}


  


class CreateMovieMovieInsert {
  
    
    
    
   String id;

   
  
  
    CreateMovieMovieInsert.fromJson(Map<String, dynamic> json):
        id = 
 
    nativeFromJson<String>(json['id'])
  

        
       {
      
        
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    nativeToJson<String>(id)
    
;
      
    
    return json;
  }

  CreateMovieMovieInsert({
    
    required this.id,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}



  


class CreateMovieData {
  
    
    
    
   CreateMovieMovieInsert movie_insert;

   
  
  
    CreateMovieData.fromJson(Map<String, dynamic> json):
        movie_insert = 
 
    CreateMovieMovieInsert.fromJson(json['movie_insert'])
  

        
       {
      
        
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['movie_insert'] = 
  
      movie_insert.toJson()
  
;
      
    
    return json;
  }

  CreateMovieData({
    
    required this.movie_insert,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}



  


class CreateMovieVariables {
  
    
    
    
   String title;

   
  
    
    
    
   int releaseYear;

   
  
    
    
    
   String genre;

   
  
    
    
    
   double? rating;

   
  
    
    
    
   String? description;

   
  
  
    CreateMovieVariables.fromJson(Map<String, dynamic> json):
        title = 
 
    nativeFromJson<String>(json['title'])
  

        ,
      
        releaseYear = 
 
    nativeFromJson<int>(json['releaseYear'])
  

        ,
      
        genre = 
 
    nativeFromJson<String>(json['genre'])
  

        
       {
      
        
      
        
      
        
      
        
          rating = json['rating'] == null ? null : 
 
    nativeFromJson<double>(json['rating'])
  
;
        
      
        
          description = json['description'] == null ? null : 
 
    nativeFromJson<String>(json['description'])
  
;
        
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['title'] = 
  
    nativeToJson<String>(title)
    
;
      
    
      
      json['releaseYear'] = 
  
    nativeToJson<int>(releaseYear)
    
;
      
    
      
      json['genre'] = 
  
    nativeToJson<String>(genre)
    
;
      
    
      
        if (rating != null) {
          json['rating'] = 
  
    nativeToJson<double?>(rating)
    
;
        }
      
    
      
        if (description != null) {
          json['description'] = 
  
    nativeToJson<String?>(description)
    
;
        }
      
    
    return json;
  }

  CreateMovieVariables({
    
    required this.title,
  
    required this.releaseYear,
  
    required this.genre,
  
     this.rating,
  
     this.description,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
      
    
      
    
      
    
      
    
  }
}








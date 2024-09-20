part of movies;







class ListPersons {
  String name = "ListPersons";
  ListPersons({required this.dataConnect});

  Deserializer<ListPersonsResponse> dataDeserializer = (String json)  => ListPersonsResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  
  QueryRef<ListPersonsResponse, void> ref(
      ) {
    
    return dataConnect.query(this.name, dataDeserializer, null, null);
  }
  FirebaseDataConnect dataConnect;
}


  


class ListPersonsPeople {
  
    
    
    
   late  String id;
   
  
    
    
    
   late  String name;
   
  
  
    ListPersonsPeople.fromJson(Map<String, dynamic> json):
          id = 
            json['id'],
        
    
          name = 
            json['name']
        
     {
      
        
      
        
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    id
  
;
      
    
      
      json['name'] = 
  
    name
  
;
      
    
    return json;
  }

  ListPersonsPeople({
    
    required this.id,
  
    required this.name,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
      
    
  }

}




  


class ListPersonsResponse {
  
    
    
    
   late List<ListPersonsPeople> people;
   
  
  
    ListPersonsResponse.fromJson(Map<String, dynamic> json):
          people = 
            (json['people'] as List<dynamic>)
              .map((e) => ListPersonsPeople.fromJson(e))
              .toList()
          
        
     {
      
        
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['people'] = 
  
    people.map((e) => e.toJson()).toList()
  
;
      
    
    return json;
  }

  ListPersonsResponse({
    
    required this.people,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }

}







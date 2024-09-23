part of movies;







class ListPersons {
  String name = "ListPersons";
  ListPersons({required this.dataConnect});

  Deserializer<ListPersonsData> dataDeserializer = (String json)  => ListPersonsData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  
  QueryRef<ListPersonsData, void> ref(
      ) {
    
    return dataConnect.query(this.name, dataDeserializer, emptySerializer, null);
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




  


class ListPersonsData {
  
    
    
    
   late List<ListPersonsPeople> people;
   
  
  
    ListPersonsData.fromJson(Map<String, dynamic> json):
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

  ListPersonsData({
    
    required this.people,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }

}







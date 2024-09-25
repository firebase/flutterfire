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
  
    
    
    
   String id;

   
  
    
    
    
   String name;

   
  
  
    ListPersonsPeople.fromJson(Map<String, dynamic> json):
        id = 
 
    nativeFromJson<String>(json['id'])
  

        ,
      
        name = 
 
    nativeFromJson<String>(json['name'])
  

        
       {
      
        
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    nativeToJson<String>(id)
    
;
      
    
      
      json['name'] = 
  
    nativeToJson<String>(name)
    
;
      
    
    return json;
  }

  ListPersonsPeople({
    
    required this.id,
  
    required this.name,
  
  }) { // TODO: Only show this if there are optional fields.
    
      
    
      
    
  }
}



  


class ListPersonsData {
  
    
    
    
   List<ListPersonsPeople> people;

   
  
  
    ListPersonsData.fromJson(Map<String, dynamic> json):
        people = 
 
    
      (json['people'] as List<dynamic>)
        .map((e) => ListPersonsPeople.fromJson(e))
        .toList()
    
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['people'] = 
  
    
      people.map((e) => e.toJson()).toList()
    
  
;
      
    
    return json;
  }

  ListPersonsData({
    
    required this.people,
  
  }) { // TODO: Only show this if there are optional fields.
    
      
    
  }
}








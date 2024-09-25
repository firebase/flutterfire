part of movies;








class AddTimestamp {
  String name = "addTimestamp";
  AddTimestamp({required this.dataConnect});

  Deserializer<AddTimestampData> dataDeserializer = (String json)  => AddTimestampData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddTimestampVariables> varsSerializer = (AddTimestampVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddTimestampData, AddTimestampVariables> ref(
      {required Timestamp timestamp,}) {
    AddTimestampVariables vars=AddTimestampVariables(timestamp: timestamp,);

    return dataConnect.mutation(this.name, dataDeserializer, varsSerializer, vars);
  }
  FirebaseDataConnect dataConnect;
}


  


class AddTimestampTimestampHolderInsert {
  
    
    
    
   String id;

   
  
  
    AddTimestampTimestampHolderInsert.fromJson(Map<String, dynamic> json):
        id = 
 
    nativeFromJson<String>(json['id'])
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    nativeToJson<String>(id)
    
;
      
    
    return json;
  }

  AddTimestampTimestampHolderInsert({
    
    required this.id,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}



  


class AddTimestampData {
  
    
    
    
   AddTimestampTimestampHolderInsert timestampHolder_insert;

   
  
  
    AddTimestampData.fromJson(Map<String, dynamic> json):
        timestampHolder_insert = 
 
    AddTimestampTimestampHolderInsert.fromJson(json['timestampHolder_insert'])
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['timestampHolder_insert'] = 
  
      timestampHolder_insert.toJson()
  
;
      
    
    return json;
  }

  AddTimestampData({
    
    required this.timestampHolder_insert,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}



  


class AddTimestampVariables {
  
    
    
    
   Timestamp timestamp;

   
  
  
    AddTimestampVariables.fromJson(Map<String, dynamic> json):
        timestamp = 
 
    Timestamp.fromJson(json['timestamp'])
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['timestamp'] = 
  
      timestamp.toJson()
  
;
      
    
    return json;
  }

  AddTimestampVariables({
    
    required this.timestamp,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}








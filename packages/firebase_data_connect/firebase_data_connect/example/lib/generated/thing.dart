part of movies;








class Thing {
  String name = "thing";
  Thing({required this.dataConnect});

  Deserializer<ThingData> dataDeserializer = (String json)  => ThingData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<ThingVariables> varsSerializer = (ThingVariables vars) => jsonEncode(vars.toJson());
  MutationRef<ThingData, ThingVariables> ref(
      {dynamic title,}) {
    ThingVariables vars=ThingVariables(title: AnyValue(title),);

    return dataConnect.mutation(this.name, dataDeserializer, varsSerializer, vars);
  }
  FirebaseDataConnect dataConnect;
}


  


class ThingThingInsert {
  
    
    
    
   String id;

   
  
  
    ThingThingInsert.fromJson(Map<String, dynamic> json):
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

  ThingThingInsert({
    
    required this.id,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}



  


class ThingData {
  
    
    
    
   ThingThingInsert thing_insert;

   
  
  
    ThingData.fromJson(Map<String, dynamic> json):
        thing_insert = 
 
    ThingThingInsert.fromJson(json['thing_insert'])
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['thing_insert'] = 
  
      thing_insert.toJson()
  
;
      
    
    return json;
  }

  ThingData({
    
    required this.thing_insert,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}



  


class ThingVariables {
  
    
    
    
   Optional<AnyValue> _title = Optional.optional(AnyValue.fromJson, defaultSerializer);

   
    set title(AnyValue? t) {
      this._title.value = t;
    }
    AnyValue? get title => this._title.value;
   
  
  
    ThingVariables.fromJson(Map<String, dynamic> json) {
      
        
          _title.value = json['title'] == null ? null : 
 
    AnyValue.fromJson(json['title'])
  
;
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
        if(_title.state == OptionalState.set) {
          json['title'] = _title.toJson();
        }
     
    
    return json;
  }

  ThingVariables({
    
    
      
      AnyValue? title,
    
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
        
        
        this._title = Optional.optional(AnyValue.fromJson, defaultSerializer);
        this._title.value = title;
      
    
  }
}








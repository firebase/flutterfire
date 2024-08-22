// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of movies;







class AddPerson {
  String name = "addPerson";
  AddPerson({required this.dataConnect});

  Deserializer<AddPersonResponse> dataDeserializer = (String json)  => AddPersonResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddPersonVariables> varsSerializer = jsonEncode;
  MutationRef<AddPersonResponse, AddPersonVariables> ref(
      {String? name,AddPersonVariables?addPersonVariables}) {
    AddPersonVariables vars1=AddPersonVariables(name: name,);
AddPersonVariables vars = addPersonVariables ?? vars1;
    return dataConnect.mutation(this.name, dataDeserializer, varsSerializer, vars);
  }
  FirebaseDataConnect dataConnect;
}


  


class AddPersonPersonInsert {
  
    
    
    
   late  String id;
   
  
  
    AddPersonPersonInsert.fromJson(Map<String, dynamic> json):
          id = 
            json['id']
        
     {
      
         
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    id
  
;
      
    
    return json;
  }

  AddPersonPersonInsert({
    
    required this.id,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }

}




  


class AddPersonResponse {
  
    
    
    
   late  AddPersonPersonInsert person_insert;
   
  
  
    AddPersonResponse.fromJson(Map<String, dynamic> json):
          person_insert = 
            AddPersonPersonInsert.fromJson(json['person_insert'])
          
        
     {
      
         
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['person_insert'] = 
  
    person_insert.toJson()
  
;
      
    
    return json;
  }

  AddPersonResponse({
    
    required this.person_insert,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }

}




  


class AddPersonVariables {
  
    
    
    
   late  String? name;
   
  
  
    AddPersonVariables.fromJson(Map<String, dynamic> json):
          name = 
            json['name']
        
     {
      
         
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
        if (name != null) {
          json['name'] = 
  
    name
  
;
        }
      
    
    return json;
  }

  AddPersonVariables({
    
    
      
      String? name,
    
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }

}







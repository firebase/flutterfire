
@file:Suppress(
  "KotlinRedundantDiagnosticSuppress",
  "LocalVariableName",
  "RedundantVisibilityModifier",
  "RemoveEmptyClassBody",
  "SpellCheckingInspection",
  "LocalVariableName",
  "unused",
)

@file:UseSerializers(DateSerializer::class, UUIDSerializer::class, TimestampSerializer::class)

package com.myapplication

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationStrategy
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.serializer

import com.google.firebase.dataconnect.MutationRef
import com.google.firebase.dataconnect.MutationResult

import com.google.firebase.dataconnect.OptionalVariable
import com.google.firebase.dataconnect.generated.GeneratedMutation

import kotlinx.serialization.UseSerializers
import com.google.firebase.dataconnect.serializers.DateSerializer
import com.google.firebase.dataconnect.serializers.UUIDSerializer
import com.google.firebase.dataconnect.serializers.TimestampSerializer

public interface AddMovieMutation :
    GeneratedMutation<
      MoviesConnector,
      AddMovieMutation.Data,
      AddMovieMutation.Variables
    >
{
  
    @Serializable
  public data class Variables(
  
    val genre:
    String,
    val title:
    String,
    val rating:
    OptionalVariable<Double?>,
    val description:
    OptionalVariable<String?>
  ) {
    
    
      
      @DslMarker public annotation class BuilderDsl

      @BuilderDsl
      public interface Builder {
        public var genre: String
        public var title: String
        public var rating: Double?
        public var description: String?
        
      }

      public companion object {
        @Suppress("NAME_SHADOWING")
        public fun build(
          genre: String,title: String,
          block_: Builder.() -> Unit
        ): Variables {
          var genre= genre
            var title= title
            var rating: OptionalVariable<Double?> = OptionalVariable.Undefined
            var description: OptionalVariable<String?> = OptionalVariable.Undefined
            

          return object : Builder {
            override var genre: String
              get() = throw UnsupportedOperationException("getting builder values is not supported")
              set(value_) { genre = value_ }
              
            override var title: String
              get() = throw UnsupportedOperationException("getting builder values is not supported")
              set(value_) { title = value_ }
              
            override var rating: Double?
              get() = throw UnsupportedOperationException("getting builder values is not supported")
              set(value_) { rating = OptionalVariable.Value(value_) }
              
            override var description: String?
              get() = throw UnsupportedOperationException("getting builder values is not supported")
              set(value_) { description = OptionalVariable.Value(value_) }
              
            
          }.apply(block_)
          .let {
            Variables(
              genre=genre,title=title,rating=rating,description=description,
            )
          }
        }
      }
    
  }
  

  
    @Serializable
  public data class Data(
  @SerialName("movie_insert")
    val key:
    MovieKey
  ) {
    
    
  }
  

  public companion object {
    @Suppress("ConstPropertyName")
    public const val operationName: String = "addMovie"
    public val dataDeserializer: DeserializationStrategy<Data> = serializer()
    public val variablesSerializer: SerializationStrategy<Variables> = serializer()
  }
}

public fun AddMovieMutation.ref(
  
    genre: String,title: String,
  
    block_: AddMovieMutation.Variables.Builder.() -> Unit
  
): MutationRef<
    AddMovieMutation.Data,
    AddMovieMutation.Variables
  > =
  ref(
    
      AddMovieMutation.Variables.build(
        genre=genre,title=title,
  
    block_
      )
    
  )

public suspend fun AddMovieMutation.execute(
  
    genre: String,title: String,
  
    block_: AddMovieMutation.Variables.Builder.() -> Unit
  
  ): MutationResult<
    AddMovieMutation.Data,
    AddMovieMutation.Variables
  > =
  ref(
    
      genre=genre,title=title,
  
    block_
    
  ).execute()



// The lines below are used by the code generator to ensure that this file is deleted if it is no
// longer needed. Any files in this directory that contain the lines below will be deleted by the
// code generator if the file is no longer needed. If, for some reason, you do _not_ want the code
// generator to delete this file, then remove the line below (and this comment too, if you want).

// FIREBASE_DATA_CONNECT_GENERATED_FILE MARKER 42da5e14-69b3-401b-a9f1-e407bee89a78
// FIREBASE_DATA_CONNECT_GENERATED_FILE CONNECTOR movies

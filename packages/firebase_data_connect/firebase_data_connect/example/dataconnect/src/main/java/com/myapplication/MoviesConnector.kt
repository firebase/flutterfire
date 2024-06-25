
@file:Suppress(
  "KotlinRedundantDiagnosticSuppress",
  "LocalVariableName",
  "RedundantVisibilityModifier",
  "RemoveEmptyClassBody",
  "SpellCheckingInspection",
  "LocalVariableName",
  "unused",
)

package com.myapplication

import com.google.firebase.FirebaseApp
import com.google.firebase.dataconnect.ConnectorConfig
import com.google.firebase.dataconnect.DataConnectSettings
import com.google.firebase.dataconnect.FirebaseDataConnect
import com.google.firebase.dataconnect.generated.GeneratedConnector
import com.google.firebase.dataconnect.getInstance
import java.util.WeakHashMap

public interface MoviesConnector : GeneratedConnector {
  override val dataConnect: FirebaseDataConnect

  
    public val addMovie: AddMovieMutation
  
    public val listMovies: ListMoviesQuery
  

  public companion object {
    @Suppress("MemberVisibilityCanBePrivate")
    public val config: ConnectorConfig = ConnectorConfig(
      connector = "movies",
      location = "us-central1",
      serviceId = "dataconnect",
    )

    public fun getInstance(
      dataConnect: FirebaseDataConnect
    ):MoviesConnector = synchronized(instances) {
      instances.getOrPut(dataConnect) {
        MoviesConnectorImpl(dataConnect)
      }
    }

    private val instances = WeakHashMap<FirebaseDataConnect, MoviesConnectorImpl>()
  }
}

public val MoviesConnector.Companion.instance:MoviesConnector
  get() = getInstance(FirebaseDataConnect.getInstance(config))

public fun MoviesConnector.Companion.getInstance(
  settings: DataConnectSettings = DataConnectSettings()
):MoviesConnector =
  getInstance(FirebaseDataConnect.getInstance(config, settings))

public fun MoviesConnector.Companion.getInstance(
  app: FirebaseApp,
  settings: DataConnectSettings = DataConnectSettings()
):MoviesConnector =
  getInstance(FirebaseDataConnect.getInstance(app, config, settings))

private class MoviesConnectorImpl(
  override val dataConnect: FirebaseDataConnect
) : MoviesConnector {
  
    override val addMovie by lazy(LazyThreadSafetyMode.PUBLICATION) {
      AddMovieMutationImpl(this)
    }
  
    override val listMovies by lazy(LazyThreadSafetyMode.PUBLICATION) {
      ListMoviesQueryImpl(this)
    }
  

  override fun equals(other: Any?): Boolean = other === this

  override fun hashCode(): Int = System.identityHashCode(this)

  override fun toString() = "MoviesConnectorImpl(dataConnect=$dataConnect)"
}


  private class AddMovieMutationImpl(
    override val connector: MoviesConnectorImpl
  ) : AddMovieMutation {
  override val operationName by AddMovieMutation.Companion::operationName
  override val dataDeserializer by AddMovieMutation.Companion::dataDeserializer
  override val variablesSerializer by AddMovieMutation.Companion::variablesSerializer

  override fun equals(other: Any?): Boolean = other === this

  override fun hashCode(): Int = System.identityHashCode(this)

  override fun toString() = "AddMovieMutationImpl(" +
    "operationName=$operationName, " +
    "dataDeserializer=$dataDeserializer, " +
    "variablesSerializer=$variablesSerializer, " +
    "connector=$connector)"
}

  private class ListMoviesQueryImpl(
    override val connector: MoviesConnectorImpl
  ) : ListMoviesQuery {
  override val operationName by ListMoviesQuery.Companion::operationName
  override val dataDeserializer by ListMoviesQuery.Companion::dataDeserializer
  override val variablesSerializer by ListMoviesQuery.Companion::variablesSerializer

  override fun equals(other: Any?): Boolean = other === this

  override fun hashCode(): Int = System.identityHashCode(this)

  override fun toString() = "ListMoviesQueryImpl(" +
    "operationName=$operationName, " +
    "dataDeserializer=$dataDeserializer, " +
    "variablesSerializer=$variablesSerializer, " +
    "connector=$connector)"
}


// The lines below are used by the code generator to ensure that this file is deleted if it is no
// longer needed. Any files in this directory that contain the lines below will be deleted by the
// code generator if the file is no longer needed. If, for some reason, you do _not_ want the code
// generator to delete this file, then remove the line below (and this comment too, if you want).

// FIREBASE_DATA_CONNECT_GENERATED_FILE MARKER 42da5e14-69b3-401b-a9f1-e407bee89a78
// FIREBASE_DATA_CONNECT_GENERATED_FILE CONNECTOR movies

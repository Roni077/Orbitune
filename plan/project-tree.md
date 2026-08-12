# Detailed Project Architecture Tree

Orbitune utilizes a **Feature-First Clean Architecture (MVVM)** following strict agent skill guidelines. Below is the exact file-level blueprint of the Dart files that will be created, satisfying the 42 required screens and all modules.

```text
orbitune/
├── android/                   
├── assets/                    
├── plan/                      
├── test/                      
└── lib/
    ├── main.dart                                   # Entry point & ProviderScope
    │
    ├── core/                                       
    │   ├── constants/
    │   │   ├── app_colors.dart                     
    │   │   ├── app_strings.dart                    
    │   │   ├── app_dimens.dart                     
    │   │   └── api_constants.dart                  
    │   ├── errors/
    │   │   ├── failure.dart                        # Sealed class for UI error mapping
    │   │   └── exceptions.dart                     
    │   ├── extensions/
    │   │   ├── context_ext.dart                    
    │   │   └── duration_ext.dart                   
    │   ├── helpers/
    │   │   ├── debouncer.dart                      
    │   │   └── result_type.dart                    # Either/Result type for safe error handling
    │   ├── network/
    │   │   ├── network_client.dart                 
    │   │   ├── network_info.dart                   
    │   │   └── error_mapper.dart                   
    │   ├── permissions/
    │   │   └── permission_handler_util.dart        
    │   ├── theme/
    │   │   ├── app_theme.dart                      
    │   │   └── dynamic_color_builder.dart          
    │   └── utils/
    │       ├── logger.dart                         
    │       ├── track_mapper.dart                   
    │       └── file_utils.dart                     
    │
    ├── data/                                       
    │   ├── datasources/
    │   │   ├── local/
    │   │   │   ├── app_database.dart               
    │   │   │   ├── track_local_ds.dart             
    │   │   │   ├── playlist_local_ds.dart          
    │   │   │   └── history_local_ds.dart           
    │   │   └── remote/
    │   │       ├── online_music_ds.dart            
    │   │       ├── jiosaavn_ds_impl.dart           # Uses jiosaavn package
    │   │       └── ytmusic_ds_impl.dart            # Uses ytmusicapi_dart package
    │   ├── models/
    │   │   ├── track_dto.dart                      
    │   │   ├── playlist_dto.dart                   
    │   │   └── isar_collections.dart               
    │   └── repositories/
    │       ├── local_music_repo_impl.dart          
    │       ├── online_music_repo_impl.dart         
    │       ├── playlist_repo_impl.dart             
    │       ├── favorites_repo_impl.dart            
    │       └── settings_repo_impl.dart             
    │
    ├── domain/                                     
    │   ├── entities/
    │   │   ├── track.dart                          
    │   │   ├── album.dart                          
    │   │   ├── artist.dart                         
    │   │   └── playlist.dart                       
    │   ├── repositories/
    │   │   ├── local_music_repository.dart         
    │   │   ├── online_music_repository.dart        
    │   │   ├── playlist_repository.dart            
    │   │   ├── favorites_repository.dart           
    │   │   └── settings_repository.dart            
    │   └── usecases/
    │       ├── get_local_tracks_uc.dart            
    │       ├── search_online_tracks_uc.dart        
    │       ├── add_to_playlist_uc.dart             
    │       └── toggle_favorite_uc.dart             
    │
    ├── services/                                   
    │   ├── audio/
    │   │   ├── audio_handler_impl.dart             
    │   │   ├── custom_audio_source.dart            
    │   │   ├── just_audio_player.dart              
    │   │   ├── queue_manager.dart                  
    │   │   ├── playback_state_notifier.dart        
    │   │   └── media_session_handler.dart          
    │   ├── downloads/
    │   │   └── download_manager.dart               
    │   ├── equalizer/
    │   │   └── equalizer_controller.dart           
    │   ├── metadata/
    │   │   ├── media_scanner_service.dart          
    │   │   └── isolate_parser.dart                 
    │   └── lyrics/
    │       └── lyrics_service.dart                 
    │
    └── ui/                                         
        ├── core/
        │   ├── widgets/
        │   │   ├── orbitune_button.dart            
        │   │   ├── song_tile.dart                  
        │   │   ├── artwork_view.dart               
        │   │   ├── empty_state.dart                
        │   │   └── loading_skeleton.dart           
        │   └── navigation/
        │       ├── app_router.dart                 # GoRouter & StatefulShellRoute config
        │       └── scaffold_with_nav.dart          # Shell widget consuming StatefulNavigationShell
        │
        └── features/
            ├── onboarding/
            │   ├── views/
            │   │   ├── splash_screen.dart          # [Screen 1]
            │   │   ├── onboarding_screen.dart      # [Screen 2]
            │   │   └── permission_screen.dart      # [Screen 3]
            │   └── view_models/
            │       └── onboarding_view_model.dart  
            │
            ├── home/
            │   ├── views/
            │   │   ├── home_screen.dart            # [Screen 4]
            │   │   ├── online_music_screen.dart    # [Screen 5]
            │   │   └── widgets/section_header.dart 
            │   └── view_models/
            │       └── home_view_model.dart        
            │
            ├── search/
            │   ├── views/
            │   │   ├── search_screen.dart          # [Screen 6]
            │   │   └── search_results_screen.dart  # [Screen 7]
            │   └── view_models/
            │       └── search_view_model.dart      
            │
            ├── library/
            │   ├── views/
            │   │   ├── library_screen.dart         # [Screen 8]
            │   │   └── tabs/
            │   │       ├── songs_tab.dart          # [Screen 9]
            │   │       ├── albums_tab.dart         # [Screen 10]
            │   │       ├── artists_tab.dart        # [Screen 11]
            │   │       ├── genres_tab.dart         # [Screen 12]
            │   │       └── folders_tab.dart        # [Screen 13]
            │   └── view_models/
            │       └── library_view_model.dart     
            │
            ├── favorites/
            │   ├── views/
            │   │   └── favorites_screen.dart       # [Screen 14]
            │   └── view_models/
            │       └── favorites_view_model.dart   
            │
            ├── history/
            │   ├── views/
            │   │   └── recently_played_screen.dart # [Screen 15]
            │   └── view_models/
            │       └── history_view_model.dart     
            │
            ├── downloads/
            │   ├── views/
            │   │   └── downloads_screen.dart       # [Screen 16]
            │   └── view_models/
            │       └── downloads_view_model.dart   
            │
            ├── playlists/
            │   ├── views/
            │   │   ├── playlists_screen.dart       # [Screen 17]
            │   │   ├── playlist_details_screen.dart# [Screen 18]
            │   │   └── widgets/create_dialog.dart 
            │   └── view_models/
            │       └── playlist_view_model.dart    
            │
            ├── artist/
            │   ├── views/
            │   │   └── artist_details_screen.dart  # [Screen 19]
            │   └── view_models/
            │       └── artist_view_model.dart      
            │
            ├── album/
            │   ├── views/
            │   │   └── album_details_screen.dart   # [Screen 20]
            │   └── view_models/
            │       └── album_view_model.dart       
            │
            ├── player/
            │   ├── views/
            │   │   ├── now_playing_screen.dart     # [Screen 21]
            │   │   ├── queue_screen.dart           # [Screen 22]
            │   │   └── widgets/
            │   │       ├── mini_player.dart        
            │   │       └── playback_controls.dart  
            │   └── view_models/
            │       └── player_view_model.dart      
            │
            ├── lyrics/
            │   ├── views/
            │   │   └── lyrics_screen.dart          # [Screen 23]
            │   └── view_models/
            │       └── lyrics_view_model.dart      
            │
            ├── equalizer/
            │   ├── views/
            │   │   └── equalizer_screen.dart       # [Screen 24]
            │   └── view_models/
            │       └── equalizer_view_model.dart   
            │
            └── settings/
                ├── views/
                │   ├── settings_screen.dart        # [Screen 25]
                │   └── sub_screens/
                │       ├── playback_settings.dart  # [Screen 26]
                │       ├── appearance_settings.dart# [Screen 27]
                │       ├── library_settings.dart   # [Screen 28]
                │       ├── online_settings.dart    # [Screen 29]
                │       └── about_screen.dart       # [Screen 30]
                └── view_models/
                    └── settings_view_model.dart    
```

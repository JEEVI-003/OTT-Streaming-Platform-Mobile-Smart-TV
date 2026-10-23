package com.VsmartEngine.MediaJungle.Library;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.Objects;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.exception.ResourceNotFoundException;
import com.VsmartEngine.MediaJungle.model.Audiodescription;
import com.VsmartEngine.MediaJungle.repository.AddAudioRepository;
import com.VsmartEngine.MediaJungle.repository.AddAudiodescription;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;


@RestController
public class PlaylistController {
	
	@Autowired
	private PlaylistRepository playlistrepository;
	
	@Autowired
	private AddAudiodescription audio ;
	
	private static final Logger logger = LoggerFactory.getLogger(PlaylistController.class);
    public ResponseEntity<Playlist> createPlaylist(
        @RequestParam String title, @RequestParam String description,@RequestParam Long userId) {
		Playlist playlist = new Playlist();
        playlist.setTitle(title);
        playlist.setDescription(description);
        playlist.setUserId(userId);
        Playlist playlists = playlistrepository.save(playlist);
        return ResponseEntity.ok(playlists);
    }
	
	// Add an audio ID to a playlist
    
    public ResponseEntity<Playlist> addAudioIdToPlaylist(
        @PathVariable Long playlistId, @PathVariable Long audioId) {
    	Playlist playlist = playlistrepository.findById(playlistId)
                .orElseThrow(() -> new ResourceNotFoundException("Playlist not found"));
            
            playlist.getAudioIds().add(audioId);
            Playlist playlists = playlistrepository.save(playlist);
        return ResponseEntity.ok(playlists);
    }
    
    
    
    public ResponseEntity<Playlist> createPlaylistwithid(
        @RequestParam String title, 
        @RequestParam String description,
        @RequestParam Long audioId,
        @RequestParam Long userId) {
        
        // Create a new Playlist instance and set title and description
        Playlist playlist = new Playlist();
        playlist.setTitle(title);
        playlist.setDescription(description);
        playlist.setUserId(userId);
        // Save the playlist to generate an ID
        playlistrepository.save(playlist);
        // Add the audioId to the playlist's audioIds list
        playlist.getAudioIds().add(audioId);
        // Save the updated playlist with the audio ID
        Playlist updatedPlaylist = playlistrepository.save(playlist);
        return ResponseEntity.ok(updatedPlaylist);
    }
    
 
    public ResponseEntity<List<Playlist>> getPlaylistsByUserId(@PathVariable Long userId) {
        // Retrieve all playlists for the given userId
        List<Playlist> playlists = playlistrepository.findAllByUserId(userId);  
        // Return the list of playlists
        return ResponseEntity.ok(playlists);
    }
    

    public ResponseEntity<Playlist> getPlaylists(@PathVariable Long Id) {
        // Retrieve all playlists for the given userId
        Optional<Playlist> playlists = playlistrepository.findById(Id);
        if (playlists.isPresent()) {
        	Playlist user = playlists.get();
            // Check if the profile is present (not null and not empty)
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    public ResponseEntity<List<playlistDTO>> getPlaylistWithAudioDetails(@PathVariable Long id) {
        List<Playlist> playlists = playlistrepository.findByPlaylist(id);
        // Map each Playlist to a PlaylistDTO with audio details
        List<playlistDTO> playlistDTOs = playlists.stream().map(playlist -> {
            // Convert audioIds to a list of LikedsongsDTO
            List<LikedsongsDTO> audioDetails = playlist.getAudioIds().stream()
                .map(audioId -> {
                    Optional<Audiodescription> optionalAudio = audio.findById(audioId);
                    if (optionalAudio.isPresent()) {
                        Audiodescription audioDescription = optionalAudio.get();
                        return new LikedsongsDTO(audioDescription.getId(), audioDescription.getAudio_title());
                    }
                    return null;
                })
                .filter(Objects::nonNull)  // Filter out any null values
                .collect(Collectors.toList());
            // Create and return a PlaylistDTO with audio details
            return new playlistDTO(
                playlist.getUserId(),
                playlist.getId(),
                playlist.getTitle(),
                playlist.getDescription(),           
                audioDetails
            );
        }).collect(Collectors.toList());

        return ResponseEntity.ok(playlistDTOs);
    }

// New DELETE method for deleting a playlist by ID
    
    public ResponseEntity<String> deletePlaylist(@PathVariable Long id) {
        // Check if the playlist exists
        if (!playlistrepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Failed: Playlist not found");
        }

        // Delete the playlist
        playlistrepository.deleteById(id);

        // Return success message
        return ResponseEntity.ok("Success: Playlist deleted");
    }
    
    
    public ResponseEntity<Void> removeAudioFromPlaylist(@PathVariable Long playlistId, @PathVariable Long audioId) {
        // Check if the playlist exists
        Optional<Playlist> optionalPlaylist = playlistrepository.findById(playlistId);
        if (!optionalPlaylist.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Playlist playlist = optionalPlaylist.get();

        // Remove the audioId from the playlist's audioIds list
        boolean removed = playlist.getAudioIds().remove(audioId);

        // Save the updated playlist
        playlistrepository.save(playlist);

        if (removed) {
            return ResponseEntity.noContent().build(); // Success
        } else {
            return ResponseEntity.badRequest().body(null); // Audio ID not found in the playlist
        }
    }
    
    public ResponseEntity<String> updatePlaylist(
            @PathVariable Long Id,
            @RequestParam(value = "title", required = false) String title,
            @RequestParam(value = "description", required = false) String description){
        try {
            // Retrieve existing user data from the repository
            Optional<Playlist> optionalplaylist = playlistrepository.findById(Id);
            if (!optionalplaylist.isPresent()) {
                return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
            }
            Playlist existingplaylist = optionalplaylist.get();
            // Apply partial updates to the existing user data if provided
            if (title != null) {
                existingplaylist.setTitle(title);
            }
            if (description != null) {
                existingplaylist.setDescription(description);
            }
            // Save the updated user data back to the repository
            playlistrepository.save(existingplaylist);

            return new ResponseEntity<>("playlist updated successfully", HttpStatus.OK);
        } catch (Exception e) {
        	logger.error("", e);
            return new ResponseEntity<>("Error updating playlist", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    public ResponseEntity<String> moveAudioToAnotherPlaylist(
            @PathVariable Long playlistId, 
            @PathVariable Long audioId, 
            @PathVariable Long movedPlaylistId) {

        try {
            // Find the source playlist (from where the audio is being moved)
            Optional<Playlist> sourcePlaylistOpt = playlistrepository.findById(playlistId);
            if (!sourcePlaylistOpt.isPresent()) {
                return new ResponseEntity<>("Source Playlist not found", HttpStatus.NOT_FOUND);
            }
            Playlist sourcePlaylist = sourcePlaylistOpt.get();

            // Find the destination playlist (to where the audio is being moved)
            Optional<Playlist> destPlaylistOpt = playlistrepository.findById(movedPlaylistId);
            if (!destPlaylistOpt.isPresent()) {
                return new ResponseEntity<>("Destination Playlist not found", HttpStatus.NOT_FOUND);
            }
            Playlist destPlaylist = destPlaylistOpt.get();

            // Check if the audio is in the source playlist
            boolean removed = sourcePlaylist.getAudioIds().remove(audioId);
            if (!removed) {
                return new ResponseEntity<>("Audio not found in source playlist", HttpStatus.NOT_FOUND);
            }

            // Add the audioId to the destination playlist
            destPlaylist.getAudioIds().add(audioId);

            // Save the updated playlists
            playlistrepository.save(sourcePlaylist);
            playlistrepository.save(destPlaylist);

            // Optionally, delete the audio from the audio repository if required
            // audio.deleteById(audioId); // Uncomment if you want to delete the audio after moving

            return new ResponseEntity<>("Audio moved successfully", HttpStatus.OK);

        } catch (Exception e) {
        	logger.error("", e);
            return new ResponseEntity<>("Error moving audio: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    
    
    

}

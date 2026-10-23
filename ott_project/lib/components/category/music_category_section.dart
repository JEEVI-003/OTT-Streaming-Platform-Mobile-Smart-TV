
import 'package:flutter/material.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/category_based_song.dart';
import 'package:ott_project/components/music_folder/song_player_page.dart';
import 'package:ott_project/components/pallete.dart';

import '../music_folder/audio_card.dart';


class MusicCategorySection extends StatelessWidget {
  final AudioContainer audioContainer;
  final int userId;
  final Function(AudioDescription) onTap;

  const MusicCategorySection({
    super.key,
   // required this.title,
    required this.audioContainer,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
   final displayedAudio = audioContainer.audiolist.length > 5
        ? audioContainer.audiolist.sublist(0, 5)
        : audioContainer.audiolist;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              audioContainer.categoryName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kWhite,
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryBasedSong(categoryName: audioContainer.categoryName, audioDescriptions: audioContainer.audiolist ,)));
                },
                child: Text('See more', style: TextStyle(color: Colors.green))),
          ],
        ),
       
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.22,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayedAudio.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: AudioCard(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> 
                     SongPlayerPage(music: displayedAudio[index], onChange: onTap, onDislike: (_){},musicList: audioContainer.audiolist,)));
                    },
                    audio: displayedAudio[index],
                    initialIndex: index, 
                  ),
                );
              }),
        ),
      ],
    );
       
  }
}

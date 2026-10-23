import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ott_project/components/pallete.dart';

import 'audio_container.dart';
class AudioCard extends StatefulWidget {
  final AudioDescription audio;
  final int initialIndex;
  final VoidCallback onTap;

  const AudioCard({
    Key? key,
    required this.audio,
    required this.initialIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = widget.audio.thumbnailImage;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<Uint8List?>(
                  future: _thumbnailFuture,
                  builder: (context, snapshot) {
                    final thumbnail = snapshot.data;
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.memory(
                        thumbnail!,
                        width: 164,
                        height: 130,
                        fit: BoxFit.fill,
                      );
                    } else {
                      return Container(
                        width: 164,
                        height: 135,
                        color: Colors.grey,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
            Text(
              widget.audio.audioTitle,
              style: const TextStyle(color: kWhite),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

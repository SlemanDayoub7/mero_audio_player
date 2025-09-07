// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mero_audio_player/features/audio_player/domain/entities/playlist.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/cubit/audio_player/audio_player_cubit.dart';
// import 'package:mero_audio_player/features/audio_player/presentation/cubit/playlist/playlist_cubit.dart';

// class PlaylistsPage extends StatelessWidget {
//   const PlaylistsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Playlists')),
//       body: BlocBuilder<PlaylistCubit, List<Playlist>>(
//         builder: (context, playlists) {
//           if (playlists.isEmpty) {
//             return Center(child: Text('No playlists found'));
//           }
//           return ListView.builder(
//             itemCount: playlists.length,
//             itemBuilder: (context, index) {
//               final playlist = playlists[index];
//               return ListTile(
//                 title: Text(playlist.name),
//                 subtitle: Text('${playlist.audios.length} songs'),
//                 onTap: () {
//                   context.read<AudioPlayerCubit>().loadPlaylist(
//                     playlist.audios,
//                   );
//                 },
//                 trailing: IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed:
//                       () => context.read<PlaylistCubit>().deletePlaylist(index),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           final nameController = TextEditingController();
//           showDialog(
//             context: context,
//             builder:
//                 (_) => AlertDialog(
//                   title: Text('New Playlist'),
//                   content: TextField(
//                     controller: nameController,
//                     decoration: InputDecoration(hintText: 'Playlist name'),
//                   ),
//                   actions: [
//                     TextButton(
//                       child: Text('Cancel'),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     TextButton(
//                       child: Text('Add'),
//                       onPressed: () {
//                         final name = nameController.text.trim();
//                         if (name.isNotEmpty) {
//                           context.read<PlaylistCubit>().addPlaylist(
//                             Playlist(name: name, audios: []),
//                           );
//                         }
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//           );
//         },
//       ),
//     );
//   }
// }

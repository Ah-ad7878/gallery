import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(NameBar());
}

class NameBar extends StatelessWidget {
  const NameBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //list for store images
  List<AssetEntity> images = [];

  //create function to get permission from user
  Future<void> getImage() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> media = await albums.first.getAssetListPaged(
          page: 0,
          size: 100,
        );

        setState(() {
          images = media;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FullImagePage(image: images[index]);
                  },
                ),
              );
            },
            child: FutureBuilder<Uint8List?>(
              future: images[index].thumbnailDataWithSize(
                const ThumbnailSize(200, 200),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Container(
                    child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                  );
                }
                return Container(color: Colors.grey);
              },
            ),
          );
        },
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final AssetEntity image;

  const FullImagePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: FutureBuilder<Uint8List?>(
          future: image.thumbnailDataWithSize(const ThumbnailSize(1000, 1000)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return InteractiveViewer(
                child: Image.memory(snapshot.data!, fit: BoxFit.contain),
              );
            }

            return const CircularProgressIndicator(color: Colors.white);
          },
        ),
      ),
    );
  }
}

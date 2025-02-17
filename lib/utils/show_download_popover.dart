import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/providers/providers.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'utils.dart';

final Widget _progressIndicator = SizedBox(
  height: 100,
  child: getCircularProgressIndicator(),
);

Future showDownloadPopup(BuildContext context, {Video? video, String? videoUrl}) {
  assert(video != null || videoUrl != null);
  final yt = YoutubeExplode();
  Future<Video?> getVideo() => yt.videos.get(videoUrl!);
  return showPopover(
    context: context,
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
    innerPadding: EdgeInsets.zero,
    builder: (ctx) => FutureBuilder<Video?>(
        future: videoUrl != null ? getVideo().whenComplete(() => yt.close()) : null,
        builder: (context, snapshot) {
          return video != null || snapshot.hasData && snapshot.data != null
              ? DownloadsWidget(video: video ?? snapshot.data!)
              : snapshot.hasError
                  ? const Text("Error")
                  : _progressIndicator;
        }),
  );
}

class DownloadsWidget extends ConsumerWidget {
  final Video video;
  final VoidCallback? onClose;

  const DownloadsWidget({
    Key? key,
    required this.video,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    return FutureBuilder<StreamManifest>(
      future: YoutubeExplode().videos.streamsClient.getManifest(video.id.value),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onClose == null)
                    FTVideo(
                      isRow: true,
                      videoData: video,
                      isInsideDownloadPopup: true,
                    ),
                  if (ref.watch(thumbnailDownloaderProvider)) ...[
                    linksHeader(
                      context,
                      icon: LucideIcons.image,
                      label: "Thumbnail",
                      padding: const EdgeInsets.only(top: 6, bottom: 14),
                    ),
                    for (var thumbnail in video.thumbnails.toStreamInfo)
                      CustomListTile(
                        stream: thumbnail,
                        video: video,
                        onClose: onClose,
                      ),
                  ],
                  linksHeader(
                    context,
                    icon: LucideIcons.film,
                    label: "Video + Audio",
                    padding: const EdgeInsets.only(top: 6, bottom: 14),
                  ),
                  for (var videoStream in snapshot.data!.muxed.toList().sortByVideoQuality())
                    CustomListTile(
                      stream: videoStream,
                      video: video,
                      onClose: onClose,
                    ),
                  linksHeader(
                    context,
                    icon: LucideIcons.music,
                    label: "Audio only",
                  ),
                  for (var audioStream in snapshot.data!.audioOnly.toList().reversed)
                    CustomListTile(
                      stream: audioStream,
                      video: video,
                      onClose: onClose,
                    ),
                  linksHeader(
                    context,
                    icon: LucideIcons.video,
                    label: "Video only",
                  ),
                  for (var videoStream in snapshot.data!.videoOnly.toList().sortByVideoQuality())
                    CustomListTile(
                      stream: videoStream,
                      video: video,
                      onClose: onClose,
                    ),
                ],
              )
            : _progressIndicator;
      },
    );
  }
}

Widget linksHeader(
  BuildContext context, {
  required IconData icon,
  required String label,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 14),
}) {
  return Padding(
    padding: padding,
    child: Row(
      children: [
        Icon(
          icon,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: context.textTheme.headline5,
        )
      ],
    ),
  );
}

class CustomListTile extends ConsumerWidget {
  final dynamic stream;
  final Video video;
  final VoidCallback? onClose;

  const CustomListTile({
    Key? key,
    required this.stream,
    required this.video,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          if ((Platform.isAndroid || Platform.isIOS) && !await Permission.storage.request().isGranted) return;
          ref.watch(downloadListProvider.notifier).addDownload(
                DownloadItem.fromVideo(
                  video: video,
                  stream: stream,
                  path: ref.watch(downloadPathProvider).path,
                ),
              );
          onClose != null ? onClose!() : context.back();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (stream is ThumbnailStreamInfo
                            ? stream.containerName
                            : stream is AudioOnlyStreamInfo
                                ? stream.audioCodec.split('.')[0].replaceAll('mp4a', 'm4a')
                                : stream.container.name)
                        .toUpperCase(),
                  ),
                  Text(stream is ThumbnailStreamInfo ? "" : (stream.size.totalBytes as int).getFileSize()),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  stream is VideoStreamInfo
                      ? stream.videoQualityLabel
                      : stream is AudioOnlyStreamInfo
                          ? (stream.bitrate.bitsPerSecond as int).getBitrate()
                          : stream is ThumbnailStreamInfo
                              ? stream.name
                              : "",
                  style: context.textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

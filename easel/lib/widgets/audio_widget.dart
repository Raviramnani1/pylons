import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easel_flutter/easel_provider.dart';
import 'package:easel_flutter/models/picked_file_model.dart';
import 'package:easel_flutter/repository/repository.dart';
import 'package:easel_flutter/screens/owner_view/viewmodels/owner_view_viewmodel.dart';
import 'package:easel_flutter/utils/constants.dart';
import 'package:easel_flutter/utils/easel_app_theme.dart';
import 'package:easel_flutter/utils/extension_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/nft_format.dart';

class AudioWidget extends StatefulWidget {
  final File? file;
  final String? filePath;
  final bool previewFlag;
  final bool fromOwnerScreen;

  const AudioWidget({
    Key? key,
    this.file,
    required this.previewFlag,
    this.filePath,
    this.fromOwnerScreen = false,
  }) : super(key: key);

  @override
  AudioWidgetState createState() => AudioWidgetState();
}

class AudioWidgetState extends State<AudioWidget> with WidgetsBindingObserver {
  EaselProvider get easelProvider => GetIt.I.get();

  Repository get repository => GetIt.I.get<Repository>();

  OwnerViewViewModel? ownerViewModel;

  @override
  void initState() {
    super.initState();

    if (!widget.previewFlag) {
      easelProvider.initializeAudioPlayer(publishedNFTUrl: widget.filePath ?? "");
      return;
    } else {
      easelProvider.initializeAudioPlayerForFile(file: widget.file!);
      return;
    }
  }

  BoxDecoration getAudioBackgroundDecorationFromEaselViewModel({required EaselProvider viewModel}) {
    if (widget.previewFlag && viewModel.audioThumbnail == null) {
      return const BoxDecoration();
    }
    if (widget.previewFlag && viewModel.audioThumbnail != null) {
      return BoxDecoration(image: DecorationImage(image: FileImage(viewModel.audioThumbnail!), fit: BoxFit.fitHeight));
    }
    return BoxDecoration(
      image: viewModel.nft.thumbnailUrl.isNotEmpty
          ? DecorationImage(
              image: CachedNetworkImageProvider(
                viewModel.nft.thumbnailUrl.changeDomain(),
              ),
              fit: BoxFit.fitHeight,
            )
          : null,
    );
  }

  BoxDecoration getAudioBackgroundDecorationFromOwnerViewModel(OwnerViewViewModel? viewModel) {
    return BoxDecoration(
      image: viewModel!.nft.thumbnailUrl.isNotEmpty
          ? DecorationImage(
              image: CachedNetworkImageProvider(
                viewModel.nft.thumbnailUrl.changeDomain(),
              ),
              fit: BoxFit.fitWidth,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final easelViewModel = context.watch<EaselProvider>();
    if (widget.fromOwnerScreen) {
      ownerViewModel = context.watch<OwnerViewViewModel>();
    } else {
      ownerViewModel = null;
    }

    return WillPopScope(
        onWillPop: () {
          easelProvider.setAudioThumbnail(null);
          Navigator.pop(context);
          return Future.value(true);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: widget.fromOwnerScreen
              ? getAudioBackgroundDecorationFromOwnerViewModel(
                  ownerViewModel,
                )
              : getAudioBackgroundDecorationFromEaselViewModel(
                  viewModel: easelViewModel,
                ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 0.4.sh,
                  ),
                  // ignore: prefer_if_elements_to_conditional_expressions
                  (shouldShowThumbnailButtonOrStepsOrNot())
                      ? SizedBox(
                          height: 100.h,
                          width: 330.0.w,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 10.w, bottom: 10.h, top: 10.h, left: 5.w),
                                  child: ValueListenableBuilder<ButtonState>(
                                    valueListenable: easelViewModel.buttonNotifier,
                                    builder: (_, value, __) {
                                      switch (value) {
                                        case ButtonState.loading:
                                          return SizedBox(height: 22.h, width: 22.h, child: CircularProgressIndicator(strokeWidth: 2.w, color: Colors.black));
                                        case ButtonState.paused:
                                          return InkWell(
                                            onTap: () {
                                              easelViewModel.playAudio(forFile: widget.file != null);
                                            },
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: EaselAppTheme.kDarkBlue,
                                              size: 35.h,
                                            ),
                                          );

                                        case ButtonState.playing:
                                          return InkWell(
                                            onTap: () {
                                              easelViewModel.pauseAudio(forFile: widget.file != null);
                                            },
                                            child: Icon(
                                              Icons.pause,
                                              color: EaselAppTheme.kDarkBlue,
                                              size: 35.h,
                                            ),
                                          );
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ValueListenableBuilder<ProgressBarState>(
                                    valueListenable: easelViewModel.audioProgressNotifier,
                                    builder: (_, value, __) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 3.h, right: 20.w),
                                        child: ProgressBar(
                                          progressBarColor: EaselAppTheme.kDarkBlue,
                                          thumbColor: EaselAppTheme.kDarkBlue,
                                          progress: value.current,
                                          baseBarColor: EaselAppTheme.kGrey,
                                          bufferedBarColor: EaselAppTheme.kLightGrey,
                                          buffered: value.buffered,
                                          total: value.total,
                                          timeLabelTextStyle: TextStyle(color: EaselAppTheme.kGrey, fontWeight: FontWeight.w800, fontSize: 9.sp),
                                          thumbRadius: 10.h,
                                          timeLabelPadding: 3.h,
                                          onSeek: (position) {
                                            easelViewModel.seekAudio(position, forFile: widget.file != null);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ))
                      : const SizedBox(),
                  SizedBox(
                    height: 40.0.h,
                  ),
                  if (shouldShowThumbnailButtonOrStepsOrNot()) _buildThumbnailButton() else const SizedBox(),
                ],
              ),
            ),
          ),
        ));
  }

  bool shouldShowThumbnailButtonOrStepsOrNot() {
    return widget.previewFlag;
  }

  @override
  void dispose() {
    easelProvider.disposeAudioController();
    super.dispose();
  }

  Widget _buildThumbnailButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 20.h),
        child: SizedBox(
          height: 120.h,
          width: 120.w,
          child: InkWell(
            onTap: () {
              audioThumbnailPicker();
            },
            child: SvgPicture.asset(PngUtils.kUploadThumbnail),
          ),
        ),
      ),
    );
  }

  Future<void> audioThumbnailPicker() async {
    easelProvider.pauseAudio(forFile: true);
    final pickedFile = await repository.pickFile(NftFormat.supportedFormats[0]);
    final result = pickedFile.getOrElse(() => PickedFileModel(path: "", fileName: "", extension: ""));
    if (result.path.isEmpty) {
      return;
    }
    easelProvider.setAudioThumbnail(File(result.path));
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

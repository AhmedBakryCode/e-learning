import 'dart:async';
import 'dart:io';

import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/responsive_layout.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/video_session_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/video_session_state.dart';
import 'package:e_learning/features/courses/presentation/widgets/course_video_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:flutter/services.dart';

class VideoPlayerPage extends StatelessWidget {
  const VideoPlayerPage({
    super.key,
    required this.courseId,
    required this.videoId,
  });

  final String courseId;
  final String videoId;

  @override
  Widget build(BuildContext context) {
    final studentId = context.read<AuthCubit>().state.user?.id;
    if (studentId == null) {
      return const AdaptiveScaffold(
        title: 'Video player',
        subtitle: 'Lesson is being prepared.',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (_) => sl<VideoSessionCubit>()
        ..loadSession(
          studentId: studentId,
          courseId: courseId,
          videoId: videoId,
        ),
      child: _VideoPlayerView(courseId: courseId),
    );
  }
}

class _VideoPlayerView extends StatefulWidget {
  const _VideoPlayerView({required this.courseId});

  final String courseId;

  @override
  State<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<_VideoPlayerView> {
  Player? _player;
  VideoController? _controller;
  String? _currentVideoId;
  int _lastSavedSecond = 0;
  bool _isControllerReady = false;
  bool _autoCompletionTriggered = false;
  String? _controllerError;
  late VideoSessionCubit _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<VideoSessionCubit>();
    _enableSecureScreen();
  }

  Future<void> _enableSecureScreen() async {
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterWindowManagerPlus.addFlags(
        FlutterWindowManagerPlus.FLAG_SECURE,
      );
    }
  }

  Future<void> _disableSecureScreen() async {
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterWindowManagerPlus.clearFlags(
        FlutterWindowManagerPlus.FLAG_SECURE,
      );
    }
  }

  @override
  void dispose() {
    _disableSecureScreen();
    _persistPosition(force: true);
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoSessionCubit, VideoSessionState>(
      listenWhen: (previous, current) =>
          previous.currentVideo?.id != current.currentVideo?.id ||
          previous.resumePositionSeconds != current.resumePositionSeconds ||
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.status == ViewStateStatus.success &&
            state.currentVideo != null) {
          _ensureController(
            videoUrl: state.currentVideo!.videoUrl,
            videoId: state.currentVideo!.id,
            resumePositionSeconds: state.resumePositionSeconds,
          );
        }

        if (state.actionStatus != ViewStateStatus.initial &&
            state.actionMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionMessage!)));
          context.read<VideoSessionCubit>().clearActionState();
        }
      },
      builder: (context, state) {
        if (state.status == ViewStateStatus.loading) {
          return const AdaptiveScaffold(
            title: 'Video player',
            subtitle: 'Loading the lesson launcher.',
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == ViewStateStatus.failure ||
            state.currentVideo == null) {
          return AdaptiveScaffold(
            title: 'Video player',
            subtitle: 'Lesson playback will appear here once available.',
            body: EmptyStateWidget(
              title: 'No video available',
              message:
                  state.errorMessage ??
                  'This lesson could not be loaded from existing experimental data.',
              icon: Icons.play_circle_outline_rounded,
            ),
          );
        }

        return ResponsiveLayout(
          mobile: _MobileLayout(
            state: state,
            courseId: widget.courseId,
            playerSurface: _buildPlayerSurface(context),
            formatSeconds: _formatSeconds,
          ),
          desktop: _DesktopLayout(
            state: state,
            courseId: widget.courseId,
            playerSurface: _buildPlayerSurface(context),
            formatSeconds: _formatSeconds,
          ),
        );
      },
    );
  }

  Widget _buildPlayerSurface(BuildContext context) {
    if (_controllerError != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            boxShadow: AppShadows.elevated,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white60,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  _controllerError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () {
                  final state = context.read<VideoSessionCubit>().state;
                  if (state.currentVideo != null) {
                    _ensureController(
                      videoUrl: state.currentVideo!.videoUrl,
                      videoId: state.currentVideo!.id,
                      resumePositionSeconds: state.resumePositionSeconds,
                      force: true,
                    );
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isControllerReady || _controller == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withAlpha(180),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: AppShadows.elevated,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Video(controller: _controller!),
            _buildWatermark(context),
            _buildSpeedCorner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermark(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return const SizedBox.shrink();
    return _WatermarkOverlay(text: '${user.name} | ${user.id}');
  }

  Widget _buildSpeedCorner(BuildContext context) {
    return Positioned(
      top: AppSpacing.md,
      right: AppSpacing.md,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(120),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Material(
          color: Colors.transparent,
          child: PopupMenuButton<double>(
            initialValue: _player?.state.rate ?? 1.0,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              _player?.setRate(speed);
              setState(() {});
            },
            itemBuilder: (context) =>
                [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                  return PopupMenuItem(value: speed, child: Text('${speed}x'));
                }).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                '${_player?.state.rate ?? 1.0}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _ensureController({
    required String videoUrl,
    required String videoId,
    required int resumePositionSeconds,
    bool force = false,
  }) async {
    if (!force &&
        _currentVideoId == videoId &&
        (_player != null || _controllerError != null)) {
      return;
    }

    _currentVideoId = videoId;
    _lastSavedSecond = resumePositionSeconds;
    _autoCompletionTriggered = false;
    await _disposeController();

    setState(() {
      _controllerError = null;
      _isControllerReady = false;
    });

    try {
      final player = Player();
      final controller = VideoController(player);

      await player.open(Media(videoUrl), play: false);

      if (!mounted) {
        await player.dispose();
        return;
      }

      if (resumePositionSeconds > 0) {
        await player.seek(Duration(seconds: resumePositionSeconds));
      }

      player.stream.position.listen((position) {
        if (!mounted) return;
        final positionSeconds = position.inSeconds;
        if ((positionSeconds - _lastSavedSecond).abs() >= 5) {
          _persistPosition();
        }

        final durationSeconds = player.state.duration.inSeconds;
        if (!_autoCompletionTriggered &&
            durationSeconds > 0 &&
            positionSeconds >= durationSeconds - 1) {
          _autoCompletionTriggered = true;
          unawaited(_cubit.markCompleted());
        }
      });

      setState(() {
        _player = player;
        _controller = controller;
        _isControllerReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Video Player error: $e');
      setState(() {
        _controllerError =
            'Unable to play this lesson. Please check your internet connection and try again.';
      });
    }
  }

  Future<void> _persistPosition({bool force = false}) async {
    final player = _player;
    if (player == null) {
      return;
    }

    final currentSecond = player.state.position.inSeconds;
    if (!force && (currentSecond - _lastSavedSecond).abs() < 5) {
      return;
    }

    _lastSavedSecond = currentSecond;
    unawaited(_cubit.savePlayback(currentSecond));
  }

  Future<void> _disposeController() async {
    final player = _player;
    _player = null;
    _controller = null;
    _isControllerReady = false;
    if (player != null) {
      await player.dispose();
    }
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.state,
    required this.courseId,
    required this.playerSurface,
    required this.formatSeconds,
  });

  final VideoSessionState state;
  final String courseId;
  final Widget playerSurface;
  final String Function(int) formatSeconds;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AdaptiveScaffold(
        title: 'Video player',
        subtitle: 'Complete your lessons effectively.',
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  playerSurface,
                  const SizedBox(height: AppSpacing.lg),
                  _VideoInfoCard(
                    state: state,
                    courseId: courseId,
                    formatSeconds: formatSeconds,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTabs(context),
                ],
              ),
            ),
            _buildNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Column(
      children: [
        TabBar(
          tabs: const [
            Tab(text: 'Lessons'),
            Tab(text: 'Comments'),
            Tab(text: 'Comments'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            children: [
              _VideosList(state: state, courseId: courseId),
              _NotesTab(state: state, formatSeconds: formatSeconds),
              _CommentsTab(state: state, courseId: courseId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final nextIndex =
        state.videos.indexWhere((v) => v.id == state.currentVideo!.id) + 1;
    final nextVideo = nextIndex < state.videos.length
        ? state.videos[nextIndex]
        : null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: nextVideo == null
                  ? null
                  : () => context.pushReplacement(
                      '/student/courses/$courseId/video/${nextVideo.id}',
                    ),
              child: Text(nextVideo == null ? 'Done' : 'Next lesson'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.state,
    required this.courseId,
    required this.playerSurface,
    required this.formatSeconds,
  });

  final VideoSessionState state;
  final String courseId;
  final Widget playerSurface;
  final String Function(int) formatSeconds;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: state.currentVideo!.title,
      subtitle: 'Enjoy watching the current lesson.',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  playerSurface,
                  const SizedBox(height: AppSpacing.xl),
                  _VideoInfoCard(
                    state: state,
                    courseId: courseId,
                    formatSeconds: formatSeconds,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _NotesTab(state: state, formatSeconds: formatSeconds),
                ],
              ),
            ),
          ),
          // Sidebar area
          Container(
            width: 350,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List of lessons',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _VideosList(state: state, courseId: courseId),
                ),
                const SizedBox(height: AppSpacing.lg),
                _CommentsTab(state: state, courseId: courseId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoInfoCard extends StatelessWidget {
  const _VideoInfoCard({
    required this.state,
    required this.courseId,
    required this.formatSeconds,
  });
  final VideoSessionState state;
  final String courseId;
  final String Function(int) formatSeconds;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: state.currentVideo!.title,
      subtitle: state.currentVideo!.duration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.currentVideo!.description),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Course progress ${(state.courseProgressPercent * 100).round()}%',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: state.courseProgressPercent,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<VideoSessionCubit>().markCompleted(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Mark as complete'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/student/courses/$courseId/comments?videoId=${state.currentVideo!.id}',
                  ),
                  icon: const Icon(Icons.forum_rounded),
                  label: const Text('Comments'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideosList extends StatelessWidget {
  const _VideosList({required this.state, required this.courseId});
  final VideoSessionState state;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: state.videos.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final video = state.videos[index];
        return CourseVideoTile(
          video: video,
          isHighlighted: video.id == state.currentVideo!.id,
          highlightLabel: 'Currently watching',
          onTap: () => context.pushReplacement(
            '/student/courses/$courseId/video/${video.id}',
          ),
        );
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.state, required this.formatSeconds});
  final VideoSessionState state;
  final String Function(int) formatSeconds;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Lesson notes',
      subtitle:
          'Current location: ${formatSeconds(state.resumePositionSeconds)}',
      child: const Text(
        'This lesson is connected to an experimental cloud data system. Your notes will be automatically saved when you write them in future updates.',
      ),
    );
  }
}

class _CommentsTab extends StatelessWidget {
  const _CommentsTab({required this.state, required this.courseId});
  final VideoSessionState state;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Discussions',
      subtitle: 'Interact with your classmates in this lesson.',
      child: FilledButton.icon(
        onPressed: () => context.push(
          '/student/courses/$courseId/comments?videoId=${state.currentVideo!.id}',
        ),
        icon: const Icon(Icons.forum_rounded),
        label: const Text('Open comments'),
      ),
    );
  }
}

class _WatermarkOverlay extends StatefulWidget {
  const _WatermarkOverlay({required this.text});
  final String text;

  @override
  State<_WatermarkOverlay> createState() => _WatermarkOverlayState();
}

class _WatermarkOverlayState extends State<_WatermarkOverlay> {
  double top = 20;
  double left = 20;
  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMoving();
  }

  void _startMoving() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        final now = DateTime.now().millisecondsSinceEpoch;
        top = (now % 100).toDouble() + 10;
        left = (now % 150).toDouble() + 10;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(seconds: 5),
      top: top,
      left: left,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.15,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}



import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/solar_image.dart';
import '../services/solar_image_service.dart';

class SolarActivityPage extends StatefulWidget {
  const SolarActivityPage({super.key});

  @override
  State<SolarActivityPage> createState() => _SolarActivityPageState();
}

class _SolarActivityPageState extends State<SolarActivityPage> {
  final SolarImageService _service = SolarImageService();
  final Map<String, ImageLoadState> _imageStates = {};
  final Map<String, String> _latestUrls = {};
  bool _isLoadingUrls = true;

  @override
  void initState() {
    super.initState();
    for (final src in solarImageSources) {
      _imageStates[src.id] = ImageLoadState.loading;
    }
    _loadImageUrls();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadImageUrls({bool forceRefresh = false}) async {
    // Keep existing tiles visible while refreshing in the background.
    if (!forceRefresh && _latestUrls.isNotEmpty) {
      return;
    }
    setState(() => _isLoadingUrls = true);
    try {
      final urls =
          await _service.fetchLatestImages(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _latestUrls
          ..clear()
          ..addAll(urls);
        _isLoadingUrls = false;
        if (forceRefresh) {          for (final src in solarImageSources) {
            _imageStates[src.id] = ImageLoadState.loading;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingUrls = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('太阳图像加载失败: $e')),
      );
    }
  }

  Future<void> _refreshAll() => _loadImageUrls(forceRefresh: true);

  String? _getImageUrl(SolarImageSource source) {
    final key = _service.getWavelengthKey(source.instrument, source.wavelength);
    if (key.isNotEmpty && _latestUrls.containsKey(key)) {
      return _latestUrls[key];
    }
    return source.allUrls.isNotEmpty ? source.allUrls.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.orange,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: _refreshAll,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(child: _buildSummaryBanner()),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildImageCard(solarImageSources[index]),
                childCount: solarImageSources.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.deepOrange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              const Text(
                '多波段太阳观测',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'SDO/AIA 使用10个不同极紫外波段观测太阳大气各层温度结构；'
            'HMI测量光球层磁场；SOHO/LASCO日冕仪追踪CME传播。'
            '点击下方图像查看详细信息。',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildCategoryChip('AIA (EUV)', Colors.cyan),
              _buildCategoryChip('HMI (磁场)', Colors.blue),
              _buildCategoryChip('LASCO (日冕仪)', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImageCard(SolarImageSource source) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showImageDetail(source),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: source.color.withValues(alpha: 0.3),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildSolarImage(source),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: source.color.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        source.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _buildStatusIcon(source.id),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.name,
                    style: TextStyle(
                      color: source.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    source.wavelength,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarImage(SolarImageSource source) {
    final url = _getImageUrl(source);
    if (url == null || (_isLoadingUrls && source.category != 'LASCO')) {
      return _buildPlaceholder(source.color, source.name);
    }
    return _NetworkImage(
      url: url,
      onResult: (success) {
        if (mounted) {
          setState(() {
            _imageStates[source.id] =
                success ? ImageLoadState.loaded : ImageLoadState.error;
          });
        }
      },
      color: source.color,
      label: source.name,
    );
  }

  Widget _buildStatusIcon(String id) {
    final state = _imageStates[id] ?? ImageLoadState.loading;
    switch (state) {
      case ImageLoadState.loading:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white54,
            ),
          ),
        );
      case ImageLoadState.loaded:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 12),
        );
      case ImageLoadState.error:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.error_outline, color: Colors.red, size: 12),
        );
    }
  }

  void _showImageDetail(SolarImageSource source) {
    final url = _getImageUrl(source);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => _SolarImageDetailDialog(
        source: source,
        imageUrl: url,
      ),
    );
  }

  Widget _buildPlaceholder(Color color, String label) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.solar_power,
              size: 40,
              color: color.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '图像暂不可用',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ImageLoadState { loading, loaded, error }

class _NetworkImage extends StatefulWidget {
  final String url;
  final void Function(bool) onResult;
  final Color color;
  final String label;

  const _NetworkImage({
    required this.url,
    required this.onResult,
    required this.color,
    required this.label,
  });

  @override
  State<_NetworkImage> createState() => _NetworkImageState();
}

class _NetworkImageState extends State<_NetworkImage> {
  bool _hasError = false;
  bool _reported = false;

  @override
  void didUpdateWidget(covariant _NetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _hasError = false;
      _reported = false;
    }
  }

  void _reportOnce(bool success) {
    if (_reported) return;
    _reported = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onResult(success);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildPlaceholder();
    }

    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingOverlay();
      },
      errorBuilder: (context, error, stackTrace) {
        if (!_hasError) {
          setState(() => _hasError = true);
          _reportOnce(false);
        }
        return _buildPlaceholder();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame != null) {
          _reportOnce(true);
        }
        return child;
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: widget.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '加载 ${widget.label}...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.solar_power,
              size: 40,
              color: widget.color.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '图像暂不可用',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-size solar image viewer with copy-link and save-to-disk actions.
class _SolarImageDetailDialog extends StatefulWidget {
  final SolarImageSource source;
  final String? imageUrl;

  const _SolarImageDetailDialog({
    required this.source,
    required this.imageUrl,
  });

  @override
  State<_SolarImageDetailDialog> createState() =>
      _SolarImageDetailDialogState();
}

class _SolarImageDetailDialogState extends State<_SolarImageDetailDialog> {
  bool _saving = false;

  String? get _url => widget.imageUrl;

  Future<void> _copyUrl() async {
    final url = _url;
    if (url == null || url.isEmpty) {
      _toast('暂无可用图像链接');
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    _toast('已复制图像链接');
  }

  Future<void> _saveImage() async {
    final url = _url;
    if (url == null || url.isEmpty) {
      _toast('暂无可用图像');
      return;
    }

    final stamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .split('.')
        .first;
    final suggestedName =
        '${widget.source.id}_$stamp.jpg'.replaceAll(' ', '_');

    setState(() => _saving = true);
    try {
      // Ask for path first so Linux users see a dialog immediately.
      final savePath = await _pickSavePath(suggestedName);
      if (savePath == null) {
        if (mounted) setState(() => _saving = false);
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'User-Agent': 'SpaceWeather/1.0 (Flutter; educational)',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('下载失败 HTTP ${response.statusCode}');
      }

      final file = File(savePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes, flush: true);

      if (!mounted) return;
      _toast('已保存到 $savePath');
    } catch (e) {
      if (!mounted) return;
      _toast('保存失败: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Linux GTK file chooser often fails under Wayland; prefer zenity.
  Future<String?> _pickSavePath(String suggestedName) async {
    if (Platform.isLinux) {
      final zenity = await _pickSavePathWithZenity(suggestedName);
      if (zenity.available) {
        // Dialog was shown; null path means user canceled.
        return zenity.path;
      }
    }

    try {
      final location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'JPEG',
            extensions: ['jpg', 'jpeg'],
            mimeTypes: ['image/jpeg'],
          ),
        ],
      );
      if (location != null) return location.path;
      if (!Platform.isLinux) return null;
    } catch (_) {
      // Fall through to Downloads on Linux.
    }

    if (Platform.isLinux) {
      final downloads = _defaultDownloadsPath(suggestedName);
      _toast('未能打开文件对话框，将保存到 $downloads');
      return downloads;
    }
    return null;
  }

  Future<({bool available, String? path})> _pickSavePathWithZenity(
    String suggestedName,
  ) async {
    try {
      final initial = _defaultDownloadsPath(suggestedName);
      final result = await Process.run(
        'zenity',
        [
          '--file-selection',
          '--save',
          '--confirm-overwrite',
          '--title=保存太阳图像',
          '--filename=$initial',
          '--file-filter=JPEG images | *.jpg *.jpeg',
        ],
      );
      if (result.exitCode != 0) {
        return (available: true, path: null);
      }
      final path = (result.stdout as String).trim();
      return (available: true, path: path.isEmpty ? null : path);
    } on ProcessException {
      return (available: false, path: null);
    } catch (_) {
      return (available: false, path: null);
    }
  }

  String _defaultDownloadsPath(String suggestedName) {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      return '$home/Downloads/$suggestedName';
    }
    return '${Directory.systemTemp.path}/$suggestedName';
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final source = widget.source;
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.95,
          maxHeight: size.height * 0.95,
          minWidth: 320,
          minHeight: 400,
        ),
        child: SizedBox(
          width: size.width * 0.9,
          height: size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Icon(Icons.solar_power, color: source.color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: TextStyle(
                              color: source.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${source.instrument} | ${source.wavelength}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '复制链接',
                      onPressed: _saving ? null : _copyUrl,
                      icon: const Icon(Icons.link),
                    ),
                    IconButton(
                      tooltip: '保存到本地',
                      onPressed: _saving ? null : _saveImage,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.54),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              Expanded(
                child: ColoredBox(
                  color: Colors.black,
                  child: _url == null
                      ? Center(
                          child: Text(
                            '图像暂不可用',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 8,
                          child: SizedBox.expand(
                            child: Image.network(
                              _url!,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.high,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: source.color,
                                    value: loadingProgress
                                                .expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress
                                                .expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    '图像加载失败',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.descriptionZh,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      source.description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '提示：双指/滚轮可缩放，拖动可平移；工具栏可复制链接或保存原图。',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

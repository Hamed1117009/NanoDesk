import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Original banner asset size used to preserve aspect ratio in the footer.
const double kBannerAspectWidth = 1792;
const double kBannerAspectHeight = 592;

class BottomAdBanners extends StatefulWidget {
  const BottomAdBanners({Key? key}) : super(key: key);

  @override
  State<BottomAdBanners> createState() => _BottomAdBannersState();
}

class _BottomAdBannersState extends State<BottomAdBanners> {
  List<Map<String, String>> _banners = [];

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final response = await http
          .get(Uri.parse('https://onlist.ir/api/banner/NanoDesk'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return;
      }

      final body = response.body.trim();
      if (body.isEmpty || body.startsWith('<')) {
        return;
      }

      final decoded = json.decode(body);
      if (decoded is! List) {
        return;
      }

      final banners = <Map<String, String>>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final picUrl = item['pic']?.toString() ?? '';
        final linkUrl = item['url']?.toString() ?? '';
        if (picUrl.isEmpty) {
          continue;
        }
        banners.add({'pic': picUrl, 'url': linkUrl});
      }

      if (!mounted || banners.isEmpty) {
        return;
      }

      setState(() {
        _banners = banners;
      });
    } catch (_) {
      // API unavailable or invalid response: leave banner area empty.
    }
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildBannerSlot(Map<String, String>? banner, double height) {
    if (banner == null) {
      return SizedBox(height: height);
    }

    final picUrl = banner['pic'] ?? '';
    final linkUrl = banner['url'] ?? '';

    return SizedBox(
      height: height,
      child: InkWell(
        onTap: linkUrl.isNotEmpty ? () => _launchUrl(linkUrl) : null,
        child: Image.network(
          picUrl,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final first = _banners.isNotEmpty ? _banners[0] : null;
    final second = _banners.length > 1 ? _banners[1] : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= 0) {
          return const SizedBox.shrink();
        }

        final height = width * kBannerAspectHeight / kBannerAspectWidth;

        return SizedBox(
          width: width,
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildBannerSlot(first, height)),
              Expanded(child: _buildBannerSlot(second, height)),
            ],
          ),
        );
      },
    );
  }
}

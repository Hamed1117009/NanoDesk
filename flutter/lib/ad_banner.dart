import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 266,
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _banners.map((banner) {
          final picUrl = banner['pic'] ?? '';
          final linkUrl = banner['url'] ?? '';

          return Expanded(
            child: InkWell(
              onTap: linkUrl.isNotEmpty ? () => _launchUrl(linkUrl) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.network(
                  picUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

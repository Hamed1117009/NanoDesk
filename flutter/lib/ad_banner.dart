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
  // لیستی برای ذخیره اطلاعات بنرها پس از دریافت از API
  List<dynamic> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // فراخوانی متد دریافت اطلاعات در زمان لود شدن ویجت
    _fetchBanners();
  }

  // متد دریافت اطلاعات از API با GET
  Future<void> _fetchBanners() async {
    try {
      final response = await http.get(Uri.parse('https://onlist.ir/api/banner/NanoDesk'));
      
      if (response.statusCode == 200) {
        // تبدیل رشته JSON به یک آرایه (List) در دارت
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _banners = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // متد باز کردن لینک در مرورگر
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 260, // ارتفاع متناسب با سایز جدید برای حالت در حال بارگذاری
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return Container(
      height: 266, // ۲۵۰ پیکسل برای ارتفاع بنر + حدود ۱۶ پیکسل برای حاشیه‌ها (padding)
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // قرارگیری در مرکز
        children: _banners.map((banner) {
          final picUrl = banner['pic']?.toString() ?? '';
          final linkUrl = banner['url']?.toString() ?? '';

          return Expanded(
            child: InkWell(
              onTap: () {
                if (linkUrl.isNotEmpty) {
                  _launchUrl(linkUrl);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // فاصله بین دو بنر
                child: picUrl.isNotEmpty
                    ? Image.network(
                        picUrl,
                        fit: BoxFit.contain, // برای اینکه کل عکس ۳۰۰x۲۵۰ بدون برش خوردن نمایش داده شود
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
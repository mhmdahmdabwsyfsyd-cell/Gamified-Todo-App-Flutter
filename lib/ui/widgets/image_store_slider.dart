import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class ImageStoreSlider extends StatefulWidget {
  const ImageStoreSlider({Key? key}) : super(key: key);

  @override
  State<ImageStoreSlider> createState() => _ImageStoreSliderState();
}

class _ImageStoreSliderState extends State<ImageStoreSlider> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  
  // قائمة مسارات الصور من مجلد assets وأسعارها
  final List<Map<String, dynamic>> storeItems = [
    {"path": "assets/avatars/av1.png", "cost": 20},
    {"path": "assets/avatars/av2.png", "cost": 40},
    {"path": "assets/avatars/av3.png", "cost": 60},
    {"path": "assets/avatars/av4.png", "cost": 80},
     {"path": "assets/avatars/av5.png", "cost": 100},
    {"path": "assets/avatars/av6.png", "cost": 120},
    {"path": "assets/avatars/av7.png", "cost": 140},
    {"path": "assets/avatars/av8.png", "cost": 160},
    {"path": "assets/avatars/av9.png", "cost": 200},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollController.offset + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return SizedBox(
      height: 110, // زدت الطول لتظهر الصور بشكل أوضح
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: storeItems.length * 100,
        itemBuilder: (context, index) {
          final item = storeItems[index % storeItems.length];
          final String path = item['path'];
          final bool isUnlocked = provider.userStats.unlockedImages.contains(path);
          final bool isSelected = provider.userStats.currentAvatar == path;

          return GestureDetector(
            onTap: () {
              if (isUnlocked) {
                provider.setAvatar(path);
              } else {
                if (provider.buyImage(path, item['cost'])) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح الصورة بنجاح!')));
                }
              }
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : (isUnlocked ? Colors.green : Colors.white24),
                  width: 3,
                ),
                boxShadow: isSelected ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10)] : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand, // لتملأ الصورة الكارت بالكامل
                  children: [
                    // الصورة تملأ الكارت
                    Image.asset(path, fit: BoxFit.cover),
                    
                    // طبقة شفافة تظهر السعر إذا لم تكن مشتراة
                    if (!isUnlocked)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Text('${item['cost']} XP', 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    // علامة "صح" إذا كانت مختارة
                    if (isSelected)
                      const Positioned(
                        top: 2, right: 2,
                        child: Icon(Icons.check_circle, color: Colors.cyanAccent, size: 20),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
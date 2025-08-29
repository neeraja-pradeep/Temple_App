import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import '../features/special/presentation/special_page.dart';
import '../features/pooja/presentation/pooja_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/shop/presentation/shop_page.dart';
import '../features/music/presentation/music_page.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 2;
  final List<Widget> _pages = const [
    SpecialPage(),
    PoojaPage(),
    HomePage(),
    ShopPage(),
    MusicPage(),
  ];
  final List<String> _labels = [
    'പ്രത്യകം', // Special
    'പൂജ', // Pooja
    'ഹോം', // Home
    'ഷോപ്പ്', // Shop
    'സംഗീതം', // Music
  ];
  final List<String> _icons = [
    'assets/bottomNavBar/bn1.png',
    'assets/bottomNavBar/bn2.png',
    'assets/bottomNavBar/bn3.png',
    'assets/bottomNavBar/bn4.png',
    'assets/bottomNavBar/bn5.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.topCenter,
          ),
          _pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppColors.navBarBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isSelected
                      ? Container(
                          width: 63.w,
                          height: 50.h,

                          decoration: BoxDecoration(
                            color: AppColors
                                .selectedBackground, // white background
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color:
                                  AppColors.selectedBackground, // border color
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(
                                  140,
                                  0,
                                  26,
                                  0.16,
                                ), // shadow color rgba(140, 0, 26, 0.16)
                                offset: Offset(0, 4.h),
                                blurRadius: 16.r,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                _icons[index],
                                width: 28.w,
                                height: 28.h,
                                color: AppColors.selected,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _labels[index],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.selected,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Image.asset(
                          _icons[index],
                          width: 24.w,
                          height: 24.w,
                          color: AppColors.unselected,
                        ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temple App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainNavScreen(),
      builder: (context, child) {
        ScreenUtil.init(context);
        return child!;
      },
    );
  }
}

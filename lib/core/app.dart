import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import '../features/special/presentation/special_page.dart';
import '../features/pooja/presentation/pooja_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/shop/presentation/shop_page.dart';
import '../features/music/presentation/music_page.dart';

class MainNavScreen extends StatefulWidget {
  final Widget? drawerContent;
  const MainNavScreen({super.key, this.drawerContent});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 2;
  final List<Widget> _pages = [
    SpecialPage(),
    PoojaPage(),
    HomePage(),
    ShopPage(),
    MusicPage(),
  ];
  final List<String> _labels = [
    'പ്രത്യകം', // Special
    'പൂജ', // Pooja
    'ദർശനം', // Home
    'വിപണി', // Shop
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
    // Set status bar style to light content (white icons and text)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Scaffold(
        drawer: _selectedIndex == 2
            ? Drawer(
                backgroundColor: Color(0xFFD9D9D9),
                width: 285.w,
                child: Consumer(
                  builder: (context, ref, _) =>
                      HomePage.buildDrawerContent(context, ref),
                ),
              )
            : null,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/background.jpg',
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
                                color: AppColors
                                    .selectedBackground, // border color
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
                                  height: 28.w,
                                  color: AppColors.selected,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _labels[index],
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.selected,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.asset(
                            _icons[index],
                            height: 26.h,
                            width: 26.w,
                            color: AppColors.unselected,
                          ),
                  ],
                ),
              );
            }),
          ),
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
      debugShowCheckedModeBanner: false,
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

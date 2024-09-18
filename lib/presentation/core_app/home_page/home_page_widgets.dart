part of 'home_page_screen.dart';

class _HomePageWidget extends StatefulWidget {
  @override
  State<_HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<_HomePageWidget>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedTabIndex = 3;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: DoublePressToExit(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Body.big(
                      text: 'BALANCE DUE',
                      color: AppColors.textSecondary,
                    ),
                    CurrencyDisplayText(value: 245781.98),
                  ],
                ),
              ),
              _LineChartData(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.only(top: 6, bottom: 6),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary,
                  ),
                  tabs: [
                    Tab(
                      child: Body.smallBold(
                        text: '1W',
                        color: _selectedTabIndex == 0
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    Tab(
                      child: Body.smallBold(
                        text: '1M',
                        color: _selectedTabIndex == 1
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    Tab(
                      child: Body.smallBold(
                        text: '3M',
                        color: _selectedTabIndex == 2
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    Tab(
                      child: Body.smallBold(
                        text: '6M',
                        color: _selectedTabIndex == 3
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    Tab(
                      child: Body.smallBold(
                        text: 'YTD',
                        color: _selectedTabIndex == 4
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    Tab(
                      child: Body.smallBold(
                        text: '1Y',
                        color: _selectedTabIndex == 5
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    Tab(
                      child: Body.smallBold(
                        text: 'ALL',
                        color: _selectedTabIndex == 6
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: CustomAppBar(
        title: 'Credit cards',
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/home.svg'),
            activeIcon:
                BottomNavigationIcon(iconKey: 'assets/icons/home_filled.svg'),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/invest.svg'),
            activeIcon:
                BottomNavigationIcon(iconKey: 'assets/icons/invest_filled.svg'),
            label: 'INVEST',
          ),
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/discover.svg'),
            activeIcon: BottomNavigationIcon(
                iconKey: 'assets/icons/discover_filled.svg'),
            label: 'DISCOVER',
          ),
          BottomNavigationBarItem(
            icon: BottomNavigationIcon(iconKey: 'assets/icons/account.png'),
            activeIcon: BottomNavigationIcon(
                iconKey: 'assets/icons/account_filled.png'),
            label: 'ACCOUNT',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _LineChartData extends StatelessWidget {
  final List<Color> gradientColors = [
    AppColors.primary,
    AppColors.primaryVariation1,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.safeAreaScreenHeight / 3,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(2.6, 2),
                FlSpot(4.9, 5),
                FlSpot(6.8, 3.1),
                FlSpot(8, 4),
                FlSpot(9.5, 3),
                FlSpot(11, 4),
              ],
              isCurved: true,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
            ),
          ],
          gridData: FlGridData(
            show: false, // This removes the grid
          ),
          borderData: FlBorderData(
            show: false, // This removes the border around the chart
          ),
          titlesData: FlTitlesData(
            show: false, // This hides all the numbers and titles on the axes
          ),
        ),
      ),
    );
  }
}
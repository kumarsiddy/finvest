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
      backgroundColor: AppColors.primaryBackground,
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.only(top: 6, bottom: 6),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary,
                    ),
                    dividerColor: AppColors.transparent,
                    tabs: [
                      Tab(
                        child: Label.medium(
                          text: '1W',
                          color: _selectedTabIndex == 0
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Tab(
                        child: Label.medium(
                          text: '1M',
                          color: _selectedTabIndex == 1
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Tab(
                        child: Label.medium(
                          text: '3M',
                          color: _selectedTabIndex == 2
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Tab(
                        child: Label.medium(
                          text: '6M',
                          color: _selectedTabIndex == 3
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Tab(
                        child: Label.medium(
                          text: 'YTD',
                          color: _selectedTabIndex == 4
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Tab(
                        child: Label.medium(
                          text: '1Y',
                          color: _selectedTabIndex == 5
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      Tab(
                        child: Label.medium(
                          text: 'ALL',
                          color: _selectedTabIndex == 6
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _CreditCardsWidget(),
              _SpendCardWidget(),
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

final _cardItems = [
  CreditCardItem(
    iconKey: 'assets/icons/wells_fargo.png',
    title: "Wellsfargo Gold",
    balance: 23456.99,
    cardNumber: 'Asset ****6375',
  ),
  CreditCardItem(
    iconKey: 'assets/icons/citi.png',
    title: 'Citi Platinum',
    balance: 23456.99,
    cardNumber: 'Asset ****6006',
  ),
];

class _CreditCardsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header.small(text: 'Credit Cards'),
            Divider(thickness: 0.3),
            ListView.builder(
              itemCount: _cardItems.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _CreditCardItem(cardItem: _cardItems[index]);
              },
            ),
            Divider(thickness: 0.3),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Body.smallBold(text: 'ADD ACCOUNT'),
                  SmallIcon(iconKey: 'assets/icons/add.svg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCardItem extends StatelessWidget {
  final CreditCardItem cardItem;

  const _CreditCardItem({
    super.key,
    required this.cardItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(iconKey: cardItem.iconKey),
          SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Body.big(text: cardItem.title),
              Body.small(text: cardItem.cardNumber),
            ],
          ),
          Spacer(),
          Body.big(text: '\$${cardItem.balance}')
        ],
      ),
    );
  }
}

final _spendItems = [
  SpendItem(
    iconKey: 'assets/icons/burger.svg',
    bgColor: 'D4EAF6',
    title: "Foods & dining",
    amount: 5300.32,
    details: '90% of spends',
  ),
  SpendItem(
    iconKey: 'assets/icons/electronics.svg',
    bgColor: 'FCF0D6',
    title: 'Apps & software',
    amount: 2300.79,
    details: '90% of spends',
  ),
  SpendItem(
    iconKey: 'assets/icons/health_wellness.svg',
    bgColor: 'E7E3FF',
    title: 'Health & wellness',
    amount: 1400.39,
    details: '4% of spends',
  ),
];

class _SpendCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header.small(text: 'Top categories'),
            Divider(thickness: 0.3),
            ListView.builder(
              itemCount: _spendItems.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _SpendItemWidget(spendItem: _spendItems[index]);
              },
            ),
            Divider(thickness: 0.3),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Body.smallBold(text: 'SEE ALL CATEGORIES'),
                  const SizedBox(width: 4),
                  SmallIcon(iconKey: 'assets/icons/right_arrow.svg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendItemWidget extends StatelessWidget {
  final SpendItem spendItem;

  const _SpendItemWidget({
    super.key,
    required this.spendItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIcon(
            iconKey: spendItem.iconKey,
            colorHash: spendItem.bgColor,
          ),
          SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Body.big(text: spendItem.title),
              const SizedBox(width: 4),
              Body.small(text: spendItem.details),
            ],
          ),
          Spacer(),
          Body.big(text: '\$${spendItem.amount}')
        ],
      ),
    );
  }
}
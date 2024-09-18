part of 'credit_card_page.dart';

class _CreditCardPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 3.375 / 2.125,
              child: _CreditCardWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // elevation: 4,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Body.big(text: 'CHASE'),
                    Body.big(text: 'VISA'),
                  ],
                ),
                SizedBox(height: 36),
                Body.big(text: '**** **** **** 7628'),
              ],
            ),
          ),
          Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
              color: Colors.blue,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Body.small(
                      text: 'TOTAL DUE',
                      color: Colors.white,
                    ),
                    Body.big(
                      text: '\$24,890.00',
                      color: Colors.white,
                    ),
                  ],
                ),
                Spacer(),
                FlexibleIcon(
                  iconKey: 'assets/icons/chip.svg',
                  height: 36,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CreditCardInfoListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {});
  }
}

class _CreditCardInfoItemWidget extends StatelessWidget {
  final CreditCardItem creditCardItem;

  const _CreditCardInfoItemWidget({
    super.key,
    required this.creditCardItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(iconKey: creditCardItem.iconKey),
        ],
      ),
    );
  }
}
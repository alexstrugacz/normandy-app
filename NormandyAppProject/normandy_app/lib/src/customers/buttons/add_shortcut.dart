import 'package:flutter/material.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:normandy_app/src/customers/customer_utils.dart';

class AddShortcutToOneDrive extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Customer? customer;
  final bool mounted;

  const AddShortcutToOneDrive({
    super.key,
    this.icon,
    required this.text,
    required this.customer,
    required this.mounted,
  });

  bool isValid() {
    return customer != null && customer!.spUrl.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => CustomerUtils.addShortcutToOneDrive(mounted, customer, context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                icon,
                size: 16,
                color: (isValid() ? Colors.blue : Colors.grey),
              ),
            ),
          Text(
            text,
            style: TextStyle(
              color: (isValid() ? Colors.blue : Colors.grey),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

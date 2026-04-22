import 'package:flutter/material.dart';
import 'package:welangflood/src/common_widets/filled%20button/button.dart';
import 'package:welangflood/src/common_widets/transition/transition.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/screens/entri/entri_survei.dart';

class EntriButton extends StatelessWidget {
  final bool compact;
  final bool fillHeight;

  const EntriButton({
    super.key,
    this.compact = false,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = compact ? 300.0 : 375.0;
        final double containerWidth =
            constraints.maxWidth < maxWidth ? constraints.maxWidth : maxWidth;
        final double horizontalPadding = compact
            ? screenSize.width * 0.028
            : screenSize.width * 0.0427;
        final double verticalPadding = compact
            ? screenSize.height * 0.014
            : screenSize.height * 0.0266;
        final double titleSize = compact
            ? screenSize.width * 0.029
            : screenSize.width * 0.035;
        final double buttonHeight = compact
            ? screenSize.height * 0.047
            : screenSize.height * 0.055;

        return Container(
          width: containerWidth,
          height: fillHeight ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tPrimaryColor),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: fillHeight ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.file_copy,
                    size: screenSize.width * 0.058,
                    color: tPrimaryColor,
                  ),
                  SizedBox(width: screenSize.width * 0.028),
                  Expanded(
                    child: Text(
                      tEntriTitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tPrimaryColor,
                        fontFamily: 'Inter',
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 8 : screenSize.height * 0.0213),
              CustomElevatedButton(
                height: buttonHeight,
                onPressed: () {
                  TransitionUtils.navigateWithFadeTransition(context, const EntriSurvei());
                },
                text: tEntriButton,
                foregroundColor: tTertiaryColor,
                backgroundColor: tPrimaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

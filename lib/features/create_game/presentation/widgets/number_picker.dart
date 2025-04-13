import 'package:chronicle/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  final int from;
  final int to;
  final Function(int) onNumberChanged;

  const NumberPicker(
      {super.key,
      required this.from,
      required this.to,
      required this.onNumberChanged});

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  int? selectedNumber;

  @override
  void initState() {
    super.initState();
    selectedNumber = widget.from;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: widget.to - widget.from + 1,
          itemBuilder: (context, index) {
            return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedNumber = widget.from + index;
                    widget.onNumberChanged(selectedNumber!);
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.zero,
                  backgroundColor: selectedNumber == widget.from + index
                      ? AppColors.primary
                      : AppColors.surface,
                  foregroundColor: selectedNumber == widget.from + index
                      ? AppColors.surface
                      : AppColors.textColor,
                ),
                child: Text("${widget.from + index}"));
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 2,
            );
          }),
    );
  }
}

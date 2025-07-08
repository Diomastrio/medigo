import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;
  final Color selectedColor;
  final Color unselectedColor;
  final double itemHeight;
  final int visibleItemCount;

  const CustomTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
    this.selectedColor = const Color(0xFF4FC3F7),
    this.unselectedColor = const Color(0xFF9E9E9E),
    this.itemHeight = 60.0,
    this.visibleItemCount = 3,
  }) : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onHourChanged(int hour) {
    setState(() {
      _selectedHour = hour;
    });
    widget.onTimeChanged(TimeOfDay(hour: hour, minute: _selectedMinute));
  }

  void _onMinuteChanged(int minute) {
    setState(() {
      _selectedMinute = minute;
    });
    widget.onTimeChanged(TimeOfDay(hour: _selectedHour, minute: minute));
  }

  void _updateFromNativePicker(TimeOfDay newTime) {
    setState(() {
      _selectedHour = newTime.hour;
      _selectedMinute = newTime.minute;
    });
    
    // Update the scroll controllers to reflect the new time
    _hourController.animateToItem(
      _selectedHour,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _minuteController.animateToItem(
      _selectedMinute,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    widget.onTimeChanged(newTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.itemHeight * widget.visibleItemCount,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour Picker
              Expanded(
                child: _buildScrollPicker(
                  controller: _hourController,
                  itemCount: 24,
                  selectedValue: _selectedHour,
                  onSelectedItemChanged: _onHourChanged,
                  formatValue: (value) => value.toString().padLeft(2, '0'),
                ),
              ),

              // Separator
              Container(
                width: 40,
                child: Center(
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: widget.selectedColor,
                    ),
                  ),
                ),
              ),

              // Minute Picker
              Expanded(
                child: _buildScrollPicker(
                  controller: _minuteController,
                  itemCount: 60,
                  selectedValue: _selectedMinute,
                  onSelectedItemChanged: _onMinuteChanged,
                  formatValue: (value) => value.toString().padLeft(2, '0'),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Alternative: Tap to open native time picker
        TextButton(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
            );
            if (picked != null) {
              _updateFromNativePicker(picked);
            }
          },
          child: Text(
            'O toca aquí para seleccionar tiempo',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedValue,
    required Function(int) onSelectedItemChanged,
    required String Function(int) formatValue,
  }) {
    return Stack(
      children: [
        // ListWheelScrollView for scrolling
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: widget.itemHeight,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          perspective: 0.005,
          diameterRatio: 1.2,
          squeeze: 1.0,
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= itemCount) return null;

              final isSelected = index == selectedValue;

              return Container(
                height: widget.itemHeight,
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 24 : 12,
                      vertical: isSelected ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.selectedColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(isSelected ? 25 : 12),
                    ),
                    child: Text(
                      formatValue(index),
                      style: TextStyle(
                        fontSize: isSelected ? 28 : 20,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : widget.unselectedColor,
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: itemCount,
          ),
        ),

        // Selection indicator (optional - creates the highlighted area effect)
        Positioned.fill(
          child: Center(
            child: Container(
              height: widget.itemHeight,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: widget.selectedColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget complementario para mostrar números adicionales arriba y abajo (como en tu diseño)
class TimePickerWithContext extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;
  final Color selectedColor;
  final Color unselectedColor;

  const TimePickerWithContext({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
    this.selectedColor = const Color(0xFF4FC3F7),
    this.unselectedColor = const Color(0xFF9E9E9E),
  }) : super(key: key);

  @override
  _TimePickerWithContextState createState() => _TimePickerWithContextState();
}

class _TimePickerWithContextState extends State<TimePickerWithContext> {
  late TimeOfDay _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.initialTime;
  }

  void _onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _currentTime = newTime;
    });
    widget.onTimeChanged(newTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Context numbers (top)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              child: Center(
                child: Text(
                  ((_currentTime.hour - 1) % 24).toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 18, color: widget.unselectedColor),
                ),
              ),
            ),
            SizedBox(width: 40),
            Container(
              width: 80,
              child: Center(
                child: Text(
                  ((_currentTime.minute - 1) % 60).toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 18, color: widget.unselectedColor),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8),

        // Main time picker
        Container(
          height: 200,
          child: CustomTimePicker(
            initialTime: widget.initialTime,
            onTimeChanged: _onTimeChanged,
            selectedColor: widget.selectedColor,
            unselectedColor: widget.unselectedColor,
            itemHeight: 60,
            visibleItemCount: 3,
          ),
        ),

        SizedBox(height: 8),

        // Context numbers (bottom)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              child: Center(
                child: Text(
                  ((_currentTime.hour + 1) % 24).toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 18, color: widget.unselectedColor),
                ),
              ),
            ),
            SizedBox(width: 40),
            Container(
              width: 80,
              child: Center(
                child: Text(
                  ((_currentTime.minute + 1) % 60).toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 18, color: widget.unselectedColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Ejemplo de uso simple
class SimpleTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const SimpleTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _SimpleTimePickerState createState() => _SimpleTimePickerState();
}

class _SimpleTimePickerState extends State<SimpleTimePicker> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return TimePickerWithContext(
      initialTime: widget.initialTime,
      onTimeChanged: (TimeOfDay time) {
        setState(() {
          _selectedTime = time;
        });
        widget.onTimeChanged(time);
      },
      selectedColor: Colors.blue[400]!,
      unselectedColor: Colors.grey[600]!,
    );
  }
}

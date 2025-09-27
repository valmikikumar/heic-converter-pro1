import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double? strokeWidth;
  final bool showPercentage;

  const CustomProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.strokeWidth,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final progressStrokeWidth = strokeWidth ?? 4.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: progressStrokeWidth,
                backgroundColor: progressColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            if (showPercentage)
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class LinearProgressWithLabel extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double? height;
  final bool showPercentage;

  const LinearProgressWithLabel({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.height,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final progressHeight = height ?? 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showPercentage)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(progressHeight / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: progressHeight,
            backgroundColor: progressColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColorFinal = activeColor ?? theme.colorScheme.primary;
    final inactiveColorFinal = inactiveColor ?? theme.colorScheme.outline;

    return Column(
      children: [
        // Progress line
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  // Step circle
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isActive
                          ? activeColorFinal
                          : inactiveColorFinal,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                          : Text(
                              '${index + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isActive
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  // Connecting line
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < currentStep
                            ? activeColorFinal
                            : inactiveColorFinal.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        
        const SizedBox(height: 8),
        
        // Step labels
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;
            
            return Expanded(
              child: Text(
                stepLabels[index],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCompleted || isActive
                      ? activeColorFinal
                      : inactiveColorFinal,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final double progress;
  final String? label;
  final Color? color;
  final Duration animationDuration;

  const AnimatedProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: oldWidget.progress, end: widget.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomProgressIndicator(
          progress: _animation.value,
          label: widget.label,
          color: widget.color,
        );
      },
    );
  }
}

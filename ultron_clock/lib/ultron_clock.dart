import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pigment/pigment.dart';
import 'package:ultron_clock/analog/container_hand.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

final radiansPerTick = radians(360 / 60);
final radiansPerHour = radians(360 / 12);

class UltronClock extends StatefulWidget {
  UltronClock(this.model);

  final ClockModel model;

  @override
  _UltronClockState createState() => _UltronClockState();
}

class _UltronClockState extends State<UltronClock> {
  var duration = Duration(milliseconds: 1000);
  var _now = DateTime.now();
  var _temperature = '';
  var _condition = WeatherCondition.sunny;
  var _highTemp = '';
  var _lowTemp = '';
  var _location = '';
  bool isAnalog = true;
  bool isAm = true;
  bool isDay = true;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(UltronClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _condition = widget.model.weatherCondition;
      _highTemp = widget.model.highString;
      _lowTemp = widget.model.lowString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      isAm = DateFormat('a').format(_now).toLowerCase() == 'am';
      var startOfNightTime =
          DateTime(_now.year, _now.month, _now.day, 18, 0, 0);
      var startOfDayTime = DateTime(_now.year, _now.month, _now.day, 6, 0, 0);
      isDay = _now.isAfter(startOfDayTime) && _now.isBefore(startOfNightTime);
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _now.second) -
            Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    Size size = media.size;
    final orientation = media.orientation;
    final day = DateFormat.EEEE().format(DateTime.now());
    final date = DateFormat.d().format(DateTime.now());
    final month = DateFormat.MMMM().format(DateTime.now());
    final year = DateFormat.y().format(DateTime.now());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final customTheme = isDark
        ? theme.copyWith(
            primaryColor: Colors.white,
            highlightColor: Color(0xFF8AB4F8),
            splashColor: Pigment.fromString('#4f99f5'),
            accentColor: Colors.white,
            indicatorColor: Colors.white,
            backgroundColor: Color(0xFFD2E3FC),
          )
        : theme.copyWith(
            primaryColor: Colors.black,
            highlightColor: Color(0xFF4285F4),
            splashColor: Pigment.fromString('#131c66'),
            accentColor: Pigment.fromString('#4f99f5'),
            indicatorColor: Pigment.fromString('#ffa800'),
            backgroundColor: Color(0xFF3C4043),
          );
    final TextTheme textTheme = customTheme.textTheme;
    bool hasFullView = orientation == Orientation.landscape &&
        size.height > 650 &&
        size.width > 1100;

    _smallHand() {
      return ContainerHand(
        color: Colors.transparent,
        size: 0.6,
        angleRadians:
            (_now.hour * radiansPerHour + (_now.minute / 60) * radiansPerHour),
        child: Transform.translate(
          offset: Offset(0.0, -160.0),
          child: Container(
            width: 20,
            height: 220,
            decoration: BoxDecoration(
              color: customTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? customTheme.splashColor
                      : customTheme.splashColor.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: isDark ? 35 : 30,
                )
              ],
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
          ),
        ),
      );
    }

    _largeHand() {
      return ContainerHand(
        color: Colors.transparent,
        size: 0.6,
        angleRadians: _now.minute * radiansPerTick,
        child: Transform.translate(
          offset: Offset(0.0, -215.0),
          child: Container(
            width: 20,
            height: 330,
            decoration: BoxDecoration(
              color: customTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? customTheme.splashColor
                      : customTheme.splashColor.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: isDark ? 35 : 30,
                )
              ],
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
          ),
        ),
      );
    }

    _clockDot() {
      return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Pigment.fromString('#E23530')),
        height: 20,
        width: 20,
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.black : Colors.white),
          height: 6,
          width: 6,
        ),
      );
    }

    _leftView() {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: hasFullView
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: <Widget>[
                AnimatedDefaultTextStyle(
                  duration: duration,
                  child: Text(
                    day,
                  ),
                  style: textTheme.headline.copyWith(
                      color: customTheme.primaryColor,
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w200),
                  textAlign: TextAlign.center,
                ),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: duration,
                    child: Text(
                      date,
                    ),
                    style: textTheme.display3.copyWith(
                        color: customTheme.primaryColor,
                        fontFamily: 'Inter',
                        fontSize: 100,
                        letterSpacing: -1),
                    textAlign: TextAlign.center,
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  child: Text(
                    month + ' ' + year,
                  ),
                  style: textTheme.body1.copyWith(
                      color: customTheme.primaryColor,
                      fontFamily: 'Inter',
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (hasFullView)
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedOpacity(
                        duration: duration,
                        opacity: 0.3,
                        child: SvgPicture.asset(
                          'assets/icons/weather-icon-snowy.svg',
                          color: customTheme.primaryColor,
                          height: 50,
                          width: 50,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: kIsWeb
                            ? Image.asset(
                                'assets/icons/weather-icon-cloudy.png',
                                height: 100,
                                width: 100,
                              )
                            : SvgPicture.asset(
                                weatherAsset,
                                height: 100,
                                width: 100,
                                color: customTheme.accentColor,
                              ),
                      ),
                      AnimatedOpacity(
                        duration: duration,
                        opacity: 0.3,
                        child: SvgPicture.asset(
                          'assets/icons/weather-icon-windy.svg',
                          color: customTheme.primaryColor,
                          height: 50,
                          width: 50,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    child: Text(
                      _location,
                    ),
                    style: textTheme.body1.copyWith(
                        color: customTheme.primaryColor,
                        fontFamily: 'Inter',
                        fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    child: Text(
                      getRoundedTemperatureWithoutUnit(_temperature),
                    ),
                    style: textTheme.display2.copyWith(
                        color: customTheme.primaryColor,
                        fontFamily: 'Inter',
                        letterSpacing: -1,
                        fontSize: 65,
                        fontWeight: FontWeight.w100),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            getRoundedTemperatureWithoutUnit(_highTemp),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 3),
                          child: Icon(
                            Icons.arrow_upward,
                            color: customTheme.primaryColor,
                            size: 15,
                          ),
                        ),
                        SizedBox(width: 10),
                        Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.arrow_downward,
                            color: customTheme.primaryColor,
                            size: 15,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            getRoundedTemperatureWithoutUnit(_lowTemp),
                          ),
                        ),
                      ],
                    ),
                    style: textTheme.body1.copyWith(
                        color: customTheme.primaryColor,
                        fontFamily: 'Inter',
                        fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
        ],
      );
    }

    _rightView() {
      return Row(
        children: <Widget>[
          Flexible(
            flex: 87,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    AnimatedDefaultTextStyle(
                      duration: duration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AnimatedOpacity(
                            duration: duration,
                            opacity: isAm ? 1 : 0.3,
                            child: Text(
                              'AM',
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          AnimatedOpacity(
                            duration: duration,
                            opacity: isAm ? 0.3 : 1,
                            child: Text(
                              'PM',
                            ),
                          ),
                        ],
                      ),
                      style: textTheme.body1.copyWith(
                          color: customTheme.primaryColor,
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w200),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    AnimatedOpacity(
                        duration: duration,
                        opacity: isDay ? 1 : 0.25,
                        child: kIsWeb
                            ? Image.asset(
                                'assets/icons/mode-icon-light.png',
                                height: 50,
                                width: 50,
                              )
                            : SvgPicture.asset(
                                'assets/icons/mode-icon-light.svg',
                                color: customTheme.accentColor,
                                height: 50,
                                width: 50,
                              )),
                    SizedBox(
                      width: 10,
                    ),
                    AnimatedOpacity(
                      duration: duration,
                      opacity: isDay ? 0.25 : 1,
                      child: kIsWeb
                          ? Image.asset(
                              'assets/icons/mode-icon-dark.png',
                              height: 50,
                              width: 50,
                            )
                          : SvgPicture.asset(
                              'assets/icons/mode-icon-dark.svg',
                              color: customTheme.accentColor,
                              height: 50,
                              width: 50,
                            ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 13,
            child: SizedBox(),
          )
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: duration,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(isDark
                        ? 'assets/images/bg-dark.jpg'
                        : 'assets/images/bg-light.jpg'))),
          ),
          Opacity(
            opacity: 0.65,
            child: FlareActor(
                isDark
                    ? "assets/flare/sweep_dark.flr"
                    : "assets/flare/sweep_light.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "rotate"),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 28,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 15,
                        child: SizedBox(),
                      ),
                      Expanded(
                        flex: 70,
                        child: _leftView(),
                      ),
                      Expanded(
                        flex: 15,
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 72,
                child: Container(
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.centerRight,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _smallHand(),
                                _largeHand(),
                                _clockDot(),
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Expanded(
                            flex: 15,
                            child: SizedBox(),
                          ),
                          Expanded(
                            flex: 70,
                            child: _rightView(),
                          ),
                          Expanded(
                            flex: 15,
                            child: SizedBox(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getRoundedTemperatureWithoutUnit(String temp) =>
      double.parse(temp.split('°').first).toStringAsFixed(0) + '°';

  String get weatherAsset {
    switch (_condition) {
      case WeatherCondition.cloudy:
        return 'assets/icons/weather-icon-cloudy.svg';
        break;
      case WeatherCondition.foggy:
        return 'assets/icons/weather-icon-foggy.svg';
        break;
      case WeatherCondition.rainy:
        return 'assets/icons/weather-icon-rainy.svg';
        break;
      case WeatherCondition.snowy:
        return 'assets/icons/weather-icon-snowy.svg';
        break;
      case WeatherCondition.sunny:
        return 'assets/icons/weather-icon-sunny.svg';
        break;
      case WeatherCondition.thunderstorm:
        return 'assets/icons/weather-icon-thunderstorm.svg';
        break;
      case WeatherCondition.windy:
        return 'assets/icons/weather-icon-windy.svg';
        break;
      default:
        return 'assets/icons/weather-icon-sunny.svg';
        break;
    }
  }
}

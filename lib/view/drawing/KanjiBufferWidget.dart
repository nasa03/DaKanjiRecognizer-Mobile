import 'dart:math';

import 'package:da_kanji_mobile/provider/Lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/model/helper/HandlePredictions.dart';
import 'package:get_it/get_it.dart';



/// A draggable `OutlinedButton` that moves back to `Alignment.center` when it's
/// released.
class KanjiBufferWidget extends StatefulWidget {
  final double canvasSize;

  KanjiBufferWidget(this.canvasSize);

  @override
  _KanjiBufferWidgetState createState() => _KanjiBufferWidgetState();
}

class _KanjiBufferWidgetState extends State<KanjiBufferWidget>
    with TickerProviderStateMixin {

  AnimationController _springController;

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_springAnimation].
  Alignment _dragAlignment = Alignment.center;
  bool deletedWithSwipe = false;

  // animation to make the kanjibuffer "jump back" when released
  Animation<Alignment> _springAnimation;
  
  // animation and controller for the delete-chars-rotation of the kanji buffer
  int _rotationXDuration = 250;
  AnimationController _rotationXController;
  Animation<double> _rotationXAnimation;

  // animation when character added to kanjibuffer
  int _scaleInNewCharDuration = 250; 
  AnimationController _scaleInNewCharController;
  Animation<double> _scaleInNewCharAnimation;

  /// size of the kanji buffer
  double width;
  /// how many characters do fit in this box
  int charactersFit = 0;
  /// callback when the kanjibuffer changed
  Function kanjiBufferChanged;

  

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _springAnimation = _springController.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 60,
      stiffness: 0.01,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _springController.animateWith(simulation);
  }

  @override
  void initState() {
    
    super.initState();
    
    // controller / animation of swipe left gesture
    _springController = AnimationController(vsync: this);
    _springController.addListener(() {
      setState(() {
        _dragAlignment = _springAnimation.value;
      });
    });

    // initialize the animation / controller of the delete characters animation
    _rotationXController = AnimationController(
      duration: Duration(milliseconds: _rotationXDuration),
      vsync: this,
    );
    _rotationXAnimation = CurvedAnimation(
      parent: _rotationXController,
      curve: Curves.linear
    );
    
    // controller / animation of the character added animation
    _scaleInNewCharController = AnimationController(
      duration: Duration(milliseconds: _scaleInNewCharDuration),
      vsync: this,
    );
    _scaleInNewCharAnimation = new Tween(
      begin: 0.1,
      end: 1.0,
    ).animate(new CurvedAnimation(
      parent: _scaleInNewCharController,
      curve: Curves.easeOut,
    ));
    // make sure all characters are show even if page changed
    _scaleInNewCharController.value = 1.0;
  }

  @override
  void dispose() {
    _springController.dispose();
    _rotationXController.dispose();
    _scaleInNewCharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if(GetIt.I<KanjiBuffer>().runAnimation){
      _scaleInNewCharController.forward(from: 0.0);
      GetIt.I<KanjiBuffer>().runAnimation = false;
    }

    charactersFit = calculateCharactersFit();

    return GestureDetector(
      onPanDown: (details) {
        _springController.stop();
      },
      // animate dragging the widget
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            max(min(details.delta.dx / (size.height / 2), 0), -0.05),
            0
          );
          // delete the last char if drag over the threshold
          if(_dragAlignment.x < -0.03 && !deletedWithSwipe &&
            GetIt.I<KanjiBuffer>().kanjiBuffer.length > 0){

            // if the delete animation is already running delete the character
            // of the old animation
            if(_scaleInNewCharController.status == AnimationStatus.reverse)
              GetIt.I<KanjiBuffer>().removeLastChar();

            // run the animation in reverse and at the end delete the char
            _scaleInNewCharController.reverse();
            Future.delayed(
              Duration(milliseconds: (_scaleInNewCharDuration).round()),
              () { 
                _scaleInNewCharController.stop();
                _scaleInNewCharController.value = 1.0;
                GetIt.I<KanjiBuffer>().removeLastChar();
              }
             );
            deletedWithSwipe = true;
          }
        });
      },
      // run the animation to move the widget back to the center
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond, size);
        deletedWithSwipe = false;
      },
      // empty on double press
      onDoubleTap: () {
        // start the delete animation if there are characters in the buffer
        if(GetIt.I<KanjiBuffer>().kanjiBuffer.length > 0){
          _rotationXController.forward(from: 0.0);

          //delete the characters after the animation
          Future.delayed(Duration(milliseconds: (_rotationXDuration/4).round()), (){
            setState(() {
               GetIt.I<KanjiBuffer>().clearKanjiBuffer();           
            });
          });
        }
      },
      child: Align(
        alignment: _dragAlignment,
        child: AnimatedBuilder(
            animation:  _rotationXAnimation,
            child: Container(
            // make the multi character bar the same size as 3 prediction-buttons
            width: widget.canvasSize,
            child: OutlinedButton(
              // copy to clipboard and show snackbar
              onPressed: (){
                GetIt.I<Lookup>().setChar(
                  GetIt.I<KanjiBuffer>().kanjiBuffer, buffer: true
                );
                HandlePrediction().handlePress(context); 
              },
              // open with dictionary on long press
              onLongPress: (){
                GetIt.I<Lookup>().setChar(
                  GetIt.I<KanjiBuffer>().kanjiBuffer,
                  buffer: true, longPress: true
                );
                HandlePrediction().handlePress(context); 
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    () { 
                      int length = GetIt.I<KanjiBuffer>().kanjiBuffer.length;
                      
                      // more than one character is in the kanjibuffer
                      if(length > 1){
                        // more character in the buffer than can be shown
                        if(GetIt.I<KanjiBuffer>().kanjiBuffer.length > charactersFit)
                          return "…" +  GetIt.I<KanjiBuffer>().kanjiBuffer
                            .substring(length-charactersFit, length-1);
                        // whole buffer can be shown
                        else{
                          return GetIt.I<KanjiBuffer>()
                            .kanjiBuffer.substring(0, length-1);
                        }
                      }
                      else
                        return "";
                    } (),
                    textScaleFactor: 1.5,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: "NotoSans"
                    ),
                  ),
                  ScaleTransition(
                    scale: _scaleInNewCharAnimation,
                    child: Text(
                      () {
                        int length = GetIt.I<KanjiBuffer>().kanjiBuffer.length;
                        if(length > 0)
                          return GetIt.I<KanjiBuffer>().kanjiBuffer[length - 1];
                        else
                          return "";
                      } (),
                      textScaleFactor: 1.5,
                      style: TextStyle(
                        fontFamily: "NotoSans"
                      ),
                    )
                  )
                ]
              )
            ),
          ),
          // builder for spinning (delete) animation
          builder: (BuildContext context, Widget child){
            return Transform(
              transform: () { 
                Matrix4 transform = Matrix4.identity();
                transform *=
                  Matrix4.rotationX(_rotationXAnimation.value * 2 * pi);
                return transform;
              } (),
              alignment: Alignment.center,
              child: child,
            );
          },
        )
      ),
    );
  }

  /// Calculates and returns how many characters fit in this KanjiBufferWidget
  int calculateCharactersFit(){
    int _charactersFit = -3;
    String chars = "口口";
    double w = 1;
    while(widget.canvasSize > w){
      w = (TextPainter(
        text: TextSpan(text: chars),
        maxLines: 1,
        textScaleFactor: 1.5,
        textDirection: TextDirection.ltr)
      ..layout()).size.width;

      chars += "口";
      _charactersFit += 1;
    }

    return _charactersFit;
  }
}

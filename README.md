# Description

Tap debounce simplifying widget. Wrap your button widget in TapDebounce widget and any taps will be 
disabled while tap callback is in progress.

## Instruction

Assume your code with some button look like this:

```dart
//...
child: RaisedButton(
  color: Colors.blue,
  disabledColor: Colors.grey,
  onPressed: () async => await someLongOperation(), // your tap handler
  child: const Text('Short'),
  );
//...
```

and you do not want user to be able to press the button again several times and start other 
someLongOperation functions. Example is a Navigator pop function - it can take a few hundred of 
millis to navigate and user can press the button several times, and that will lead to undesired pop 
several screens back instead of one.

Wrap this code to Debouncer and move RaisedButton onPressed contents to Debouncer onTap:

```dart
//...
child: TapDebouncer(
  onTap: () async => await someLongOperation(), // your tap handler moved here
  builder: (BuildContext context, TapDebouncerFunc onTap) {
    return RaisedButton(
      color: Colors.blue,
      disabledColor: Colors.grey,
      onPressed: onTap,  // It is just onTap from builder callback
      child: const Text('Short'),
    );
  },
),
//...
```

Debouncer will disable the RaisedButton by setting onPressed to null while onTap is being executed. 

You can add optional delay to be sure that the button is disabled some time after someOperation is 
called.


```dart
//...
onTap: () async {
    await someOperation();
    
    await Future<void>.delayed(const Duration(milliseconds: 1000));
},
//...
```

You can fill optional cooldown field with some Duration and avoid adding of Future.delayed at 
the end of onTap callback, this will be done automatically:

```dart
//...
child: TapDebouncer(
  cooldown: const Duration(milliseconds: 1000),
  onTap: () async => await someLongOperation(), // your tap handler moved here
  builder: (BuildContext context, TapDebouncerFunc onTap) {
    return RaisedButton(
      color: Colors.blue,
      disabledColor: Colors.grey,
      onPressed: onTap,  // It is just onTap from builder callback
      child: const Text('Short'),
    );
  },
),
//...
```

Then your onTap could be changed to this:

```dart
//...
onTap: () async => await someOperation(),
//...
```

If someOperation will raise exception cooldown delay will also work, after exception.

See example application for details:

![Example of button disabled after tap](https://github.com/sla-000/flutter_debouncer/blob/master/page/debounced.gif)

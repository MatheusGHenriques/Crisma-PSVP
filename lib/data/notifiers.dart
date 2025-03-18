import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> chatHasSelectedTagNotifier = ValueNotifier(false);
ValueNotifier<bool> isChatBoxInitializedNotifier = ValueNotifier(false);
ValueNotifier<bool> hasConnectedPeerNotifier = ValueNotifier(false);
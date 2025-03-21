import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> hasSelectedTagNotifier = ValueNotifier(false);
ValueNotifier<bool> isChatBoxInitializedNotifier = ValueNotifier(false);
ValueNotifier<int> connectedPeersNotifier = ValueNotifier(0);
ValueNotifier<int> unreadMessagesNotifier = ValueNotifier(0);
ValueNotifier<int> newTasksNotifier = ValueNotifier(0);
ValueNotifier<bool> updatedScheduleNotifier = ValueNotifier(false);
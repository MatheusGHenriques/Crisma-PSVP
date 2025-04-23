import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<int> selectedTagsNotifier = ValueNotifier(0);
ValueNotifier<bool> isChatBoxInitializedNotifier = ValueNotifier(false);
ValueNotifier<int> connectedPeersNotifier = ValueNotifier(0);
ValueNotifier<int> unreadMessagesNotifier = ValueNotifier(0);
ValueNotifier<int> newTasksNotifier = ValueNotifier(0);
ValueNotifier<bool> updatedScheduleNotifier = ValueNotifier(false);
ValueNotifier<int> newCiphersNotifier = ValueNotifier(0);
ValueNotifier<int> newPollsNotifier = ValueNotifier(0);

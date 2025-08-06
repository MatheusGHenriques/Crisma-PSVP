import 'network_manager.dart';
import '/main.dart';
import '/data/poll.dart';
import '/data/notifiers.dart';
import '/data/user_info.dart';
import '/views/pages/chat_page.dart';
import '/views/pages/tasks_page.dart';
import '/data/message.dart';
import '/data/pdf.dart';
import '/data/task.dart';

extension DataSyncHandler on PeerToPeerNetworking {
  void addMessageToChatBox(Message message) async {
    if (chatBoxMessages.add(message)) {
      for (Message boxMessage in chatBox.values) {
        if (message.compare(boxMessage) && (message.readBy.length > boxMessage.readBy.length || message.tags.isEmpty)) {
          if (!message.readBy.contains(userName)) unreadMessagesNotifier.value--;
          boxMessage.delete();
          break;
        }
      }
      if (ChatPage.userHasMessageTags(message) && message.sender != userName && !message.readBy.contains(userName)) {
        unreadMessagesNotifier.value++;
        notifications.newNotification(message);
      }
      await chatBox.add(message);
      await message.save();
      sendMessage(message);
    }
  }

  void addTaskToTaskBox(Task task) async {
    if (taskBoxTasks.add(task)) {
      for (var boxTask in taskBox.values.whereType<Task>()) {
        if (!task.compare(boxTask)) continue;
        if (shouldReplaceTask(task, boxTask)) {
          await boxTask.delete();
          break;
        }
        return;
      }
      await taskBox.add(task);
      await task.save();
      if (TasksPage.userHasTaskTags(task) && task.numberOfPersons > 0 && task.sender != userName) {
        newTasksNotifier.value++;
        notifications.newNotification(task);
      }
      sendTask(task);
    }
  }

  bool shouldReplaceTask(Task newTask, Task existingTask) {
    return newTask.numberOfPersons < existingTask.numberOfPersons ||
        (newTask.persons.isNotEmpty && existingTask.persons.isNotEmpty && newTask.persons != existingTask.persons);
  }

  void addPollToTaskBox(Poll poll) async {
    if (taskBoxPolls.add(poll)) {
      for (var boxPoll in taskBox.values.whereType<Poll>()) {
        if (!poll.compare(boxPoll)) continue;
        if (shouldReplacePoll(poll, boxPoll)) {
          await boxPoll.delete();
          break;
        }
        return;
      }
      await taskBox.add(poll);
      await poll.save();
      sendPoll(poll);
      if (TasksPage.userHasPollTags(poll) &&
          poll.sender != userName &&
          !poll.votes.values.any((voters) => voters.contains(userName))) {
        newPollsNotifier.value++;
        notifications.newNotification(poll);
      }
    }
  }

  bool shouldReplacePoll(Poll newPoll, Poll existingPoll) {
    if (newPoll.votes.keys.length > existingPoll.votes.keys.length || noTagsInPoll(newPoll)) return true;
    if (newPoll.votes.keys.length == existingPoll.votes.keys.length) return hasMoreVotes(newPoll, existingPoll);
    return false;
  }

  bool noTagsInPoll(Poll poll) {
    for (bool tag in poll.tags.values) {
      if (tag) return false;
    }
    return true;
  }

  bool hasMoreVotes(Poll newPoll, Poll existingPoll) {
    int newPollVotes = newPoll.votes.values.fold(0, (sum, list) => sum + list.length);
    int existingPollVotes = existingPoll.votes.values.fold(0, (sum, list) => sum + list.length);
    return newPollVotes > existingPollVotes;
  }

  void addPdfToPdfBox(Pdf pdf) async {
    if (pdfBoxPdfs.add(pdf)) {
      if (pdf.type == 'Cronograma') {
        if (pdfBox.isEmpty || await pdfBox.get("pdf").time.isBefore(pdf.time)) {
          await pdfBox.put("pdf", pdf);
          updatedScheduleNotifier.value = true;
          sendPdf(pdf);
        }
      } else {
        await pdfBox.add(pdf);
        sendPdf(pdf);
        if (userTags['Música']!) {
          newCiphersNotifier.value++;
          notifications.newNotification(pdf);
        }
      }
    }
  }
}

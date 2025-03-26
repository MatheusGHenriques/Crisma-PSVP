import '/data/message.dart';
import '/data/pdf.dart';
import '/data/task.dart';
import 'package:hive_ce/hive.dart';

import '../data/poll.dart';

@GenerateAdapters([AdapterSpec<Message>(), AdapterSpec<Task>(), AdapterSpec<Poll>(),AdapterSpec<Pdf>()])
part 'hive_adapters.g.dart';

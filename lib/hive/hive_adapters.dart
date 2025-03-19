import 'package:crisma/data/message.dart';
import 'package:crisma/data/task.dart';
import 'package:hive_ce/hive.dart';

@GenerateAdapters([AdapterSpec<Message>(), AdapterSpec<Task>()])
part 'hive_adapters.g.dart';
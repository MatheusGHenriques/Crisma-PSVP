import 'package:crisma/data/message.dart';
import 'package:hive_ce/hive.dart';

@GenerateAdapters([AdapterSpec<Message>()])
part 'hive_adapters.g.dart';
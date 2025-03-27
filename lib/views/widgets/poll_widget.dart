import 'package:flutter/material.dart';
import '/data/user_info.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/main.dart';
import '/data/poll.dart';

class PollWidget extends StatefulWidget {
  final Poll poll;
  final Function(Poll) onSendPoll;

  const PollWidget({super.key, required this.poll, required this.onSendPoll});

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  String? _selectedOption;
  final TextEditingController _newVoteController = TextEditingController();
  bool _hasNewVote = false;

  @override
  void initState() {
    _newVoteController.addListener(() {
      if (_newVoteController.text.isNotEmpty) {
        setState(() {
          _hasNewVote = true;
        });
      }
    });
    super.initState();
  }

  String _getTags() {
    String tags = "";
    for (String tag in widget.poll.tags.keys) {
      if (widget.poll.tags[tag]!) {
        tags += "@$tag ";
      }
    }
    return tags;
  }

  void _sendPoll() async {
    if(_selectedOption != null) {
      widget.poll.votes.forEach((key, votesList) {
        votesList.remove(userName);
      });
      widget.poll.votes[_selectedOption]!.add(userName);
    }
    setState(() {
      widget.onSendPoll(widget.poll);
    });
    await widget.poll.save();
  }

  void _deletePoll() {
    for (String key in widget.poll.tags.keys) {
      widget.poll.tags[key] = false;
    }
    _sendPoll();
  }

  String _getVotesNumbers(String text) {
    List<String> list = widget.poll.votes[text] ?? [];
    return ' (${list.length})';
  }

  List<Widget> _generateVotes() {
    for(String key in widget.poll.votes.keys){
      if(widget.poll.votes[key]!.contains(userName)){
        _selectedOption = key;
      }
    }

    List<Widget> result = [];
    for (String text in widget.poll.votes.keys) {
      result.add(
        RadioListTile(
          title: Text(text + _getVotesNumbers(text)),
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
          value: text,
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value;
              _sendPoll();
            });
          },
        ),
      );
    }
    if (widget.poll.openResponse) {
      result.add(
        RadioListTile(
          title: TextField(
            maxLength: 20,
            controller: _newVoteController,
            decoration: InputDecoration(counterText: "", hintText: "Outra opção"),
          ),
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
          value: _newVoteController.text,
          groupValue: _selectedOption,
          onChanged:
              _hasNewVote && _newVoteController.text != ""
                  ? (value) {
                    widget.poll.votes[_newVoteController.text] = [];
                      _newVoteController.clear();
                    setState(() {
                      _selectedOption = value as String?;
                      _sendPoll();
                    });
                  }
                  : null,
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color:
                widget.poll.sender == userName
                    ? CustomThemes.secondaryLightColor(colorTheme)
                    : isDarkMode
                    ? CustomThemes.darkBackgroundColor(colorTheme)
                    : CustomThemes.lightBackgroundColor(colorTheme),
          ),
          child: Row(
            spacing: 20,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    widget.poll.sender != userName
                        ? Text(
                          widget.poll.sender,
                          style: TextStyle(
                            color: CustomThemes.mainColor(colorTheme),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                        : const SizedBox(),
                    Text(
                      _getTags(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CustomThemes.secondaryDarkColor(colorTheme),
                      ),
                    ),
                    Text(
                      widget.poll.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView(shrinkWrap: true, children: _generateVotes()),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: widget.poll.sender == userName
                    ? IconButton(
                      onPressed: () {
                        _deletePoll();
                      },
                      icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white : Colors.black),
                    )
                    : SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }
}

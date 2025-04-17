part of 'user_stories_bloc.dart';

// The UserStoriesState likely represents data that needs to be saved, fetched, 
// or transmitted over a network.

// For example, if the user's stories are stored in a database or sent to an API, 
// the state must be serialized into JSON (using toJson) or deserialized from 
// JSON (using fromJson).

// hence we use fromJson --- toJson methods

@immutable
@JsonSerializable()
class UserStoriesState extends Equatable {
  const UserStoriesState({
    required this.author,
    required this.stories,
    required this.showStories,
  });

  factory UserStoriesState.fromJson(Map<String, dynamic> json) =>
      _$UserStoriesStateFromJson(json);

  const UserStoriesState.initial()
      : this(
          author: User.anonymous,
          stories: const [],
          showStories: false,
        );

  final User author;
  final List<Story> stories;
  final bool showStories;

  Map<String, dynamic> toJson() => _$UserStoriesStateToJson(this);

  @override
  List<Object?> get props => [author, stories, showStories];

  UserStoriesState copyWith({
    User? author,
    List<Story>? stories,
    bool? showStories,
  }) {
    return UserStoriesState(
      author: author ?? this.author,
      stories: stories ?? this.stories,
      showStories: showStories ?? this.showStories,
    );
  }
}

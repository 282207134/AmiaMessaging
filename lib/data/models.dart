class Person {
  const Person(this.id, this.name, this.image, this.preview, this.time);
  final String id, name, image, preview, time;
}

const people = [
  Person(
    'mattie',
    'Mattie Blooman',
    'mattie',
    'Sed ut et aperta iudicari etenim…',
    '12m',
  ),
  Person('wim', 'Wim Willems', 'wim', 'In quo aut rerum hic tenetur', '1 day'),
  Person(
    'amolika',
    'Amolika Shaikh',
    'amolika',
    'Torquem detraxit hosti et quidem',
    '3w',
  ),
  Person(
    'adhra',
    'Adhraaa Al Azimi',
    'story_1',
    'Torquatos nostros? quos tu paulo',
    '4w',
  ),
  Person('helena', 'Helena Brauer', 'helena', 'Et quidem faciunt, ut de', '2m'),
  Person('yi', 'Yi Hanying', 'yi', 'At vero eos et inter mediocrem', '4m'),
  Person('conan', 'Conan Matusov', 'conan', 'Been to 123 places', '10:45 AM'),
];

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    this.mine = true,
    this.kind = 'text',
    this.starred = false,
  });
  final String id, kind;
  String text;
  final bool mine;
  bool starred;
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'mine': mine,
    'kind': kind,
    'starred': starred,
  };
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    text: json['text'] as String,
    mine: json['mine'] as bool,
    kind: json['kind'] as String,
    starred: json['starred'] as bool? ?? false,
  );
}

List<ChatMessage> initialMessages() => [
  ChatMessage(
    id: 'intro',
    text: 'Lorem Ipsum is\nLorem Ipsum is simply dummy text of',
    mine: false,
  ),
  ChatMessage(
    id: 'reply',
    text: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry',
  ),
  ChatMessage(id: 'payment', text: '30', kind: 'payment'),
];

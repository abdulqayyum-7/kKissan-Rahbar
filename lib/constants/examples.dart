class Example {
  const Example(this.question, this.hint);
  final String question;
  final String hint;
}

const List<Example> kExamples = [
  Example('When should I plant wheat in my district?', 'Share your district, sowing window and irrigation access'),
  Example('How can I manage cotton pests?', 'Identify the pest and crop stage for safer local advice'),
  Example('Which crops need less water in my area?', 'Compare options using your district, soil and season'),
  Example('How should I irrigate my rice field?', 'Get practical guidance for your crop stage and water supply'),
];

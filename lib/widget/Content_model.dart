class UnboardingContent {
  String image;
  String title;
  String description;
  UnboardingContent(
      {required this.description, required this.image, required this.title});
}

List<UnboardingContent> contents = [
  UnboardingContent(
    description:
        'Pick your food from our menu\n                   more than 35 times',
    image: "assets/screen1.png",
    title: "Select from\n  Our Best Menu",
  ),
  UnboardingContent(
    description:
        'You can pay cash on delivery and\n                   card payement is avalable',
    image: "assets/screen2.png",
    title: "Easy and Online Payment",
  ),
  UnboardingContent(
      description: "Deliver your food at your Doorstep",
      image: "assets/screen3.png",
      title: 'Quick Delivery at Your Doors')
];

class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String occupation;
  final String bio;
  final List<String> photos;
  final int compatibilityScore; // e.g. 98%
  final String distance; // e.g. "3 miles away"
  final bool isVerified;
  final List<String> interests;
  final String location;
  final String? audioPromptTitle;
  final String? audioPromptDuration;
  final String? promptQuestion;
  final String? promptAnswer;
  final String height;
  final String zodiac;
  final String relationshipGoal;

  ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.occupation,
    required this.bio,
    required this.photos,
    required this.compatibilityScore,
    required this.distance,
    this.isVerified = true,
    required this.interests,
    required this.location,
    this.audioPromptTitle,
    this.audioPromptDuration,
    this.promptQuestion,
    this.promptAnswer,
    this.height = "5'7\"",
    this.zodiac = "Leo ♌",
    this.relationshipGoal = "Long-term connection",
  });
}

final List<ProfileModel> mockProfiles = [
  ProfileModel(
    id: 'p1',
    name: 'Elena Rostova',
    age: 25,
    occupation: 'UX Design Lead @ TechStudio',
    bio: 'Art gallery explorer & specialty coffee fanatic ☕. Looking for someone to share late-night rooftop vinyl sessions and Sunday morning market runs.',
    photos: [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1000&q=80',
    ],
    compatibilityScore: 98,
    distance: '2 miles away',
    isVerified: true,
    interests: ['Design', 'Vinyl Records', 'Specialty Coffee', 'Art Openings', 'Surfing'],
    location: 'San Francisco, CA',
    audioPromptTitle: 'My ideal Sunday morning...',
    audioPromptDuration: '0:18',
    promptQuestion: 'The key to my heart is...',
    promptAnswer: 'Freshly roasted espresso and spontaneous road trips up the coastline.',
    height: "5'8\"",
    zodiac: "Libra ♎",
    relationshipGoal: "Long-term relationship",
  ),
  ProfileModel(
    id: 'p2',
    name: 'Sophia Chen',
    age: 26,
    occupation: 'Architect & Urban Planner',
    bio: 'Capturing cities through film photography 🎞️. Always down for architectural walking tours, natural wine bars, and deep midnight debates.',
    photos: [
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1000&q=80',
    ],
    compatibilityScore: 94,
    distance: '4 miles away',
    isVerified: true,
    interests: ['Architecture', 'Analog Photography', 'Natural Wine', 'Bouldering', 'Indie Rock'],
    location: 'Berkeley, CA',
    audioPromptTitle: 'A random fact I love...',
    audioPromptDuration: '0:24',
    promptQuestion: 'We’ll get along if...',
    promptAnswer: 'You appreciate brutalist design and know where to find the best ramen.',
    height: "5'6\"",
    zodiac: "Gemini ♊",
    relationshipGoal: "Datable partner",
  ),
  ProfileModel(
    id: 'p3',
    name: 'Chloe Moreau',
    age: 24,
    occupation: 'Fashion Designer & Creative Strategist',
    bio: 'Parisian vibes in California 🥐🎨. Building eco-conscious street style couture. Let’s hunt for vintage treasures and hidden jazz clubs.',
    photos: [
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=1000&q=80',
    ],
    compatibilityScore: 91,
    distance: '5 miles away',
    isVerified: true,
    interests: ['Fashion Design', 'Vintage Vinyl', 'Jazz', 'Modern Art', 'Sourdough'],
    location: 'Oakland, CA',
    audioPromptTitle: 'My non-negotiable...',
    audioPromptDuration: '0:15',
    promptQuestion: 'I’m overly passionate about...',
    promptAnswer: 'Sustainable fashion ethics and finding the crispest natural wine.',
    height: "5'7\"",
    zodiac: "Taurus ♉",
    relationshipGoal: "Open to romance",
  ),
  ProfileModel(
    id: 'p4',
    name: 'Maya Lin',
    age: 27,
    occupation: 'Sound Producer & DJ',
    bio: 'Crafting ambient electronic beats by night 🎧. Ocean swimmer, plant parent of 34 greenery pots, and lover of warm sunsets.',
    photos: [
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1000&q=80',
    ],
    compatibilityScore: 89,
    distance: '3 miles away',
    isVerified: true,
    interests: ['Sound Design', 'Plant Care', 'Ocean Swimming', 'Synthesizers', 'Tacos'],
    location: 'San Francisco, CA',
    audioPromptTitle: 'Listen to this beat snippet!',
    audioPromptDuration: '0:30',
    promptQuestion: 'My simple pleasures...',
    promptAnswer: 'Golden hour sunlight streaming through my studio window while writing synth pads.',
    height: "5'5\"",
    zodiac: "Pisces ♓",
    relationshipGoal: "Long-term partner",
  ),
];

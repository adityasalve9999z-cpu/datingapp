class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String occupation;
  final String bio;
  final List<String> photos;
  final int compatibilityScore;
  final String distance;
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

  // ── New flexible fields ──────────────────────────────────────
  final String education;        // e.g. "Stanford University"
  final String degree;           // e.g. "B.Sc. Computer Science"
  final List<String> languages;  // e.g. ["English", "French"]
  final String mbti;             // e.g. "INFJ"
  final String drinking;         // "Never" | "Socially" | "Often"
  final String smoking;          // "Never" | "Occasionally" | "Yes"
  final String exercise;         // "Rarely" | "Sometimes" | "Often" | "Daily"
  final String pets;             // "Dog lover" | "Cat person" | "No pets" | "Has pets"
  final int mutualFriends;       // count of mutual connections
  final List<String> lookingFor; // e.g. ["Deep conversations", "Weekend adventures"]
  final String? instagramHandle; // optional, e.g. "@elena.designs"
  final int profileCompletion;   // 0–100 percentage

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
    // New fields with sensible defaults
    this.education = "University Graduate",
    this.degree = "Bachelor's Degree",
    this.languages = const ["English"],
    this.mbti = "INFP",
    this.drinking = "Socially",
    this.smoking = "Never",
    this.exercise = "Sometimes",
    this.pets = "No pets",
    this.mutualFriends = 0,
    this.lookingFor = const ["Genuine connection"],
    this.instagramHandle,
    this.profileCompletion = 85,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString() ??
        json['firstName']?.toString() ??
        json['name']?.toString() ??
        'User';
    final lastName = json['last_name']?.toString() ?? json['lastName']?.toString() ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();
    final photos = <String>[];
    
    // Check 'photos' array (Supabase text[] column)
    if (json['photos'] is List) {
      for (final item in json['photos'] as List) {
        final url = item?.toString();
        if (url != null && url.isNotEmpty) {
          photos.add(url);
        }
      }
    }
    
    // Check 'images' or 'image' fallback
    if (photos.isEmpty) {
      final image = json['image']?.toString();
      if (image != null && image.isNotEmpty) {
        photos.add(image);
      }
      if (json['images'] is List) {
        for (final item in json['images'] as List) {
          final url = item?.toString();
          if (url != null && url.isNotEmpty) {
            photos.add(url);
          }
        }
      }
    }
    
    if (photos.isEmpty) {
      photos.add('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1000&q=80');
    }

    final occupation = json['occupation']?.toString() ??
        (json['company'] is Map<String, dynamic>
            ? (json['company'] as Map<String, dynamic>)['name']?.toString()
            : null) ??
        'Creative Professional';

    return ProfileModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? fullName.replaceAll(' ', '-').toLowerCase(),
      name: fullName.isNotEmpty ? fullName : 'Demo User',
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? '25') ?? 25,
      occupation: occupation,
      bio: json['bio']?.toString() ?? 'Looking for a meaningful connection and good conversation.',
      photos: photos,
      compatibilityScore: int.tryParse(json['compatibility_score']?.toString() ?? json['compatibilityScore']?.toString() ?? '') ?? 90,
      distance: json['distance']?.toString() ?? 'Nearby',
      isVerified: json['is_verified'] is bool
          ? json['is_verified'] as bool
          : (json['isVerified'] is bool ? json['isVerified'] as bool : true),
      interests: (json['interests'] is List)
          ? (json['interests'] as List).map((e) => e.toString()).toList()
          : ['Design', 'Coffee', 'Travel'],
      location: json['location']?.toString() ?? 'San Francisco, CA',
      audioPromptTitle: json['audio_prompt_title']?.toString() ?? json['audioPromptTitle']?.toString(),
      audioPromptDuration: json['audio_prompt_duration']?.toString() ?? json['audioPromptDuration']?.toString(),
      promptQuestion: json['prompt_question']?.toString() ?? json['promptQuestion']?.toString(),
      promptAnswer: json['prompt_answer']?.toString() ?? json['promptAnswer']?.toString(),
      height: json['height']?.toString() ?? "5'7\"",
      zodiac: json['zodiac']?.toString() ?? 'Leo ♌',
      relationshipGoal: json['relationship_goal']?.toString() ?? json['relationshipGoal']?.toString() ?? 'Long-term connection',
      education: json['education']?.toString() ?? 'University Graduate',
      degree: json['degree']?.toString() ?? "Bachelor's Degree",
      languages: (json['languages'] is List)
          ? (json['languages'] as List).map((e) => e.toString()).toList()
          : const ['English'],
      mbti: json['mbti']?.toString() ?? 'INFP',
      drinking: json['drinking']?.toString() ?? 'Socially',
      smoking: json['smoking']?.toString() ?? 'Never',
      exercise: json['exercise']?.toString() ?? 'Sometimes',
      pets: json['pets']?.toString() ?? 'No pets',
      mutualFriends: int.tryParse(json['mutual_friends']?.toString() ?? json['mutualFriends']?.toString() ?? '') ?? 0,
      lookingFor: (json['looking_for'] is List)
          ? (json['looking_for'] as List).map((e) => e.toString()).toList()
          : ((json['lookingFor'] is List)
              ? (json['lookingFor'] as List).map((e) => e.toString()).toList()
              : const ['Genuine connection']),
      instagramHandle: json['instagram_handle']?.toString() ?? json['instagramHandle']?.toString(),
      profileCompletion: int.tryParse(json['profile_completion']?.toString() ?? json['profileCompletion']?.toString() ?? '') ?? 85,
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    final parts = name.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : name;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return {
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'bio': bio,
      'occupation': occupation,
      'location': location,
      'distance': distance,
      'height': height,
      'zodiac': zodiac,
      'relationship_goal': relationshipGoal,
      'education': education,
      'degree': degree,
      'mbti': mbti,
      'drinking': drinking,
      'smoking': smoking,
      'exercise': exercise,
      'pets': pets,
      'mutual_friends': mutualFriends,
      'instagram_handle': instagramHandle,
      'profile_completion': profileCompletion,
      'is_verified': isVerified,
      'photos': photos,
      'interests': interests,
      'languages': languages,
      'looking_for': lookingFor,
      'audio_prompt_title': audioPromptTitle,
      'audio_prompt_duration': audioPromptDuration,
      'prompt_question': promptQuestion,
      'prompt_answer': promptAnswer,
      'compatibility_score': compatibilityScore,
    };
  }
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
    education: "Stanford University",
    degree: "B.A. Human-Computer Interaction",
    languages: ["English", "Russian", "French"],
    mbti: "ENFJ",
    drinking: "Socially",
    smoking: "Never",
    exercise: "Often",
    pets: "Dog lover 🐶",
    mutualFriends: 7,
    lookingFor: ["Deep conversations", "Weekend adventures", "Someone creative"],
    instagramHandle: "@elena.designs",
    profileCompletion: 97,
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
    promptQuestion: 'We\'ll get along if...',
    promptAnswer: 'You appreciate brutalist design and know where to find the best ramen.',
    height: "5'6\"",
    zodiac: "Gemini ♊",
    relationshipGoal: "Datable partner",
    education: "UC Berkeley",
    degree: "M.Arch Architecture",
    languages: ["English", "Mandarin"],
    mbti: "INTJ",
    drinking: "Socially",
    smoking: "Never",
    exercise: "Daily",
    pets: "Cat person 🐱",
    mutualFriends: 3,
    lookingFor: ["Intellectual spark", "Art & culture dates", "Long walks"],
    instagramHandle: "@sophiachen.arch",
    profileCompletion: 92,
  ),
  ProfileModel(
    id: 'p3',
    name: 'Chloe Moreau',
    age: 24,
    occupation: 'Fashion Designer & Creative Strategist',
    bio: 'Parisian vibes in California 🥐🎨. Building eco-conscious street style couture. Let\'s hunt for vintage treasures and hidden jazz clubs.',
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
    promptQuestion: 'I\'m overly passionate about...',
    promptAnswer: 'Sustainable fashion ethics and finding the crispest natural wine.',
    height: "5'7\"",
    zodiac: "Taurus ♉",
    relationshipGoal: "Open to romance",
    education: "Parsons School of Design",
    degree: "B.F.A. Fashion Design",
    languages: ["English", "French"],
    mbti: "ISFP",
    drinking: "Occasionally",
    smoking: "Never",
    exercise: "Sometimes",
    pets: "Has pets 🐇",
    mutualFriends: 12,
    lookingFor: ["Creative soul", "Jazz nights out", "Slow Sunday mornings"],
    instagramHandle: "@chloe.couture",
    profileCompletion: 88,
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
    education: "Berklee College of Music",
    degree: "B.Mus. Electronic Production",
    languages: ["English", "Japanese"],
    mbti: "INFP",
    drinking: "Rarely",
    smoking: "Never",
    exercise: "Often",
    pets: "Plant parent 🌿",
    mutualFriends: 5,
    lookingFor: ["Late-night creativity", "Beach sunsets", "Plant enthusiast"],
    instagramHandle: "@maya.sounds",
    profileCompletion: 95,
  ),
  ProfileModel(
    id: 'p5',
    name: 'Aisha Patel',
    age: 28,
    occupation: 'Neuroscience Researcher @ UCSF',
    bio: 'Brain science by day, sourdough baker by weekend 🧠🍞. Passionate about mindfulness, trail running, and honest conversations over chai.',
    photos: [
      'https://images.unsplash.com/photo-1488716820095-cbe80883c496?auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1484863137850-59afcfe05386?auto=format&fit=crop&w=1000&q=80',
    ],
    compatibilityScore: 86,
    distance: '6 miles away',
    isVerified: true,
    interests: ['Neuroscience', 'Baking', 'Trail Running', 'Mindfulness', 'Chai'],
    location: 'San Francisco, CA',
    audioPromptTitle: 'The thing about the brain...',
    audioPromptDuration: '0:22',
    promptQuestion: 'I geek out about...',
    promptAnswer: 'Neuroplasticity, how we literally rewire ourselves through experience.',
    height: "5'4\"",
    zodiac: "Virgo ♍",
    relationshipGoal: "Serious relationship",
    education: "MIT",
    degree: "Ph.D. Neuroscience",
    languages: ["English", "Hindi", "Gujarati"],
    mbti: "INFJ",
    drinking: "Never",
    smoking: "Never",
    exercise: "Daily",
    pets: "No pets",
    mutualFriends: 9,
    lookingFor: ["Intellectual depth", "Active lifestyle partner", "Genuine emotional connection"],
    profileCompletion: 99,
  ),
];

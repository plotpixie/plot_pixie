import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  final apiKey = Platform.environment['GEMINI_KEY'];
  if (apiKey == null) {
    exit(1);
  }
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final chat = model.startChat(history: []);
  var response = await chat.sendMessage(Content.text(
      """
    
    Generate a detailed save the cat outline for this work:
     
   Title: “The Solitary Enchantment: The Grinch of Eldoria”

SUMMARY
Izar wasn’t always a solitary wizard. Once, he was a jovial and beloved figure in Eldoria, known for his magical prowess and kind heart. However, his life took a tragic turn when he refused the love of a powerful sorceress named Morgana. In her wrath, Morgana cursed Izar, condemning him to a life of solitude. Any living being that came into contact with him would be turned to stone.

The curse transformed Izar. He became a grinch-like figure, bitter and resentful. His once vibrant tower turned into a gloomy fortress, and the petrified forest surrounding it stood as a stark reminder of his curse. Izar’s heart hardened over time, mirroring the stone figures that littered his surroundings.

However, a glimmer of hope appeared when Izar discovered an ancient prophecy about the Convergence of the Three Moons, a celestial event that could break any curse. The prophecy spoke of three elements: a tear from a phoenix, the heart of a dragon, and the laughter of a child.

Izar embarked on a perilous journey to gather these elements. Along the way, he encountered various creatures, including Ignis the dragoness, Seraphina the blind basilisk, and Lyra the young nymph. Each encounter tested Izar’s resolve and slowly chipped away at his hardened exterior.

Ignis taught Izar about empathy and sacrifice. From Seraphina, he learned about courage and resilience. And Lyra, with her infectious laughter, reminded him of the joy he had once known. Each of these interactions left a profound impact on Izar, gradually transforming him from a bitter recluse to a man rediscovering the warmth of connection.

In the end, Izar managed to perform the ritual during the Convergence, breaking the curse. The petrified beings returned to life, and Izar’s tower was once again filled with laughter and companionship. Izar’s transformation was complete. He was no longer the grinch of Eldoria but a beacon of hope and resilience.

CHARACTERS

Izar

Physical Attributes: Tall and lean with a long white beard, piercing blue eyes, and a staff adorned with mystical runes.
Voice: Deep and resonant, with a hint of melancholy.
Strengths: Immense magical prowess, wisdom, resilience.
Weaknesses: Initially bitter and resentful due to his curse, struggles with loneliness.
Deepest Secret: Regrets rejecting Morgana’s love, which led to his curse.
Favorite Media: Enjoys ancient texts and magical scrolls.
Fun Fact: Has a soft spot for celestial phenomena.
Favorite Saying: “Magic is merely the tool. The true power lies within the heart.”
Hobbies: Studying ancient texts, stargazing, experimenting with spells.
Fears: Fear of never breaking his curse, fear of hurting others due to his curse.
2. Luna

Physical Attributes: Dark hair, emerald green eyes, always seen in a cloak of raven feathers.
Voice: Soft yet chilling, with an undercurrent of suppressed rage.
Strengths: Powerful magic, particularly in curses and enchantments.
Weaknesses: Her wrath and inability to handle rejection.
Deepest Secret: Still harbors feelings for Izar.
Favorite Media: Enjoys tragic love stories.
Fun Fact: Has a raven named Obsidian as her familiar.
Favorite Saying: “Love and hate are two sides of the same coin.”
Hobbies: Brewing potions, reading about forbidden magic.
Fears: Fear of being alone, fear of rejection.
3. Ignis

Physical Attributes: Majestic dragoness with scales that shimmer like molten gold.
Voice: Roaring and fiery, yet capable of gentle whispers.
Strengths: Fierce protector, empathetic.
Weaknesses: Overprotective, initially intimidating.
Deepest Secret: Wishes to see the world beyond Mount Pyra.
Favorite Media: Loves listening to Izar’s tales.
Fun Fact: Can control the intensity of her fire.
Favorite Saying: “True strength lies not in power, but in kindness.”
Hobbies: Watching over the phoenix, flying around Mount Pyra.
Fears: Fear of failing in her duty to protect the phoenix.
4. Seraphina

Physical Attributes: A blind basilisk with iridescent scales.
Voice: Echoing and serene.
Strengths: Courageous, resilient, heightened senses.
Weaknesses: Blindness, initially wary of strangers.
Deepest Secret: Dreams of seeing the world.
Favorite Media: Enjoys the sound of dripping stalactites in the Crystal Caverns.
Fun Fact: Can navigate the caverns faster than any sighted creature.
Favorite Saying: “One does not need eyes to see the beauty of the world.”
Hobbies: Exploring the Crystal Caverns, listening to the echoes.
Fears: Fear of the world outside the Crystal Caverns.
5. Lyra

Physical Attributes: A young nymph with hair like autumn leaves and eyes as bright as spring.
Voice: Musical and full of laughter.
Strengths: Joyful, carefree, able to communicate with nature.
Weaknesses: Naive, overly trusting.
Deepest Secret: Wishes to spread joy beyond the enchanted forest.
Favorite Media: Loves the songs of the forest.
Fun Fact: Can make flowers bloom with a touch.
Favorite Saying: “Laughter is the sun that drives winter from the human face.”
Hobbies: Dancing with the wind, playing with forest creatures.
Fears: Fear of silence, fear of losing her joy.

SETTING

The story unfolds in the realm of Eldoria, a world that beautifully blends elements of Silk Punk, Wuxia, and futuristic Asian aesthetics.

Eldoria is a land where technology and magic coexist. The architecture is a fusion of traditional Asian designs and futuristic elements. Pagoda-style skyscrapers touch the sky, adorned with neon glyphs and holographic banners. The streets are bustling with people and automata, while airships and dragons fill the skies.

The heart of Eldoria is the Imperial City, a sprawling metropolis powered by a combination of steam, silk, and sorcery. Here, the Emperor’s palace stands tall, its jade and gold towers gleaming under the neon lights. Surrounding the palace is a labyrinth of streets filled with shops selling everything from enchanted artifacts to high-tech gadgets.

Beyond the city, the landscape transforms into lush bamboo forests, serene lotus ponds, and misty mountains. These natural landscapes are dotted with ancient temples, secluded monasteries, and hidden martial arts schools, reminiscent of classic Wuxia settings.

Eolan’s tower is located on the outskirts of the Imperial City, standing tall amidst a petrified forest. The tower is a marvel of Silk Punk aesthetics, with its intricate carvings, shimmering silk banners, and steam-powered mechanisms. Despite its isolation, the tower is a symbol of resilience and hope against the neon skyline.

The realm is inhabited by a diverse array of beings - humans, mythical creatures, and sentient automata, all living in harmony. The culture is a rich tapestry of ancient traditions and futuristic trends, where martial arts tournaments are as popular as cybernetic enhancements.

In this unique setting, our characters embark on their journey, battling curses, overcoming challenges, and discovering the true meaning of connection. This is the world of Eldoria - a realm where the past and future intertwine, and where every thread tells a story.


      """));
  print(response.text);

  while(!response.text!.endsWith("DONE")){
    response = await chat.sendMessage(Content.text("next chapter"));
    print(response.text);
  }

}

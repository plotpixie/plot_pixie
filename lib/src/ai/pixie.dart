import 'dart:convert';
import 'dart:developer';

import 'package:plot_pixie/src/ai/ai_manager.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/ai/model/work.dart';
import 'package:plot_pixie/src/ai/prompt/promp_manipulator.dart';
import 'package:retry/retry.dart';

class Pixie {
  static final Pixie _instance = Pixie._internal();

  final Work work = Work();

  factory Pixie() {
    return _instance;
  }

  Pixie._internal();

  void setIdea(Node idea) {
    this.work.idea = idea;
  }

  void setCharacters(List<Node> characters) {
    this.work.characters = characters;
  }

  Future<List<Node>> getIdeas(String prompt, {int numberOfIdeas = 5}) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "generate $numberOfIdeas original screenplay ideas for $prompt. The description is the logline, make the title titillating. ",
        ReturnType.node,
        options: 'idea');
    log(decoratedPrompt);
    List<Node> ideas = await promptAiEngine(decoratedPrompt);
    return ideas;
  }

  Future<void> generateOutline() async {
    String beatDescription = '''
     opening image:1, theme started:1, setup:4, catalyst:1, debate:6, break into two:1
     b story:1, fun and games:10, midpoint:1, bad guys close in:15, all is lost:1, dark night of the soul:5, break into three:1
     finale:13, final image:1
    ''';

    String prompt =
        """My story is called ${work.idea?.title} and it has the following description: 
          
          ${work.idea?.description} 
    
          The characters contained in the story are ${summarizeRoles(work.characters)}
          
          Generate an outline for my story. 
                    
          The beat description are:
          ${beatDescription}
         
          Each of the lines in the description represent a different act. The string values represent the plot points that need to be generated
          
          So for finale, for example, we would expect exactly 13 scenes, no more and no less.
          
          The String in the description represents the plot point of the beat. 
                   
          This is a save the cat type outline. You must generate all 15 beats and all the scenes within the beat. The number of scenes must match the ones provided. There should be a total of 56 scenes. 
          
          Distribute 56 scenes to the outline in a way that closely follows the recommended scene distribution for this outline type. 
          
          Be explicit and specific in the choices, for example, if the characters need to choose an action describe the actual action and the path they have decided. use specific locations, settings, places if needed. 
       
          For acts:
          The description to provide a short one sentence summary of the events in the act   

          For the beat description that matches the beat title, generate the number of scenes specified in the beat
          Make sure that the scene and beats that we have are distinct and different from the existing beats. Also make sure that they follow logically as the next step in the sequence of beats:
          
         The beat title should be a three to four word summary of the scene.
         The beat descriptions summarize the main actions and plot points in the beat. 
         There is no need for detailed character descriptions within the outline.

         Within a beat:
         The plot_point trait should be the type of the beat: for example {'type':'plot_point':, 'description': 'catalyst'}. 
         The plot_point_description trait should be the description about how the plot point is used within the save the cat outline
         The outside_plot trait for each beat describes the beat in terms of the action/outside plot development for the central character. 
         The inside_plot trait describes in detail the beat in terms of the emotional/inside plot development for the central character. 
         The relational trait describes how relationships evolve between characters. 
         The philosophical trait describes details about the philosophical plot - try to come up with philosophical ideas and questions even if this is not evident.
         Make sure the beats align with the development of the characters and fix any inconsistencies if it does not.
         
         Within a scene:
         Make sure that the scene fits within the point of the point_point_description trait in the beat, if it doesn't rewrite it so that it does fit
         Make sure that all the scenes together accomplish both the inside, outside, relational and philosophical plots outline within the beat
         
         The scene title is the master scene heading, for example, INT. LABORATORY - DAY . Make the scene heading fit where it makes sense.
         The scene description is a detailed summary of the actions, events and internal changes within the scene. Try to be explicit and rich with details.  Add any interesting conversation or dialogue that can come up
         
          When finished, type in it's own line the words DONE
""";

    // work.acts = await promptAiEngine(prompt, returnType: ReturnType.beat);

    print(await retrieveFromAiEngine(prompt));
  }

  Future<void> generateScript() async {
    String characterPrompt = """
    My story is called ${work.idea?.title} and it has the following description:      
    
    ${work.idea?.description}
    
    Generate a list of 4 characters for this idea. 
    For each character, set a character foundation that meets the following criteria. Fill out all 26 items in detail.
    
1. Name: (First, middle, last) Consider cultural origins, nicknames, and how it reflects personality.
2. Age & Appearance: Physical description (height, build, hair, eyes, etc.) and how it influences their interactions with the world.
3. Occupation & Social Status: Job, income level, social standing - these shape their experiences and aspirations.
4. Education & Background: Level of schooling, upbringing, family history - all contribute to their worldview.
5. Personality Traits: Dominant traits (courageous, sarcastic, shy) and their impact on decision-making.
6. Strengths & Weaknesses: Skills and talents contrasted with insecurities and vulnerabilities.
7. Motivations & Goals: What drives them? What do they desire most deeply?
8. Fears & Regrets: What keeps them up at night? What past mistakes haunt them?
9. Moral Compass: Their sense of right and wrong, and how it clashes or aligns with others.
10. Speech Patterns & Mannerisms: Unique ways of speaking, body language, and habits that reveal personality.
Inner World & Relationships:
11. Inner Voice & Self-Talk: How they think about themselves and the world, positive or negative self-image.
12. Emotional Range: How they express and manage emotions (open, stoic, etc.).
13. Secrets & Hidden Depths: Unrevealed aspects of their personality or past.
14. Relationships with Key Characters: Family, friends, rivals - how these connections influence their journey.
15. Dynamic with the Protagonist: Supportive, antagonistic, or somewhere in between?

Character Arc & Narrative Role:
16. Starting Point: Their state of mind and circumstances at the beginning of the story.
17. Catalyst for Change: The event that disrupts their life and propels them on a journey.
18. Internal & External Conflicts: Personal struggles and obstacles they face within and from the outside world.
19. Transformation & Growth: How they evolve throughout the story, overcoming challenges or succumbing to them.
20. Impact on the Plot: How their actions and decisions influence the overall narrative.
21. Protagonist's Desire: What does your protagonist want more than anything? What drives them towards their goal?
22. Obstacles: Identify all the challenges and conflicts that prevent the protagonist from achieving their desire.
23. Cause-and-Effect: Ensure a logical progression of events. Each action or decision should have a clear consequence that propels the story forward.
24. Progressive Complications: As the story progresses, the obstacles the protagonist faces should become increasingly difficult and complex.
25. Climax: Craft a satisfying climax that resolves the main conflict and delivers a payoff on the protagonist's desire.
26. Moral Argument: What is the underlying message or value conveyed by the story through the protagonist's journey?

    When finished, type in it's own line the words, without any styling, DONE
    """;

    String characters =
        await retrieveFromAiEngine(characterPrompt, terminationString: 'DONE');

    print(characters);

    String outline = await retrieveFromAiEngine("""
      My story is called ${work.idea?.title} and it has the following description:      
      
      ${work.idea?.description}
      
      The characters and their traits are ${characters}
          
      Generate an outline based on the 22 steps in the book the Anatomy of a StoryThis in-depth approach delves into 22 key story beats that create a compelling narrative.
      * Self-revelation, need, and desire: The hero realizes their need and forms a desire to change.
      * Ghost and story world: The hero’s past haunts them, affecting their present behavior and circumstances.
      * Weakness and need: The hero has a weakness that is hurting them.
      * Inciting event: Something happens that sets the story in motion.
      * Desire: The hero wants something and this drives the rest of the story.
      * Ally or allies: The hero has friends who will help them.
      * Opponent and/or mystery: The hero faces opposition or a mystery to solve.
      * Fake-ally opponent: Not everyone who appears to be a friend is.
      * First revelation and decision: A revelation leads to a decision and a goal.
      * Plan: The hero makes a plan to achieve their goal.
      * Opponent’s plan and main counterattack: The opponent also has a plan and this leads to a counterattack.
      * Drive: The hero is forced to react under pressure.
      * Attack by ally: The hero’s allies challenge them.
      * Apparent defeat: It seems like the hero has lost.
      * Second revelation and decision: A second revelation leads to a decision.
      * Audience revelation: The audience learns something the hero doesn’t know.
      * Third revelation and decision: A third revelation leads to a decision.
      * Gate, gauntlet, visit to death: The hero faces a series of tests, leading to the brink of death.
      * Battle: The hero faces a final confrontation.
      * Self-revelation: The hero realizes something about themselves.
      * Moral decision: The hero makes a moral decision.
      * New equilibrium: A new balance is established and the hero is changed.
      
       When finished, type in it's own line the words ***DONE***

      """, terminationString: '***DONE***');

    print(outline);

    String scenes = await retrieveFromAiEngine("""
      My story is called ${work.idea?.title} and it has the following description:      
      
      ${work.idea?.description}
      
      The characters and their traits are ${characters}
          
      We have the following outline: ${outline}    
          
      Based on this outline, generate a list of scenes that explores each of the 22 steps of the outline. In order. 
      
      For each scene, generate the following analysis:
      
      Give the scene a heading and a description. 
    Scene Purpose: This prompt can be used for scenes with multiple characters, focusing on a combination of character development and plot progression.
Choose the Type of Scene:
* Fast-Paced Dialogue: Ideal for high-tension moments or arguments. (Emotion: Anger, Fear, Excitement)
* Slow Character-Driven Scene: Explores internal conflicts and reveals character traits through introspection and subtle interactions. (Emotion: Sadness, Nostalgia, Doubt)
Setting: Briefly describe the location and atmosphere. How does it influence the characters' emotions and actions?
Characters: (Choose 2 or More)
* Character 1: Describe their personality traits and any relevant background information.
* Character 2: Describe their personality traits and any relevant background information.
* (Optional) Additional Characters: Briefly describe their role in the scene.
High Point of the Scene: Briefly describe the turning point or most significant moment in the scene.
Prompt:
Dialogue (if applicable):
* Tailor the dialogue to the chosen scene type:
    * Fast-Paced Dialogue: Filled with tension or subtext. Include informal language, character-specific quirks, and emotional undercurrents that reflect the chosen emotion.
    * Slow Character-Driven Scene: Sparse dialogue, replaced with descriptions of body language and expressions that convey the chosen emotion.
Internal Monologue (Optional):
* Choose one character to have an internal monologue that reflects the high point of the scene. Describe their internal conflict as they grapple with the situation or their interactions with other characters.
* Use vivid sensory details to depict the scene from their perspective (sight, sound, smell).
* Give voice to their inner thoughts and questions, revealing their motivations, hidden feelings, and how they react to the high point.
Optional: Include a moment of clarity where the chosen character notices a detail about another character or the situation that adds significance to the scene and ties back to the high point.
      
       When finished, type in it's own line the words ***DONE***

      """, terminationString: '***DONE***');

    print(scenes);

    String movie = """
      My story is called ${work.idea?.title} and it has the following description:      
      
      ${work.idea?.description}
      
      The characters and their traits are ${characters}
          
      We have the following outline: ${outline} 
      
      And this is the scene breakdown: ${scenes}

You are an award-winning science fiction author with a penchant for expansive,
intricately woven stories. Your ultimate goal is to write the next award winning
sci-fi novel.

Convert each scene of the story into it's own chapter.

You've begun to immerse yourself in this world, and the words are flowing.
Here's what you've written so far:

=====

First, silently review the outline and story so far. Identify what the single
next part of your outline you should write.

Your task is to continue where you left off and write the next part of the story.
You are not expected to finish the whole story now. Your writing should be
detailed enough that you are only scratching the surface of the next part of
your outline. Try to write AT MINIMUM 15000 WORDS per chapter. However, only once the story
is COMPLETELY finished, write DONE. Remember, do NOT write a whole chapter
right now.

Writing Guidelines

Delve deeper. Lose yourself in the world you're building. Unleash vivid
descriptions to paint the scenes in your reader's mind. Develop your
characters—let their motivations, fears, and complexities unfold naturally.
Weave in the threads of your outline, but don't feel constrained by it. Allow
your story to surprise you as you write. Use rich imagery, sensory details, and
evocative language to bring the setting, characters, and events to life.
Introduce elements subtly that can blossom into complex subplots, relationships,
or world building details later in the story. Keep things intriguing but not
fully resolved. Avoid boxing the story into a corner too early. Plant the seeds
of subplots or potential character arc shifts that can be expanded later.

When generating text and writing style, use the following guidelines:

Patterns in Nature:  consider patterns found in nature as a guide for narrative structure. She identifies three main patterns13:
Spiral: Think of a fiddlehead fern, whirlpool, hurricane, horns twisting from a ram’s head, or a chambered nautilus1.
Meander: Picture a river curving and kinking, a snake in motion, a snail’s silver trail, or the path left by a goat grazing the tenderest greens1.
Radial or Explosion: A splash of dripping water, petals growing from a daisy’s heart, light radiating from the sun, the ring left around a tick bite3.
Visual Elements: Alison suggests that writers can use visual elements such as texture, color, or symmetry to design their narratives. These elements can open windows and let us design as much as write1.
Parataxis and Hypotaxis: Alison explains the difference between parataxis (linear and sequential) and hypotaxis (more spatial, foregrounding some parts of the sentence and letting others recede) in sentences3.
Beyond the Arc: Alison argues that the narrative arc, which has its origins in Greek tragedy, should not be the only dominant form of the novel. She encourages writers to explore other patterns to make their narratives vital and true2.
Pattern Makers: Alison establishes writers as pattern makers, always alert to patterns—ways in which experience shapes itself, ways we can replicate its shape with words1.
Writing and Reading as Ways of Seeing: Alison draws on John Berger and Northrop Frye to illuminate writing and reading alike as ways of seeing1.

When dealing with characters and their character sheets:

Design of a Character Universe:the design of a character universe, which includes the dimensionality, complexity, and arcing of a protagonist, the invention of orbiting major characters, all encircled by a cast of service and supporting roles23.
Depth and Evolution: craft characters with depth, capable of evolving as the plot progresses4. He advocates for a detailed characterization process, exploring each character’s nuances and creating individuals that resonate authentically with audiences4.
Psychological, Philosophical, and Social Perspectives: tap into the psychological, philosophical, and social perspectives to create complex contradictions that readers identify with on both an intellectual and emotional level5.
Research and Imagination: Emphasizes the importance of research and imagination in character creation. He suggests that writers should pour out their imaginations and then research from the real world of the subject to give themselves choices6.
Interplay of Character, Plot, and Theme: Use a thematic square is a tool for intertwining character, plot, and theme. It breaks the process of organizing your story’s theme down into four key concepts that play off of one another: a positive, contradictory, contrary, and negative value7.

When writing action:

Mastering the Action Genre: Get to the heart and soul of the genre and infuse their own spin on it.
The Art of Excitement: Use narrative drive with precision and clarity.
Character Drives: Action sends a self-sacrificing hero against a self-obsessed villain in a story-long fight to thwart malevolence and rescue a hapless victim. These characters—hero, villain, victim—represent three opposing drives within every human being: the will to triumph, the impulse to destroy, and the hope to survive41.
Deconstructing the Action Genre: They illuminate the challenges of the genre and demonstrate how to master the demands of the action plot with surprising beats of innovation and ingenuity15.
Avoiding Clichés.

When writing dialogue:
Dialogue vs Conversation: dialogue is not simply conversation. It’s a form of verbal action where characters express their desires, intentions, and actions1. Each line of dialogue should serve a purpose and move the story forward.
Character Revelation: Dialogue is a powerful tool for revealing character. A character’s true nature is often revealed when they are under pressure3. How a character speaks, what they choose to say or not say, can tell the reader a lot about who they are.
Conflict and Dialogue: conflict is essential to dialogue. Characters should have differing desires and viewpoints, and these conflicts should come out in their dialogue.
Subtext: Good dialogue often has layers of meaning. What a character says on the surface might be different from what they actually mean. This subtext adds depth and complexity to the dialogue.
Naturalism: strive for dialogue that sounds natural and believable. However, he also warns against making dialogue too mundane or filled with irrelevant details.
Crafting Dialogue: Use practical advice on how to craft dialogue, including tips on punctuation, formatting, and the use of dialogue tags.

Use simpler language. Vary word widths.

Develop characters organically:  suggests that characters should develop organically, and writers must foster this development by loving each of their characters.
Use dialogue effectively: Good dialogue is integral to a story. Each character should be readily identifiable by what he or she says.
Plot should develop from character: Plot should develop from character, and writers shouldn’t try to cram characters into plots that don’t suit them.

Remember, your main goal is to write as much as you can. If you get through
the story too fast, that is bad. Expand, never summarize.

When finished, type in it's own line the words ***DONE***

      """;

      print(movie);

  }

  Future<List<Node>> getCharacterTeasers(
      {int numberOfCharacters = 5,
      List<Node> existingCharacters = const []}) async {
    String options =
        'guilty pleasure,catchphrase,quirks,pet peeves,favorite quote,strangest dream,embarrassing memory,weird habit,ideal weekend,bucket list item,guilty pleasure,lucky charm,hidden talent,dream vacation,deepest secret,strange hobby, proudest achievement, best childhood memory';
    String existing = (existingCharacters.length > 0)
        ? "I already have these characters: ${summarizeRoles(existingCharacters)}, Don't repeat any names or professions from this list.  "
        : '';
    String prompt =
        "My story has this title: '${work.idea?.title}' and this logline: '${work.idea?.description}'. $existing. Who are the other protagonists, antagonists, minor characters and supporting characters? Imagine $numberOfCharacters other characters for the story.  title should be 'first name, age, occupation'. The description is a detailed 3 paragraph backstory in the character's own voice without mentioning any other characters. Generate 4 to 6 traits. A mandatory trait is appearance. Other traits are unique and obscure information about the character. trait types must be in this list: ' $options '. ";
    log(prompt);
    List<Node> characters = await promptAiEngine(prompt,
        returnType: ReturnType.character, isChat: true);
    return characters;
  }

  Future<String> retrieveFromAiEngine(String prompt,
      {bool isChat = true, String terminationString = ']'}) async {
    String decoratedPrompt =
        PromptManipulator.decoratePrompt(prompt, ReturnType.text);
    await AiManager().resetChat("gemini");

    String? result =
        await AiManager().prompt("gemini", decoratedPrompt, isChat: isChat);
    String text = result!;

    while (!result!.endsWith(terminationString)) {
      result = await AiManager().prompt("gemini", 'continue', isChat: isChat);
      text = concatenateWithoutOverlap(text, result!);
    }

    return text;
  }

  Future<List<Node>> convertText(String text, ReturnType returnType) async {
    List<Node> nodes;
    try {
      if (returnType == ReturnType.text) {
        nodes = [Node('text', text, '')];
      } else {
        nodes = List<Node>.from(
            PromptManipulator.convertResult(text, returnType, true));
      }
    } catch (e) {
      throw Exception('Error in conversion: $e');
    }
    return nodes;
  }

  Future<List<Node>> promptAiEngine(String prompt,
      {ReturnType returnType = ReturnType.node, bool isChat = true}) async {
    return await retry(() async {
      String text = await retrieveFromAiEngine(prompt, isChat: isChat);
      List<Node> nodes = await convertText(text, returnType);
      return nodes;
    }, retryIf: (e) => true, maxAttempts: 5);
  }

  String summarizeRoles(List<Node> nodes) {
    return '[${nodes.map((node) => '${node.title}: ${node.description}').join('; ')}]';
  }

  String concatenateWithoutOverlap(String a, String b) {
    final overlapLength = a.length;
    if (overlapLength >= b.length) {
      return a + b;
    }
    return a + b.substring(overlapLength);
  }
}

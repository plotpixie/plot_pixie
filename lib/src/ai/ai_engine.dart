abstract class AiEngine {
  Future<String?> prompt(String prompt);
  Future<void> resetChat();
  Future<String?> chat(String prompt, [bool reset = false]);
}

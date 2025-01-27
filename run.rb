require 'discordrb'
require 'openai'
require 'dotenv/load'

class ChatGptService
  def initialize
    @openai = OpenAI::Client.new(access_token: ENV["OPENAI_SECRET_KEY"])
  end

  def chat(previous_message, current_message)
    prompt = if previous_message && !previous_message.empty?
               "previous message: #{previous_message}\nmessage: #{current_message}"
             else
               "message: #{current_message}"
             end

    response = @openai.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            "role": "system",
            "content": "You will help the user practice English. Focus on identifying mistakes in the current message (vocab, grammar, expressions, slang). When a 'previous message' exists, evaluate if the 'message' is an appropriate reply to it. Do not evaluate the 'previous message' itself. Ignore messages in Japanese or with only URLs. Avoid commenting on formatting like missing capitalization or apostrophes."
          },
          {
            "role": "assistant",
            "content": "Focus on the reply's correctness when a 'previous message' exists. Only evaluate the current 'message' in the context of the 'previous message.' Respond concisely in Japanese, highlighting only vocab, grammar, expressions, or slang issues."
          },
          { role: "user", content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 200
      }
    )
    response['choices'].first['message']['content']
  end
end
DISCORDBOT_CLIENT_ID = ENV["DISCORDBOT_CLIENT_ID"]
DISCORDBOT_TOKEN = ENV["DISCORDBOT_TOKEN"]

previous_message = nil
gpt_service = ChatGptService.new

bot = Discordrb::Bot.new(client_id: DISCORDBOT_CLIENT_ID, token: DISCORDBOT_TOKEN)

bot.message do |event|
  if event.channel.name == "ingurissyu"
    response = gpt_service.chat(previous_message, event.message.content)
    event.respond(response)
    previous_message = event.message.content
  end
end

bot.run
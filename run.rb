require 'discordrb'
require 'openai'
require 'dotenv/load'

class ChatGptService
  def initialize
    @openai = OpenAI::Client.new(api_key: ENV["OPENAI_SECRET_KEY"])
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
          { role: "system", content: "I want to practice English. Not in response to a message. Identify mistakes in my messages (vocab, grammar, expressions, slang).Do not point out missing apostrophes or capitalization.If there's a previous message, evaluate the current message in that context and its appropriatenes.Ignore messages in Japanese or with only URLs.Don't comment on previous messages.only vocab, grammar, expressions, slang  point out that.PLEASE RESPOND IN JAPANESE." },
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
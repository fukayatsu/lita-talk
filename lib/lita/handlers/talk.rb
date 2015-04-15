require 'docomoru'

module Lita
  module Handlers
    class Talk < Handler
      config :docomo_api_key,      type: String,  required: true
      config :docomo_character_id, type: Integer, required: false

      route(/^(.+)/, :talk, command: true, help: {
        "talk" => "Talk with you if given message didn't match any other handlers."
      })
      def talk(response)
        @robot.handlers.map do |handler|
          next nil if handler == self.class
          next nil unless handler.respond_to?(:routes)
          handler.routes
        end.flatten.compact.each do |route|
          next   if !route.command
          return if response.matches.flatten[0].match(route.pattern)
        end

        if response.matches.flatten[0].match(/ところで|それはそうと|そういえば|BTW/)
          Lita.redis.del context_key(response)
        end

        context = Lita.redis.get context_key(response)
        api_response = client.create_dialogue(response.message.body, params(context))
        Lita.redis.setex context_key(response), 600, api_response.body["context"]
        response.reply api_response.body["utt"]
      end

    private

      def client
        @client ||= Docomoru::Client.new(api_key: config.docomo_api_key)
      end

      def context_key(response)
        "lita-talk:#{response.message.source.room}"
      end

      def params(context)
        {
          context: context,
          t:       config.docomo_character_id,
        }.reject do |key, value|
          value.nil?
        end
      end
    end

    Lita.register_handler(Talk)
  end
end

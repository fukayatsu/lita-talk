require 'faraday'
require 'faraday_middleware'

module Lita
  module Handlers
    class Talk < Handler
      # @see: https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=natural_dialogue&p_name=api_4#tag01
      # @see: https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=natural_dialogue&p_name=api_4_user_registration#tag01
      API_ENDPOINT             = 'https://api.apigw.smt.docomo.ne.jp'.freeze
      API_DIALOGUE_PATH        = '/naturalChatting/v1/dialogue'.freeze
      API_REGISTRATION_PATH    = '/naturalChatting/v1/registration'.freeze

      # @see: https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=natural_dialogue&p_name=api_6#tag01
      CHARACTER_TYPES          = %w[default ehime1 ehime2 ehime3 kansai hakata fukushima mie maiko ojo bushi gyaru burikko akachan]

      config :docomo_api_key, type: String, required: true

      route(
        /^(.+)/,
        :talk,
        command: true,
        help: {
          'talk' => "Talk with you if given message didn't match any other handlers."
        }
      )

      route(
        /^type\s(.+)$/,
        :update_character_type,
        command: true,
        help: {
          'type (default|ehime1|ehime2|ehime3|kansai|hakata|fukushima|mie|maiko|ojo|bushi|gyaru|burikko|akachan)' => "Change type of bot"
        }
      )

      route(
        /^type$/,
        :show_type,
        command: true,
        help: {
          'type' => 'Show type of bot'
        }
      )

      def talk(response)
        return unless command_missing?(response)

        response.reply create_dialogue(response)
      end

      def show_type(response)
        response.reply character_type
      end

      def update_character_type(response)
        type = response.matches.dig(0, 0)

        if CHARACTER_TYPES.include?(type)
          redis.set('character_type', type)
          response.reply 'ok'
        else
          response.reply("Invalid type: #{type}.\nValid types: #{CHARACTER_TYPES.join(', ')}")
        end
      end

      private

      def character_type
        redis.get('character_type') || 'default'
      end

      def client_data
        type = character_type
        return {} if type == 'default'

        {
          option: {
            t: type
          }
        }
      end

      def create_dialogue(response)
        context = fetch_context(response)

        input_text = response.matches.dig(0, 0)

        resp = faraday.post do |req|
          req.url API_DIALOGUE_PATH
          req.body = {
            language: 'ja-JP',
            appId:     context,
            voiceText: input_text,
            botId:     'Chatting',
            clientData: client_data
          }
        end

        resp.body.dig('systemText', 'expression')
      end

      def command_missing?(response)
        all_handler_routes.each do |route|
          next unless route.command
          return false if response.matches.flatten[0].match(route.pattern)
        end

        true
      end

      def all_handler_routes
        robot.handlers.map do |handler|
          next nil unless handler.respond_to?(:routes)
          next handler.routes.slice(1..-1) if handler == self.class

          handler.routes
        end.flatten.compact
      end

      def faraday
        @faraday ||= Faraday.new(API_ENDPOINT) do |conn|
          conn.request :json
          conn.headers['Content-Type'] = 'application/json;charset=UTF-8'
          conn.params['APIKEY'] = config.docomo_api_key
          conn.response :json
          conn.adapter Faraday.default_adapter
        end
      end

      def fetch_context(response)
        key = context_key(response)
        context = redis.get(key)
        return context if context

        resp = faraday.post do |req|
          req.url API_REGISTRATION_PATH
          req.body = {
            botId:   'Chatting',
            appKind: 'bot'
          }
        end

        context = resp.body['appId']
        redis.set(key, context)
        context
      end

      def context_key(response)
        if Lita.config.robot.adapter == :twitter
          "lita-talk:#{response.message.user.id}"
        else
          "lita-talk:#{response.message.source.room}"
        end
      end
    end

    Lita.register_handler(Talk)
  end
end

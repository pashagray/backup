require "uri"

module Backup
  module Notifier
    class Telegram < Base
      ##
      # Bot token in format 1234567890:AzxcvBnmAsdFghjKfEdwdwdDWdsssZNeddw
      attr_accessor :token

      ##
      # Bot must be included as admin to chat
      attr_accessor :chat_id

      def initialize(model, &block)
        super
        instance_eval(&block) if block_given?

        @headers ||= {}
        @params  ||= {}
        @success_codes ||= 200
      end

      private

      ##
      # Notify the user of the backup operation results.
      #
      # `status` indicates one of the following:
      #
      # `:success`
      # : The backup completed successfully.
      # : Notification will be sent if `on_success` is `true`.
      #
      # `:warning`
      # : The backup completed successfully, but warnings were logged.
      # : Notification will be sent if `on_warning` or `on_success` is `true`.
      #
      # `:failure`
      # : The backup operation failed.
      # : Notification will be sent if `on_warning` or `on_success` is `true`.
      #
      def notify!(status)
        msg = message.call(model, status: status_data_for(status))

        opts = {
          headers: { "User-Agent" => "Backup/#{VERSION}" }
            .merge(headers).reject { |_, value| value.nil? }
            .merge("Content-Type" => "application/x-www-form-urlencoded"),
          body: URI.encode_www_form({ "text" => msg, "chat_id" => chat_id }
          expects: success_codes # raise error if unsuccessful
        }
        opts[:ssl_verify_peer] = ssl_verify_peer unless ssl_verify_peer.nil?
        opts[:ssl_ca_file] = ssl_ca_file if ssl_ca_file

        Excon.post("https://api.telegram.org/bot#{token}/sendMessage", opts)
      end
    end
  end
end
      
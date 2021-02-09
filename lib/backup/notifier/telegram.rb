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

      ##
      # Verify the server's certificate when using SSL.
      #
      # This will default to +true+ for most systems.
      # It may be forced by setting to +true+, or disabled by setting to +false+.
      attr_accessor :ssl_verify_peer

      ##
      # Path to a +cacert.pem+ file to use for +ssl_verify_peer+.
      #
      # This is provided (via Excon), but may be specified if needed.
      attr_accessor :ssl_ca_file

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
          headers: { "Content-Type" => "application/x-www-form-urlencoded" },
          body: URI.encode_www_form({ "text" => msg, "chat_id" => chat_id })
        }
        opts[:ssl_verify_peer] = ssl_verify_peer unless ssl_verify_peer.nil?
        opts[:ssl_ca_file] = ssl_ca_file if ssl_ca_file

        Excon.post("https://api.telegram.org/bot#{token}/sendMessage", opts)
      end
    end
  end
end
      
require "spec_helper"

module Backup
  describe Notifier::Telegram do
    let(:model) { Model.new(:test_trigger, "test label") }
    let(:notifier) do
      Notifier::Telegram.new(model) do |telegram|
        telegram.token = "xxx:xxx"
        telegram.chat_id = "-1"
      end
    end

    it_behaves_like "a class that includes Config::Helpers"
    it_behaves_like "a subclass of Notifier::Base"

    describe "#initialize" do
      it "configures the notifier" do
        notifier = Notifier::Telegram.new(model) do |post|
          post.token            = "xxx:xxx"
          post.chat_id          = "-1"
        end

        expect(notifier.token).to eq "xxx:xxx"
        expect(notifier.chat_id).to eq "-1"
      end
    end
  end
end

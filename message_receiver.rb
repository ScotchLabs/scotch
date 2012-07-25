require 'rubygems'
require 'redis'
require 'sidekiq'
require File.expand_path('./app/workers/message_receive_worker.rb')

class MessageReceive
  def initialize(raw_email)
    Sidekiq::Client.enqueue(MessageReceiveWorker, raw_email)
  end
end

MessageReceive.new($stdin.read)
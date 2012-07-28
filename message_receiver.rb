require 'rubygems'
require 'redis'
require 'sidekiq'
require File.expand_path('./app/workers/message_receive_worker.rb')

class MessageReceive
  def initialize(raw_email)
    email = Mail.read_from_string(raw_email)
    to = email.to.first
    from = email.from.first
    
    message = ""
    
    if email.multipart?
      part = email.parts.select { |p| p.content_type =~ /text\/plain/ }.first rescue nil
      unless part.nil?
        message = part.body.decoded
      end
    else
      message = part.body.decoded
    end
    
    Sidekiq::Client.enqueue(MessageReceiveWorker, to, from, message)
  end
end

MessageReceive.new($stdin.read)
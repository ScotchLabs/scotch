require 'rubygems'
require 'redis'
require 'sidekiq'
require 'securerandom'
require 'mail'
require File.join(File.dirname(__FILE__), '/app/workers/message_receive_worker.rb')

class MessageReceive
  def initialize(raw_email)
    email = Mail.read_from_string(raw_email)
    to = email.to.first.encode('UTF-8')
    from = email.from.first.encode('UTF-8')
    
    text_part = ""
    html_part = ""
    
    if email.multipart?
      text_part = email.parts.select { |p| p.content_type =~ /text\/plain/ }.first rescue nil
      html_part = email.parts.select { |p| p.content_type =~ /text\/html/ }.first rescue nil

      text_message = text_part.body.decoded.encode('UTF-8') unless text_part.nil?
      html_message = html_part.body.decoded.encode('UTF-8') unless html_part.nil?
    else
      text_part = email.body.decoded
    end
    
    Sidekiq::Client.enqueue(MessageReceiveWorker, to, from, email.subject.encode('UTF-8'), text_message, html_message)
  end
end

MessageReceive.new($stdin.read)

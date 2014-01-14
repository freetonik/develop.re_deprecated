#!/bin/env ruby
# encoding: utf-8
class EmailMessage < ActionMailer::Base
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def notify(message, user)
    @message = message
    @user = user

    mail(
      :to => user.email,
      :subject => "[#{Rails.application.name}] личное сообщение от " <<
        "#{message.author.username}: #{message.subject}"
    )
  end
end

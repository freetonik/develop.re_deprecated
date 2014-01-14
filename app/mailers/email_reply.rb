#!/bin/env ruby
# encoding: utf-8

class EmailReply < ActionMailer::Base
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def reply(comment, user)
    @comment = comment
    @user = user

    mail(
      :to => user.email,
      :subject => "[#{Rails.application.name}] Ответ на комментарий от " <<
        "#{comment.user.username} on #{comment.story.title}"
    )
  end

  def mention(comment, user)
    @comment = comment
    @user = user

    mail(
      :to => user.email,
      :subject => "[#{Rails.application.name}] Упоминание от " <<
        "#{comment.user.username} on #{comment.story.title}"
    )
  end
end

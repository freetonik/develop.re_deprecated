#!/bin/env ruby
# encoding: utf-8
class PasswordReset < ActionMailer::Base
  default :from => "#{Rails.application.name} " <<
    "<nobody@#{Rails.application.domain}>"

  def password_reset_link(user, ip)
    @user = user
    @ip = ip

    mail(
      :to => user.email,
      :subject => "[#{Rails.application.name}] сброс пароля"
    )
  end
end

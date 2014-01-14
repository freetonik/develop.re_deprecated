#!/bin/env ruby
# encoding: utf-8

class SignupController < ApplicationController
  before_filter :require_logged_in_user, :only => :invite

  def index
    if @user
      flash[:error] = "Вы уже зарегистрированы."
      return redirect_to "/"
    end

    @title = "Signup"
  end

  def invited
    if @user
      flash[:error] = "Вы уже зарегистрированы."
      return redirect_to "/"
    end

    if !(@invitation = Invitation.where(:code => params[:invitation_code].to_s).first)
      flash[:error] = "Приглашение неверное или истек срок его годности"
      return redirect_to "/signup"
    end

    @title = "Регистрация"

    @new_user = User.new
    @new_user.email = @invitation.email

    render :action => "invited"
  end

  def signup
    if !(@invitation = Invitation.where(:code => params[:invitation_code].to_s).first)
      flash[:error] = "Приглашение неверное или истек срок его годности."
      return redirect_to "/signup"
    end

    @title = "Регистрация"

    @new_user = User.new(params[:user])
    @new_user.invited_by_user_id = @invitation.user_id

    if @new_user.save
      @invitation.destroy
      session[:u] = @new_user.session_token
      flash[:success] = "Добро пожаловать на #{Rails.application.name}, " <<
        "#{@new_user.username}!"

      Countinual.count!("#{Rails.application.shortname}.users.created", "+1")

      return redirect_to "/signup/invite"
    else
      render :action => "invited"
    end
  end
end

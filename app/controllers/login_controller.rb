#!/bin/env ruby
# encoding: utf-8

class LoginController < ApplicationController
  before_filter :authenticate_user

  def logout
    if @user
      reset_session
    end

    redirect_to "/"
  end

  def index
    @title = "Вход"
    render :action => "index"
  end

  def login
    if (user = User.where("email = ? OR username = ?", params[:email].to_s,
    params[:email].to_s).first) &&
    user.try(:authenticate, params[:password].to_s)
      session[:u] = user.session_token
      return redirect_to "/"
    end

    flash.now[:error] = "Неправильный e-mail/логин или пароль."
    index
  end

  def forgot_password
    @title = "Сбросить пароль"
    render :action => "forgot_password"
  end

  def reset_password
    @found_user = User.where("email = ? OR username = ?", params[:email].to_s,
      params[:email].to_s).first

    if !@found_user
      flash.now[:error] = "Неправильный e-mail или имя (логин)."
      return forgot_password
    end

    @found_user.initiate_password_reset_for_ip(request.remote_ip)

    flash.now[:success] = "Инструкции по сбросу пароля высланы на почту."
    return index
  end

  def set_new_password
    @title = "Сброс пароля"

    if params[:token].blank? ||
    !(@reset_user = User.where(:password_reset_token => params[:token].to_s).first)
      flash[:error] = "Неправильный токен сброса. Возможно, его уже использовали, " <<
        "или вы ошиблись при копировании ссылки."
      return redirect_to forgot_password_url
    end

    if params[:password].present?
      @reset_user.password = params[:password]
      @reset_user.password_confirmation = params[:password_confirmation]
      @reset_user.password_reset_token = nil

      # this will get reset upon save
      @reset_user.session_token = nil

      if @reset_user.save
        session[:u] = @reset_user.session_token
        return redirect_to "/"
      end
    end
  end
end

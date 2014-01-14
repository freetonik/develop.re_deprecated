#!/bin/env ruby
# encoding: utf-8

class SettingsController < ApplicationController
  before_filter :require_logged_in_user

  def index
    @title = "Настройки"

    @edit_user = @user.dup
  end

  def update
    @edit_user = @user.clone

    if @edit_user.update_attributes(params[:user])
      flash.now[:success] = "Настройки успешно сохранены."
      @user = @edit_user
    end

    render :action => "index"
  end
end

#!/bin/env ruby
# encoding: utf-8

class FavoritesController < ApplicationController
  STORIES_PER_PAGE = 25

  before_filter :authenticate_user

  def index
    @cur_url = "/favorites"
    @title = "Избранное"

    @page = 1
    if params[:page].to_i > 0
      @page = params[:page].to_i
    end

    @stories = @user.favorite_stories.includes(
      :user, :taggings => :tag
    ).limit(
      STORIES_PER_PAGE + 1
    ).offset(
      (@page - 1) * STORIES_PER_PAGE
    ).order(
      "stories.created_at DESC"
    ).to_a

    @show_more = false

    if @stories.count > STORIES_PER_PAGE
      @show_more = true
      @stories.pop
    end
  end
end

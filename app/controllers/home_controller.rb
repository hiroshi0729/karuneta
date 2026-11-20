class HomeController < ApplicationController
  def index
    @upcoming_posts = current_user.posts.includes(:category).upcoming.limit(3)
    @drafting_posts = current_user.posts.includes(:category).drafting.order(updated_at: :desc).limit(3)
    @idea_count = current_user.posts.idea.count
    @posted_count = current_user.posts.posted.count
  end
end

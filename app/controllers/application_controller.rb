class ApplicationController < ActionController::Base
  def welcome
  end

  @@class_commits = ApiService.aggregate_by_author(:commits)
  @@class_pulls = ApiService.aggregate_by_author(:pulls)

  @@default_commits = ApiService.contributions[:defaults][:commits]
  @@default_pulls = ApiService.contributions[:defaults][:pulls]

  def self.default
    @@default_pulls
  end

  def self.rate_limit_hit?
    default == pulls
  end

  def self.commits
    @@class_commits == {} ? @@default_commits : @@class_commits
  end

  def self.pulls
    @@class_pulls == {} ? @@default_pulls : @@class_pulls
  end

  def self.reset_commits
    @@class_commits = ApiService.aggregate_by_author(:commits)
  end

  def self.reset_pulls
    @@class_pulls = ApiService.aggregate_by_author(:pulls)
  end
end

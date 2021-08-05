require 'faraday'
require 'json'

class API

  def initialize
  end

  def self.contributors
    {
      taylor: 'https://api.github.com/repos/bfl3tch/little-esty-shop/commits?author=tvaroglu&per_page=100',
      michael: 'https://api.github.com/repos/bfl3tch/little-esty-shop/commits?author=AbbottMichael&per_page=100',
      elliot: 'https://api.github.com/repos/bfl3tch/little-esty-shop/commits?author=ElliotOlbright&per_page=100',
      brian: 'https://api.github.com/repos/bfl3tch/little-esty-shop/commits?author=bfl3tch&per_page=100'
    }
  end

  def self.contributions
    {
      commits: contributors,
      pulls: 'https://api.github.com/repos/bfl3tch/little-esty-shop/pulls?state=closed',
      defaults: {
       commits: {'tvaroglu' => 57, 'AbbottMichael' => 28, 'ElliotOlbright' => 49, 'bfl3tch' => 40},
       pulls: {'tvaroglu' => 8, 'AbbottMichael' => 6, 'ElliotOlbright' => 10, 'bfl3tch' => 7}
     }
    }
  end

  def self.make_request(endpoint)
    Faraday.get(endpoint)
  end

  def self.repo_name
    APIS::RepoName.new(contributions[:pulls]).format
  end

  def self.user_names
    APIS::UserNames.new(contributors).format
  end

  def self.render_request(endpoint)
    APIS::RenderRequest.new(endpoint).parse
  end

  def self.aggregate_by_author(metric)
    if metric == :commits
      APIS::Commits.new(render_request(contributions[:commits])).total_count_by_author
    elsif metric == :pulls
      APIS::Pulls.new(render_request(contributions[:pulls])).total_count_by_author
    end
  end


end

class ApiService
  class << self
    def base_urls
      {
        github: 'https://api.github.com/repos',
        nager_date: 'https://date.nager.at'
      }
    end

    def contributors
      {
        taylor: "#{base_urls[:github]}/bfl3tch/little-esty-shop/commits?author=tvaroglu&per_page=100",
        michael: "#{base_urls[:github]}/bfl3tch/little-esty-shop/commits?author=AbbottMichael&per_page=100",
        elliot: "#{base_urls[:github]}/bfl3tch/little-esty-shop/commits?author=ElliotOlbright&per_page=100",
        brian: "#{base_urls[:github]}/bfl3tch/little-esty-shop/commits?author=bfl3tch&per_page=100"
      }
    end

    def contributions
      {
        commits: contributors,
        pulls: "#{base_urls[:github]}/bfl3tch/little-esty-shop/pulls?state=closed",
        defaults: {
          commits: { 'tvaroglu' => 57, 'AbbottMichael' => 28,
                     'ElliotOlbright' => 49, 'bfl3tch' => 40 },
          pulls: { 'tvaroglu' => 8, 'AbbottMichael' => 6,
                   'ElliotOlbright' => 10, 'bfl3tch' => 7 }
        }
      }
    end

    def holidays_endpoint
      "#{base_urls[:nager_date]}/api/v1/Get/US/2021"
    end

    def repo_name
      Services::RepoName.new(contributions[:pulls]).format
    end

    def user_names
      Services::UserNames.new(contributors).format
    end

    def render_request(endpoint)
      Services::RenderRequest.new(endpoint).parse
    end

    def upcoming_holidays
      Services::Holidays.new(render_request(holidays_endpoint)).next_3
    end

    def aggregate_by_author(metric)
      if metric == :commits
        Services::Commits.new(render_request(contributions[:commits])).total_count_by_author
      elsif metric == :pulls
        Services::Pulls.new(render_request(contributions[:pulls])).total_count_by_author
      end
    end
  end
end

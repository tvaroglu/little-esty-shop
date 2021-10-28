module Services
  class Commits
    def initialize(response_body)
      @response_body = response_body
    end

    def aggregate
      grouping = Hash.new(0)
      if @response_body.instance_of?(Array) && @response_body.all? do |author|
           !author['author'].nil?
         end
        grouping['commits'] = @response_body.group_by do |author|
          author['author']['login']
        end
      else
        grouping['commits'] = []
      end
    end

    def total_count_by_author
      totals = Hash.new(0)
      aggregate.each do |author, commits|
        totals[author] = commits.length unless author.nil?
      end
      totals
    end
  end
end

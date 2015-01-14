require 'trello'
require 'scrum/column'

module Scrum

  class Board

    def initialize(sprint)
      @sprint = sprint
      configure_trello
      @board ||= Trello::Board.find(OPTS.trello['scrum_enabled_board'])
    end

    def active_columns
      @active_columns ||= @board.lists.select{|x| !x.closed}
    end

    def todo_column
      Column.new(active_columns.find{|x| x.name == 'To Do'})
    end

    def doing_column
      Column.new(active_columns.find{|x| x.name == 'Doing'})
    end

    def review_column
      Column.new(active_columns.find{|x| x.name == 'In review'})
    end

    def first_week_done_column
      year        = @sprint.start_date.strftime('%Y')
      week_number = @sprint.start_date.cweek
      done_column(year, week_number)
    end

    def last_week_done_column
      year        = @sprint.end_date.strftime('%Y')
      week_number = @sprint.end_date.cweek
      done_column(year, week_number)
    end

    def done_as_of_today
      last_week_done_column.sum + first_week_done_column.sum
    end

    private

    def done_column(year, week_number)
      Column.new(active_columns.find{|x| x.name == "Done (#{year}##{week_number})"})
    end

    def configure_trello
      Trello.configure do |config|
        config.developer_public_key = OPTS.trello['developer_public_key']
        config.member_token         = OPTS.trello['member_token']
      end
    end
  end

end

require 'gruff'
require 'scrum/board'
require 'scrum/day'

module Scrum

  class Sprint

    attr_reader :number, :board
    attr_accessor :days, :committed

    def initialize(number: nil)
      @number           = number || determine_sprint_number
      @board            = Board.new(self)
      @days             = []
      get_stored_days
    end

    def determine_sprint_number
      @determine_sprint_number ||= sprint_timeline.find{|_, sprint_range| sprint_range.include?(Date.today) }.first
    end

    def sprint_range
      sprint_timeline[@number]
    end

    def get_stored_days
      (1..SPRINT_DAYS).each do |day|
        sprint_date = next_sprint_day(day)
        day = Day.new(number: day, sprint: self, date: sprint_date)
        break if day.date.future? || day.date.today?
        @days << day.pull
      end
    end

    def committed
      @committed ||= [
        @board.todo_column.sum,
        @board.doing_column.sum,
        @board.review_column.sum,
        @board.first_week_done_column.sum,
        @board.last_week_done_column.sum,
      ].reduce(:+)
    end

    def currently_done_points
      @board.done_as_of_today
    end

    def ideal_burndown
      (SPRINT_DAYS + 1).times.to_a.map do |day|
        ideal_leftover = committed - committed/SPRINT_DAYS.to_f * day
        ideal_leftover >= 0.0 ? ideal_leftover.round(1) : 0.0
      end
    end

    def labels
      (0..SPRINT_DAYS).to_a.map.inject({}) {|mem, x| mem[x] = x.to_s; mem}
    end

    def burndown_array
      days.map {|d| committed - d.done_points }.unshift(committed)
    end

    # :nocov:
    def draw_chart(location)
      g = Gruff::Line.new
      g.data :ideal, ideal_burndown
      g.data :current, burndown_array
      g.font = File.join Scrum::ROOT, '/fonts/Humor-Sans-1.0.ttf'
      g.title = "SCC Burndown Sp##{number}"
      g.x_axis_label = "#{SPRINT_DAYS} days of sprint"
      g.y_axis_label = 'Story Points'
      g.y_axis_increment = 5
      g.labels = labels
      g.minimum_value = 0
      render_location = File.join(location, "scrum_burndown_sp#{number}.png")
      g.write(render_location)
      render_location
    end
    # :nocov:

    def start_date
      sprint_timeline[number].first
    end

    def end_date
      sprint_timeline[number].last
    end

    private

    def sprint_timeline
      @sprint_timeline = {}
      (1..100).each.inject(Scrum::FIRST_DAY) do |sprint_start, num|
        sprint_end = sprint_start + (2.weeks - 1.day)
        @sprint_timeline[num] = sprint_start..sprint_end
        sprint_start = sprint_end + 1.day
        sprint_start
      end
      @sprint_timeline
    end

    def next_sprint_day(day)
      range = sprint_range.to_a
      range.delete_if{|x| x.sunday? || x.saturday?}
      range[day-1]
    end

  end

end

module Scrum

  class Day

    attr_reader :number, :date
    attr_accessor :done_points

    def initialize(number: nil, sprint: sprint, done_points: nil, date: nil)
      @date        = date
      @number      = number
      @sprint      = sprint
      @done_points = done_points
    end

    def key
      "sprint#{@sprint.number}.day#{number}"
    end

    def pull
      if stored?
        self.done_points = Scrum.storage.extract(self)[:points_done]
      else
        self.done_points = @sprint.board.done_as_of_today
        self.push
      end
      self
    end

    def stored?
      Scrum.storage.exists?(self)
    end

    def push
      Scrum.storage.store(self)
    end

    def to_json
      # TODO: use proper override like super(:only => :foo, :methods => [:foo, :baz])
      { 'points_done' => done_points }.to_json
    end
  end

end

module Scrum

  class Column

    def initialize(trello_column)
      @trello_column = trello_column
    end

    def estimated_cards
      @trello_column.cards.select{|x| x.name =~ /\A\(\d\).*/}
    end

    def sum
      estimated_cards.map{|x| x.name.match(/\((\d)\).*/)[1].to_i}.sum
    end

  end

end


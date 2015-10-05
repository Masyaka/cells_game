require_relative 'cell'
require_relative 'cells_map'

class GameMap < CellsMap
  attr_accessor :global_state
  NEUTRAL_COLOR = Cell.neutral_color

  def initialize (global_state_p)
    @global_state = global_state_p
    super()
  end

  def move (from_x, from_y, direction, player_name)
    case direction
      when 'left'
        new_x = from_x - 1
        new_y = from_y
      when 'right'
        new_x = from_x + 1
        new_y = from_y
      when 'top'
        new_x = from_x
        new_y = from_y - 1
      when 'bottom'
        new_x = from_x
        new_y = from_y + 1
      else
        new_x = from_y
        new_y = from_x
    end

    player = global_state.players.find {|s| s.name == player_name}
    new_cell = Cell.new(x:new_x, y:new_y, fraction: player.fraction)

    prev_color = self[new_cell.hash].nil? ? NEUTRAL_COLOR : self[new_cell.hash].color

    self << new_cell

    if prev_color != NEUTRAL_COLOR && prev_color != new_cell.color
      clear_islands prev_color
    end
  end

  def clear_islands (color)
    islands = self.count_islands color
    while islands.count > 1
      min_island = islands.min_by {|i| i[:self_count]}
      self.dfs(min_island[:root_y], min_island[:root_x], Hash.new,  color) do |col, row|
        self.delete cid(col, row)
      end
      islands.delete min_island
      end
  end
end
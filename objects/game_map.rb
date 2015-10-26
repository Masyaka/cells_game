require_relative 'cell'
require_relative 'cells_map'

class GameMap < CellsMap
  NEUTRAL_COLOR = Cell.neutral_color

  def move (from_x, from_y, direction, player)
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

    new_cell = Cell.new(x:new_x, y:new_y, fraction: player.fraction)

    prev_color = self[new_cell.hash].nil? ? NEUTRAL_COLOR : self[new_cell.hash].color

    if prev_color != NEUTRAL_COLOR && prev_color != new_cell.color
      clear_islands prev_color
    end
    new_cell
  end

  def clear_islands (color)
    islands = self.count_islands color
    while islands.count > 1
      min_island = islands.min_by {|i| i[:cells_count]}
      self.dfs(min_island[:root_y], min_island[:root_x], Hash.new,  color) do |col, row|
        self.delete cid(col, row)
      end
      islands.delete min_island
      end
  end
end
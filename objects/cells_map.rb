require_relative 'coordinate_utilities'
require_relative 'cell'

class CellsMap < Hash
  include CoordinateUtilities

  attr_reader :changes

  # These arrays are used to get row and column numbers of 8 neighbors of a given cell
  NEIGHBOUR_ROWS = [-1, -1, -1,  0, 0,  1, 1, 1]
  NEIGHBOUR_COLS = [-1,  0,  1, -1, 1, -1, 0, 1]

  def initialize
    @changes = []
  end

  # A function to check if a given cell (row, col) can be included in DFS
  def dfs_possible? (row, col, visited, color)
    cell_hash = cid(col, row)
    in_range(row, col) &&
        !visited[cell_hash] &&
        !self[cell_hash].nil? &&
        self[cell_hash].color == color
  end

  # A utility function to do DFS (Depth First Search)
  # @param [Integer] row
  # @param [Integer] col
  # @param [Hash] visited
  # @param [String] color
  # @return [Hash]
  def dfs(row, col, visited, color, &given_block)
    # Mark this cell as visited
    visited[cid(col, row)] = true

    yield(col, row) if block_given?

    cells_count = 1

    # Recur for all connected neighbours
    8.times do |i|
      if dfs_possible?(row + NEIGHBOUR_ROWS[i], col + NEIGHBOUR_COLS[i], visited, color)
        cells_count += dfs(row + NEIGHBOUR_ROWS[i], col + NEIGHBOUR_COLS[i], visited, color, &given_block)
      end
    end

    cells_count
  end

  # Returns array of islands
  # @param [String] color
  # @return [Hash]
  def count_islands(color)
    visited = Hash.new
    result = []

    width.times do |w|
      height.times do |h|
        if dfs_possible?(min_row + h, min_col + w, visited, color)
          result << {
            cells_count: dfs(min_row + h, min_col + w, visited, color),
            root_x: min_col + w,
            root_y: min_row + h
          }
        end
      end
    end

    result
  end

  def in_range (row, col)
    (row >= min_row) && (row <= max_row) && # row number is in range
    (col >= min_col) && (col <= max_col) # column number is in range
  end

  def width
    max_col - min_col + 1
  end

  def height
    max_row - min_row + 1
  end

  def max_col
    self.max_by{|k,v|v.x}[1].x
  end

  def min_col
    self.min_by{|k,v|v.x}[1].x
  end

  def max_row
    self.max_by{|k,v|v.y}[1].y
  end

  def min_row
    self.min_by{|k,v|v.y}[1].y
  end

  def << (cell)
    self[cell.hash] = cell if cell.is_a? Cell
  end

  def []=(key,val)
    super(key,val)
    cell_created(key,val)
  end

  def cell_created(key, val)
    cell = self[key]
    @changes << {
        color: cell.color,
        x: cell.x,
        y: cell.y
    }
  end

  def delete(key)
    cell = self[key]
    cell_deleted(key) if cell.is_a? Cell
    super(key)
  end

  def cell_deleted(key)
    cell = self[key]
    @changes << {
        color: Cell.neutral_color,
        x: cell.x,
        y: cell.y
    }
  end

end
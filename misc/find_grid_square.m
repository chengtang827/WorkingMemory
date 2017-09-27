function [row,col] = find_grid_square(grid, x, y)
  row = floor((y - grid.ymargin)/grid.ydiff)+1;
  col = floor((x - grid.xmargin)/grid.xdiff)+1;
end

defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> create_grid
    |> filter_grid
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    #[r, g, b | _tail] = hex
    %Identicon.Image{image | color: {r, g, b}}
  end

  def create_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def filter_grid(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end)

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map(grid, fn({_code, index}) ->
      hor = rem(index, 5) * 50
      ver = div(index, 5) * 50

      top_left = {hor, ver}
      buttom_right = {hor + 50, ver + 50}

      {top_left, buttom_right}
    end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |>:binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
